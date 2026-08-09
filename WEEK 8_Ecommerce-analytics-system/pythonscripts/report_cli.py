"""
report_cli.py
-------------
Command-line reporting tool for the E-Commerce Order Analytics System.

Connects to database/ecommerce.db and generates a summary report for a
given period, comparing it against the immediately preceding period of
the same length.

Usage:
    python scripts/report_cli.py --report daily   --start 2026-01-01 --end 2026-01-01
    python scripts/report_cli.py --report weekly  --start 2026-01-01 --end 2026-01-07
    python scripts/report_cli.py --report monthly --start 2026-01-01 --end 2026-01-31

Arguments:
    --report   One of: daily, weekly, monthly
    --start    Start date, format YYYY-MM-DD
    --end      End date, format YYYY-MM-DD (inclusive)

The report shows:
    - Total orders
    - Total revenue
    - Unique customers
    - Top 3 products
    - Comparison with the previous period of equal length (% change)

No results are hard-coded; every number comes from a live query against
the SQLite database.
"""

import argparse
import sqlite3
import sys
from datetime import datetime, timedelta
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "database" / "ecommerce.db"

VALID_REPORT_TYPES = ("daily", "weekly", "monthly")


def parse_args(argv=None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="E-Commerce Order Analytics System - CLI Reporting Tool"
    )
    parser.add_argument(
        "--report", required=True, choices=VALID_REPORT_TYPES,
        help="Type of report: daily, weekly, or monthly"
    )
    parser.add_argument("--start", required=True, help="Start date (YYYY-MM-DD)")
    parser.add_argument("--end", required=True, help="End date (YYYY-MM-DD, inclusive)")
    return parser.parse_args(argv)


def validate_dates(start_str: str, end_str: str):
    """Parse and validate the date range. Returns (start_date, end_date) as
    datetime.date objects, or raises ValueError with a clear message."""
    try:
        start_date = datetime.strptime(start_str, "%Y-%m-%d").date()
    except ValueError:
        raise ValueError(f"Invalid --start date '{start_str}'. Expected format: YYYY-MM-DD")

    try:
        end_date = datetime.strptime(end_str, "%Y-%m-%d").date()
    except ValueError:
        raise ValueError(f"Invalid --end date '{end_str}'. Expected format: YYYY-MM-DD")

    if end_date < start_date:
        raise ValueError(f"--end date ({end_date}) cannot be before --start date ({start_date})")

    return start_date, end_date


def get_connection() -> sqlite3.Connection:
    """Connect to the SQLite database, raising a clear error if missing."""
    if not DB_PATH.exists():
        raise FileNotFoundError(
            f"Database not found at {DB_PATH}. "
            f"Run 'python scripts/load_database.py' first to create it."
        )
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.execute("SELECT 1")  # simple connectivity check
        return conn
    except sqlite3.Error as e:
        raise ConnectionError(f"Could not connect to the database: {e}")


def get_period_metrics(conn: sqlite3.Connection, start_date, end_date) -> dict:
    """Return total_orders, total_revenue, unique_customers, and top 3
    products for the given inclusive date range."""
    cur = conn.cursor()
    start_str = start_date.strftime("%Y-%m-%d 00:00:00")
    end_str = end_date.strftime("%Y-%m-%d 23:59:59")

    cur.execute(
        """
        SELECT COUNT(DISTINCT o.order_id), COUNT(DISTINCT o.customer_id)
        FROM orders o
        WHERE o.order_date BETWEEN ? AND ?
        """,
        (start_str, end_str),
    )
    total_orders, unique_customers = cur.fetchone()
    total_orders = total_orders or 0
    unique_customers = unique_customers or 0

    cur.execute(
        """
        SELECT COALESCE(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 0)
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        WHERE o.order_date BETWEEN ? AND ? AND oi.quantity > 0
        """,
        (start_str, end_str),
    )
    total_revenue = cur.fetchone()[0] or 0.0

    cur.execute(
        """
        SELECT p.product_name, SUM(oi.quantity) AS qty_sold
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        JOIN products p ON oi.product_id = p.product_id
        WHERE o.order_date BETWEEN ? AND ? AND oi.quantity > 0
        GROUP BY p.product_id, p.product_name
        ORDER BY qty_sold DESC
        LIMIT 3
        """,
        (start_str, end_str),
    )
    top_products = cur.fetchall()

    return {
        "total_orders": total_orders,
        "total_revenue": round(total_revenue, 2),
        "unique_customers": unique_customers,
        "top_products": top_products,
    }


