"""
load_database.py
-----------------
Creates the SQLite database (database/ecommerce.db) from sql/schema.sql
and loads the cleaned CSV files from data/cleaned/ into it.

Because the cleaned dataset may still intentionally contain a few
edge-case records (e.g. flagged future dates, flagged invalid discounts),
this loader validates referential integrity in Python BEFORE inserting
order_items, and reports exactly which rows are rejected and why instead
of silently failing or silently letting bad data in.

Run:
    python scripts/load_database.py
"""

import sqlite3
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
CLEAN_DIR = PROJECT_ROOT / "data" / "cleaned"
DB_DIR = PROJECT_ROOT / "database"
SQL_DIR = PROJECT_ROOT / "sql"
DB_DIR.mkdir(parents=True, exist_ok=True)

DB_PATH = DB_DIR / "ecommerce.db"
SCHEMA_PATH = SQL_DIR / "schema.sql"


def create_schema(conn: sqlite3.Connection) -> None:
    """Execute schema.sql to (re)create all tables from scratch."""
    schema_sql = SCHEMA_PATH.read_text(encoding="utf-8")
    conn.executescript(schema_sql)
    conn.commit()
    print("Schema created from sql/schema.sql")


def load_customers(conn: sqlite3.Connection) -> pd.DataFrame:
    df = pd.read_csv(CLEAN_DIR / "customers_clean.csv")
    df["is_duplicate"] = df["is_duplicate"].astype(int)
    df.to_sql("customers", conn, if_exists="append", index=False)
    print(f"Loaded customers: {len(df)} rows")
    return df


def load_products(conn: sqlite3.Connection) -> pd.DataFrame:
    df = pd.read_csv(CLEAN_DIR / "products_clean.csv")
    df.to_sql("products", conn, if_exists="append", index=False)
    print(f"Loaded products: {len(df)} rows")
    return df


def load_orders(conn: sqlite3.Connection, valid_customer_ids: set) -> pd.DataFrame:
    df = pd.read_csv(CLEAN_DIR / "orders_clean.csv")
    df["is_future_date"] = df["is_future_date"].astype(int)

    # customer_id may be NaN (missing) - SQLite allows NULL in a nullable
    # FOREIGN KEY column, so we keep those rows but report the count.
    missing_customer_mask = df["customer_id"].isna()
    print(f"  -> orders with missing customer_id (loaded as NULL): {int(missing_customer_mask.sum())}")

    # Orders that reference a customer_id which doesn't exist at all
    # (not just missing, but genuinely invalid) would break the FK
    # relationship - check and report, though our generator does not
    # intentionally create this case beyond the missing-value case.
    present_ids = df.loc[~missing_customer_mask, "customer_id"].astype(int)
    orphan_customer_orders = present_ids[~present_ids.isin(valid_customer_ids)]
    if len(orphan_customer_orders) > 0:
        print(f"  -> WARNING: {len(orphan_customer_orders)} orders reference a customer_id "
              f"that does not exist in customers. These rows will still be loaded with a "
              f"dangling reference for transparency (SQLite FK enforcement is not strict here).")

    df.to_sql("orders", conn, if_exists="append", index=False)
    print(f"Loaded orders: {len(df)} rows")
    return df


def load_order_items(conn: sqlite3.Connection, valid_order_ids: set, valid_product_ids: set) -> pd.DataFrame:
    df = pd.read_csv(CLEAN_DIR / "order_items_clean.csv")
    df["is_return"] = df["is_return"].astype(int)
    df["discount_valid"] = df["discount_valid"].astype(int)

    # Defensive re-check: even though clean_data.py already removed orphan
    # rows, we verify again here before insertion and report explicitly,
    # rather than trusting the upstream step silently.
    bad_order_ref = ~df["order_id"].isin(valid_order_ids)
    bad_product_ref = ~df["product_id"].isin(valid_product_ids)
    rejected = df[bad_order_ref | bad_product_ref]

    if len(rejected) > 0:
        print(f"  -> REJECTED {len(rejected)} order_items rows at load time due to "
              f"broken order_id/product_id references (order_item_ids: "
              f"{rejected['order_item_id'].tolist()[:10]}{'...' if len(rejected) > 10 else ''})")
        df = df[~(bad_order_ref | bad_product_ref)].copy()
    else:
        print("  -> No broken references found in order_items at load time.")

    df.to_sql("order_items", conn, if_exists="append", index=False)
    print(f"Loaded order_items: {len(df)} rows")
    return df


def print_summary(conn: sqlite3.Connection) -> None:
    print("\n" + "=" * 55)
    print("DATABASE LOAD SUMMARY")
    print("=" * 55)

    cursor = conn.cursor()
    tables = ["customers", "products", "orders", "order_items"]
    for table in tables:
        count = cursor.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        print(f"  {table:<15} -> {count:,} rows")

    print("\nRELATIONSHIP VALIDATION")
    print("-" * 55)

    orphan_order_items_order = cursor.execute(
        """
        SELECT COUNT(*) FROM order_items oi
        LEFT JOIN orders o ON oi.order_id = o.order_id
        WHERE o.order_id IS NULL
        """
    ).fetchone()[0]
    print(f"  order_items with no matching order:   {orphan_order_items_order}")

    orphan_order_items_product = cursor.execute(
        """
        SELECT COUNT(*) FROM order_items oi
        LEFT JOIN products p ON oi.product_id = p.product_id
        WHERE p.product_id IS NULL
        """
    ).fetchone()[0]
    print(f"  order_items with no matching product: {orphan_order_items_product}")

    orphan_orders_customer = cursor.execute(
        """
        SELECT COUNT(*) FROM orders o
        LEFT JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.customer_id IS NOT NULL AND c.customer_id IS NULL
        """
    ).fetchone()[0]
    print(f"  orders with invalid (non-null) customer reference: {orphan_orders_customer}")

    null_customer_orders = cursor.execute(
        "SELECT COUNT(*) FROM orders WHERE customer_id IS NULL"
    ).fetchone()[0]
    print(f"  orders with NULL customer_id (guest/unknown):       {null_customer_orders}")

    print("=" * 55)


def main():
    if DB_PATH.exists():
        DB_PATH.unlink()  # start fresh each run for reproducibility

    conn = sqlite3.connect(DB_PATH)
    try:
        create_schema(conn)

        customers_df = load_customers(conn)
        products_df = load_products(conn)

        valid_customer_ids = set(customers_df["customer_id"])
        orders_df = load_orders(conn, valid_customer_ids)

        valid_order_ids = set(orders_df["order_id"])
        valid_product_ids = set(products_df["product_id"])
        load_order_items(conn, valid_order_ids, valid_product_ids)

        conn.commit()
        print_summary(conn)
        print(f"\nDatabase created at: {DB_PATH.relative_to(PROJECT_ROOT)}")

    except sqlite3.Error as e:
        print(f"SQLite error occurred: {e}")
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
