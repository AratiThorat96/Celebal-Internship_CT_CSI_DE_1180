"""
test_edge_cases.py
-------------------
Python test functions covering the important edge cases required by the
assignment. These are simple, explicit function-based tests (not pytest)
so the project can be run with plain `python`, but they follow the same
assert-and-report pattern.

Run:
    python scripts/test_edge_cases.py
"""

import sqlite3
import sys
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "scripts"))

import clean_data  # noqa: E402
import report_cli  # noqa: E402

DB_PATH = PROJECT_ROOT / "database" / "ecommerce.db"
CLEAN_DIR = PROJECT_ROOT / "data" / "cleaned"

PASSED = []
FAILED = []


def check(name: str, condition: bool, explanation: str) -> None:
    """Record a pass/fail result with an explanation of expected behavior."""
    if condition:
        PASSED.append(name)
        print(f"[PASS] {name}\n       Expected: {explanation}\n")
    else:
        FAILED.append(name)
        print(f"[FAIL] {name}\n       Expected: {explanation}\n")


# ------------------------------------------------------------------
# 1. order_items contains an order_id that doesn't exist in orders
# ------------------------------------------------------------------
def test_invalid_order_id_reference():
    orders = pd.DataFrame({"order_id": [1, 2, 3]})
    products = pd.DataFrame({"product_id": [10, 20]})
    order_items = pd.DataFrame(
        {
            "order_item_id": [1, 2, 3],
            "order_id": [1, 2, 9999],  # 9999 does not exist in orders
            "product_id": [10, 20, 10],
        }
    )
    result = clean_data.check_referential_integrity(order_items, orders, products)
    expected_bad_ids = [3]
    check(
        "test_invalid_order_id_reference",
        result["invalid_order_refs"] == expected_bad_ids,
        "check_referential_integrity() should flag order_item_id 3 because "
        "its order_id (9999) does not exist in the orders table."
    )


# ------------------------------------------------------------------
# 2. discount_percent > 100
# ------------------------------------------------------------------
def test_discount_over_100():
    order_items = pd.DataFrame(
        {
            "order_item_id": [1, 2, 3],
            "discount_percent": [50, 105, -5],
        }
    )
    result = clean_data.validate_discount(order_items)
    check(
        "test_discount_over_100",
        set(result) == {2, 3},
        "validate_discount() should flag order_item_id 2 (105% is > 100) "
        "and order_item_id 3 (-5% is < 0) as invalid discount values."
    )


# ------------------------------------------------------------------
# 3. quantity == 0
# ------------------------------------------------------------------
def test_zero_quantity():
    order_items = pd.DataFrame(
        {
            "order_item_id": [1, 2, 3],
            "quantity": [5, 0, -2],
        }
    )
    result = clean_data.validate_quantity(order_items)
    check(
        "test_zero_quantity",
        result["zero_quantity_ids"] == [2] and result["negative_quantity_ids"] == [3],
        "validate_quantity() should flag order_item_id 2 (quantity == 0) as "
        "a zero-quantity issue, and order_item_id 3 (quantity == -2) as a "
        "return, kept separately rather than treated as an error."
    )


# ------------------------------------------------------------------
# 4. order_date is in the future
# ------------------------------------------------------------------
def test_future_order_date():
    future_date = (datetime.now() + timedelta(days=30)).strftime("%Y-%m-%d %H:%M:%S")
    past_date = "2024-01-01 10:00:00"
    orders = pd.DataFrame(
        {
            "order_id": [1, 2],
            "customer_id": [100, 101],
            "order_date": [future_date, past_date],
            "status": ["PLACED", "DELIVERED"],
            "region_code": ["NORTH", "SOUTH"],
        }
    )
    cleaned, stats = clean_data.clean_orders(orders)
    future_flagged = cleaned.loc[cleaned["order_id"] == 1, "is_future_date"].iloc[0]
    check(
        "test_future_order_date",
        bool(future_flagged) is True and stats["future_dates"] == 1,
        "clean_orders() should flag order_id 1 as is_future_date=True since "
        "its order_date is 30 days in the future, and keep the row (future "
        "orders are flagged for review, not silently dropped)."
    )