def pct_change(current: float, previous: float):
    """Return percentage change from previous to current, or None if
    previous is zero (undefined % change)."""
    if previous == 0:
        return None
    return round(((current - previous) / previous) * 100, 2)


def format_pct(value):
    if value is None:
        return "N/A (no prior data)"
    sign = "+" if value >= 0 else ""
    return f"{sign}{value}%"


def print_report(report_type: str, start_date, end_date, current: dict, previous: dict) -> None:
    width = 60
    print("=" * width)
    print(f"{report_type.upper()} REPORT".center(width))
    print(f"Period: {start_date} to {end_date}".center(width))
    print("=" * width)

    if current["total_orders"] == 0:
        print("\nNo orders found in this period.")
    else:
        print(f"\nTotal Orders:      {current['total_orders']}")
        print(f"Total Revenue:     ${current['total_revenue']:,.2f}")
        print(f"Unique Customers:  {current['unique_customers']}")

        print("\nTop 3 Products (by quantity sold):")
        if current["top_products"]:
            for i, (name, qty) in enumerate(current["top_products"], start=1):
                print(f"  {i}. {name:<30} {qty} units")
        else:
            print("  (no product sales in this period)")

    print("\n" + "-" * width)
    print("COMPARISON WITH PREVIOUS PERIOD".center(width))
    print("-" * width)
    print(f"Previous Total Orders:     {previous['total_orders']}")
    print(f"Previous Total Revenue:    ${previous['total_revenue']:,.2f}")
    print(f"Previous Unique Customers: {previous['unique_customers']}")

    orders_change = pct_change(current["total_orders"], previous["total_orders"])
    revenue_change = pct_change(current["total_revenue"], previous["total_revenue"])
    customers_change = pct_change(current["unique_customers"], previous["unique_customers"])

    print(f"\nOrders change:     {format_pct(orders_change)}")
    print(f"Revenue change:    {format_pct(revenue_change)}")
    print(f"Customers change:  {format_pct(customers_change)}")
    print("=" * width)


def build_report_lines(report_type: str, start_date, end_date, current: dict, previous: dict) -> str:
    """Same content as print_report but returned as a string, used when
    saving sample reports to file."""
    import io
    buf = io.StringIO()
    import contextlib
    with contextlib.redirect_stdout(buf):
        print_report(report_type, start_date, end_date, current, previous)
    return buf.getvalue()


def run_report(report_type: str, start_str: str, end_str: str) -> str:
    """High level orchestration: validate input, connect, query, and
    return the formatted report text. Raises exceptions on bad input or
    connection errors so callers (CLI or tests) can handle them."""
    if report_type not in VALID_REPORT_TYPES:
        raise ValueError(f"Invalid report type '{report_type}'. Must be one of {VALID_REPORT_TYPES}")

    start_date, end_date = validate_dates(start_str, end_str)
    period_length = (end_date - start_date).days + 1

    prev_end_date = start_date - timedelta(days=1)
    prev_start_date = prev_end_date - timedelta(days=period_length - 1)

    conn = get_connection()
    try:
        current = get_period_metrics(conn, start_date, end_date)
        previous = get_period_metrics(conn, prev_start_date, prev_end_date)
    finally:
        conn.close()

    return build_report_lines(report_type, start_date, end_date, current, previous)


def main(argv=None):
    args = parse_args(argv)

    try:
        report_text = run_report(args.report, args.start, args.end)
        print(report_text)
    except (ValueError, FileNotFoundError, ConnectionError) as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