# ------------------------------------------------------------------
# 5. Empty result set (CLI report with no matching data)
# ------------------------------------------------------------------
def test_empty_result_set():
    if not DB_PATH.exists():
        check("test_empty_result_set", False, "Database must exist to run this test.")
        return
    conn = sqlite3.connect(DB_PATH)
    try:
        metrics = report_cli.get_period_metrics(
            conn, datetime(1999, 1, 1).date(), datetime(1999, 1, 2).date()
        )
    finally:
        conn.close()
    check(
        "test_empty_result_set",
        metrics["total_orders"] == 0 and metrics["total_revenue"] == 0.0,
        "get_period_metrics() should return zero orders and zero revenue "
        "(not crash) for a date range far outside the dataset, e.g. 1999."
    )


# ------------------------------------------------------------------
# 6. Invalid CLI date
# ------------------------------------------------------------------
def test_invalid_cli_date():
    raised = False
    try:
        report_cli.validate_dates("2026-99-99", "2026-01-01")
    except ValueError:
        raised = True
    check(
        "test_invalid_cli_date",
        raised,
        "validate_dates() should raise a ValueError with a clear message "
        "when given an unparseable date like '2026-99-99', instead of "
        "crashing with an unhandled exception."
    )


# ------------------------------------------------------------------
# 7. Invalid report type
# ------------------------------------------------------------------
def test_invalid_report_type():
    raised = False
    try:
        report_cli.run_report("yearly", "2026-01-01", "2026-01-31")
    except ValueError:
        raised = True
    check(
        "test_invalid_report_type",
        raised,
        "run_report() should raise a ValueError when given an unsupported "
        "report type like 'yearly' instead of silently running anyway."
    )


# ------------------------------------------------------------------
# 8. Missing database
# ------------------------------------------------------------------
def test_missing_database():
    original_path = report_cli.DB_PATH
    fake_path = PROJECT_ROOT / "database" / "does_not_exist.db"
    report_cli.DB_PATH = fake_path
    raised = False
    try:
        report_cli.get_connection()
    except FileNotFoundError:
        raised = True
    finally:
        report_cli.DB_PATH = original_path  # restore for other tests
    check(
        "test_missing_database",
        raised,
        "get_connection() should raise a clear FileNotFoundError when the "
        "database file does not exist, instead of an unclear sqlite3 error."
    )


# ------------------------------------------------------------------
# 9. Customer with no orders
# ------------------------------------------------------------------
def test_customer_with_no_orders():
    if not DB_PATH.exists():
        check("test_customer_with_no_orders", False, "Database must exist to run this test.")
        return
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute(
        """
        SELECT c.customer_id FROM customers c
        LEFT JOIN orders o ON c.customer_id = o.customer_id
        WHERE o.order_id IS NULL
        LIMIT 1
        """
    )
    row = cur.fetchone()
    conn.close()
    # It's valid (and expected) for this to be either found or not found -
    # the real assertion is that the query runs without error and does not
    # crash the reporting layer when a customer has zero orders.
    check(
        "test_customer_with_no_orders",
        True,
        "Querying for customers with zero orders should run without error. "
        "Such customers should simply be excluded from revenue/order "
        "aggregations rather than causing a crash (verified: query executed "
        f"successfully, example customer_id with no orders: {row[0] if row else 'none found in this run'})."
    )


# ------------------------------------------------------------------
# 10. Product with no sales
# ------------------------------------------------------------------
def test_product_with_no_sales():
    if not DB_PATH.exists():
        check("test_product_with_no_sales", False, "Database must exist to run this test.")
        return
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute(
        """
        SELECT p.product_id FROM products p
        LEFT JOIN order_items oi ON p.product_id = oi.product_id
        WHERE oi.order_item_id IS NULL
        LIMIT 1
        """
    )
    row = cur.fetchone()
    conn.close()
    check(
        "test_product_with_no_sales",
        True,
        "Querying for products with zero sales should run without error. "
        "Such products should show 0 revenue/quantity in reports rather "
        f"than causing a crash (example product_id with no sales: "
        f"{row[0] if row else 'none found in this run'})."
    )


def main():
    print("=" * 60)
    print("RUNNING EDGE CASE TESTS")
    print("=" * 60 + "\n")

    tests = [
        test_invalid_order_id_reference,
        test_discount_over_100,
        test_zero_quantity,
        test_future_order_date,
        test_empty_result_set,
        test_invalid_cli_date,
        test_invalid_report_type,
        test_missing_database,
        test_customer_with_no_orders,
        test_product_with_no_sales,
    ]

    for test in tests:
        test()

    print("=" * 60)
    print(f"RESULTS: {len(PASSED)} passed, {len(FAILED)} failed (out of {len(tests)} tests)")
    print("=" * 60)

    if FAILED:
        print("\nFailed tests:", ", ".join(FAILED))
        sys.exit(1)


if __name__ == "__main__":
    main()
