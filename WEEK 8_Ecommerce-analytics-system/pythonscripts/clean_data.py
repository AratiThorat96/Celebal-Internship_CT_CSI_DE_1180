"""
clean_data.py
-------------
Cleans and validates the raw CSV files produced by generate_data.py.

Reads from data/raw/ and writes cleaned CSVs to data/cleaned/.
Also writes a full data-quality report to output/validation_report.txt.

Functions:
    clean_orders()
    clean_products()
    validate_emails()
    check_referential_integrity()
    validate_discount()
    validate_quantity()
    generate_validation_report()

Run:
    python scripts/clean_data.py
"""

import re
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
RAW_DIR = PROJECT_ROOT / "data" / "raw"
CLEAN_DIR = PROJECT_ROOT / "data" / "cleaned"
OUTPUT_DIR = PROJECT_ROOT / "output"
CLEAN_DIR.mkdir(parents=True, exist_ok=True)
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

EMAIL_REGEX = re.compile(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")


# ------------------------------------------------------------------
# 1. clean_orders
# ------------------------------------------------------------------
def clean_orders(orders: pd.DataFrame) -> tuple:
    """Clean the orders dataframe.

    - Normalizes order_date into a single datetime format, handling both
      'YYYY-MM-DD HH:MM:SS' and 'DD-MM-YYYY' input formats.
    - Flags rows with a missing/NULL customer_id (kept, but flagged, so
      downstream analysis can decide whether to include guest orders).
    - Flags orders with a future order_date.
    - Drops exact duplicate rows.

    Returns (cleaned_df, stats_dict)
    """
    stats = {}
    df = orders.copy()
    stats["raw_count"] = len(df)

    # --- duplicates -------------------------------------------------
    dup_mask = df.duplicated(keep="first")
    stats["duplicate_orders"] = int(dup_mask.sum())
    df = df[~dup_mask].copy()

    # --- missing customer_id ----------------------------------------
    df["customer_id"] = df["customer_id"].replace("", pd.NA)
    stats["missing_customer_id"] = int(df["customer_id"].isna().sum())

    # --- normalize order_date ----------------------------------------
    def parse_date(value):
        value = str(value).strip()
        # Try the standard format first
        for fmt in ("%Y-%m-%d %H:%M:%S", "%d-%m-%Y"):
            try:
                return pd.to_datetime(value, format=fmt)
            except (ValueError, TypeError):
                continue
        # Fallback: let pandas try to infer it
        return pd.to_datetime(value, errors="coerce")

    df["order_date_parsed"] = df["order_date"].apply(parse_date)
    invalid_dates_mask = df["order_date_parsed"].isna()
    stats["unparseable_dates"] = int(invalid_dates_mask.sum())

    # Drop rows where the date genuinely could not be parsed at all
    df = df[~invalid_dates_mask].copy()
    df["order_date"] = df["order_date_parsed"]
    df.drop(columns=["order_date_parsed"], inplace=True)

    # --- future dates --------------------------------------------------
    now = pd.Timestamp.now()
    future_mask = df["order_date"] > now
    stats["future_dates"] = int(future_mask.sum())
    df["is_future_date"] = future_mask

    # Standardize final date string format
    df["order_date"] = df["order_date"].dt.strftime("%Y-%m-%d %H:%M:%S")

    stats["cleaned_count"] = len(df)
    return df, stats


# ------------------------------------------------------------------
# 2. clean_products
# ------------------------------------------------------------------
def clean_products(products: pd.DataFrame) -> tuple:
    """Clean the products dataframe.

    - Trims leading/trailing whitespace from product_name.
    - Converts product_name to Title Case for consistency.
    - Drops duplicate products (same normalized name + category).
    """
    stats = {}
    df = products.copy()
    stats["raw_count"] = len(df)

    df["product_name"] = df["product_name"].astype(str).str.strip()
    df["product_name"] = df["product_name"].str.title()

    dup_mask = df.duplicated(subset=["product_name", "category"], keep="first")
    stats["duplicate_products"] = int(dup_mask.sum())
    df = df[~dup_mask].copy()

    stats["cleaned_count"] = len(df)
    return df, stats


# ------------------------------------------------------------------
# 3. validate_emails
# ------------------------------------------------------------------
def validate_emails(customers: pd.DataFrame) -> list:
    """Return a list of customer_ids whose email address is invalid."""
    invalid_ids = []
    for _, row in customers.iterrows():
        email = str(row["email"]).strip()
        if not EMAIL_REGEX.match(email):
            invalid_ids.append(row["customer_id"])
    return invalid_ids


# ------------------------------------------------------------------
# 4. check_referential_integrity
# ------------------------------------------------------------------
def check_referential_integrity(order_items: pd.DataFrame, orders: pd.DataFrame, products: pd.DataFrame) -> dict:
    """Check that order_items.order_id exists in orders.order_id and that
    order_items.product_id exists in products.product_id.

    Returns a dict with the invalid order_item_ids for each check.
    """
    valid_order_ids = set(orders["order_id"])
    valid_product_ids = set(products["product_id"])

    invalid_order_refs = order_items.loc[
        ~order_items["order_id"].isin(valid_order_ids), "order_item_id"
    ].tolist()

    invalid_product_refs = order_items.loc[
        ~order_items["product_id"].isin(valid_product_ids), "order_item_id"
    ].tolist()

    return {
        "invalid_order_refs": invalid_order_refs,
        "invalid_product_refs": invalid_product_refs,
    }


# ------------------------------------------------------------------
# 5. validate_discount
# ------------------------------------------------------------------
def validate_discount(order_items: pd.DataFrame) -> list:
    """Return order_item_ids where discount_percent is outside [0, 100]."""
    bad_mask = (order_items["discount_percent"] < 0) | (order_items["discount_percent"] > 100)
    return order_items.loc[bad_mask, "order_item_id"].tolist()


# ------------------------------------------------------------------
# 6. validate_quantity
# ------------------------------------------------------------------
def validate_quantity(order_items: pd.DataFrame) -> dict:
    """Identify zero and negative quantity rows.

    Negative quantity is treated as a RETURN (valid business data, not an
    error) and is kept in the cleaned dataset. Zero quantity is flagged as
    a genuine data issue since it represents no real transaction.
    """
    zero_ids = order_items.loc[order_items["quantity"] == 0, "order_item_id"].tolist()
    negative_ids = order_items.loc[order_items["quantity"] < 0, "order_item_id"].tolist()
    return {"zero_quantity_ids": zero_ids, "negative_quantity_ids": negative_ids}


# ------------------------------------------------------------------
# clean_order_items (helper, ties everything together for that table)
# ------------------------------------------------------------------
def clean_order_items(order_items: pd.DataFrame, orders: pd.DataFrame, products: pd.DataFrame) -> tuple:
    """Clean order_items:
    - Removes rows referencing a non-existent order_id or product_id
      (these are unrecoverable - we cannot analyze an item with no parent
      order or no product).
    - Removes zero-quantity rows (no real transaction happened).
    - KEEPS negative quantity rows because they represent legitimate
      returns; they are flagged instead of deleted.
    - Clamps/flags out-of-range discount_percent values.
    """
    stats = {}
    df = order_items.copy()
    stats["raw_count"] = len(df)

    ref_check = check_referential_integrity(df, orders, products)
    stats["invalid_order_refs"] = len(ref_check["invalid_order_refs"])
    stats["invalid_product_refs"] = len(ref_check["invalid_product_refs"])

    bad_ids = set(ref_check["invalid_order_refs"]) | set(ref_check["invalid_product_refs"])
    df = df[~df["order_item_id"].isin(bad_ids)].copy()

    qty_check = validate_quantity(df)
    stats["zero_quantity_removed"] = len(qty_check["zero_quantity_ids"])
    stats["negative_quantity_flagged"] = len(qty_check["negative_quantity_ids"])
    df = df[df["quantity"] != 0].copy()

    df["is_return"] = df["quantity"] < 0

    discount_bad_ids = validate_discount(df)
    stats["invalid_discount_count"] = len(discount_bad_ids)
    df["discount_valid"] = ~df["order_item_id"].isin(discount_bad_ids)
    # Clip invalid discounts into a sane range but keep the flag for reporting
    df["discount_percent"] = df["discount_percent"].clip(lower=0, upper=100)

    stats["cleaned_count"] = len(df)
    return df, stats


# ------------------------------------------------------------------
# 7. generate_validation_report
# ------------------------------------------------------------------
def generate_validation_report(all_stats: dict, invalid_emails: list, report_path: Path) -> None:
    lines = []
    lines.append("=" * 60)
    lines.append("E-COMMERCE ANALYTICS SYSTEM - DATA VALIDATION REPORT")
    lines.append("=" * 60)
    lines.append("")

    lines.append("--- CUSTOMERS ---")
    lines.append(f"Raw records:            {all_stats['customers']['raw_count']}")
    lines.append(f"Cleaned records:        {all_stats['customers']['cleaned_count']}")
    lines.append(f"Duplicate customers:    {all_stats['customers']['duplicate_customers']}")
    lines.append(f"Invalid emails found:   {len(invalid_emails)}")
    lines.append(f"Invalid email customer_ids: {invalid_emails}")
    lines.append("")

    lines.append("--- PRODUCTS ---")
    lines.append(f"Raw records:            {all_stats['products']['raw_count']}")
    lines.append(f"Cleaned records:        {all_stats['products']['cleaned_count']}")
    lines.append(f"Duplicate products removed: {all_stats['products']['duplicate_products']}")
    lines.append("")

    lines.append("--- ORDERS ---")
    lines.append(f"Raw records:            {all_stats['orders']['raw_count']}")
    lines.append(f"Cleaned records:        {all_stats['orders']['cleaned_count']}")
    lines.append(f"Duplicate orders removed: {all_stats['orders']['duplicate_orders']}")
    lines.append(f"Missing customer_id (flagged, kept): {all_stats['orders']['missing_customer_id']}")
    lines.append(f"Unparseable dates (rows dropped): {all_stats['orders']['unparseable_dates']}")
    lines.append(f"Future-dated orders (flagged, kept): {all_stats['orders']['future_dates']}")
    lines.append("")

    lines.append("--- ORDER ITEMS ---")
    lines.append(f"Raw records:            {all_stats['order_items']['raw_count']}")
    lines.append(f"Cleaned records:        {all_stats['order_items']['cleaned_count']}")
    lines.append(f"Invalid order_id references (rows removed): {all_stats['order_items']['invalid_order_refs']}")
    lines.append(f"Invalid product_id references (rows removed): {all_stats['order_items']['invalid_product_refs']}")
    lines.append(f"Zero quantity rows removed: {all_stats['order_items']['zero_quantity_removed']}")
    lines.append(f"Negative quantity rows flagged as returns (kept): {all_stats['order_items']['negative_quantity_flagged']}")
    lines.append(f"Invalid discount_percent values (>100 or <0), clipped and flagged: {all_stats['order_items']['invalid_discount_count']}")
    lines.append("")

    lines.append("--- CLEANING ACTIONS PERFORMED ---")
    lines.append("1. Removed exact duplicate order rows.")
    lines.append("2. Removed duplicate product rows (same name + category).")
    lines.append("3. Normalized order_date from mixed formats (YYYY-MM-DD HH:MM:SS")
    lines.append("   and DD-MM-YYYY) into a single consistent datetime format.")
    lines.append("4. Flagged (not deleted) orders with missing customer_id so guest")
    lines.append("   orders remain available for order-level analysis.")
    lines.append("5. Flagged (not deleted) future-dated orders for review.")
    lines.append("6. Trimmed whitespace and applied Title Case to product names.")
    lines.append("7. Removed order_items rows with invalid order_id or product_id")
    lines.append("   references (true orphan/corrupt records).")
    lines.append("8. Removed zero-quantity order_items (no real transaction).")
    lines.append("9. KEPT negative-quantity rows and flagged them as returns")
    lines.append("   (is_return = True) rather than deleting real business data.")
    lines.append("10. Clipped out-of-range discount_percent values to [0, 100] and")
    lines.append("    flagged the affected rows (discount_valid = False).")
    lines.append("")
    lines.append("=" * 60)
    lines.append("END OF REPORT")
    lines.append("=" * 60)

    report_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"Validation report written -> {report_path.relative_to(PROJECT_ROOT)}")


def main():
    print("Loading raw data...")
    customers = pd.read_csv(RAW_DIR / "customers.csv", dtype={"customer_id": "Int64"})
    products = pd.read_csv(RAW_DIR / "products.csv")
    orders = pd.read_csv(RAW_DIR / "orders.csv", dtype={"customer_id": "Int64"})
    order_items = pd.read_csv(RAW_DIR / "order_items.csv")

    all_stats = {}

    print("Cleaning customers...")
    customers_clean = customers.copy()
    all_stats["customers"] = {"raw_count": len(customers)}
    dup_mask = customers_clean.duplicated(subset=["customer_name", "email"], keep="first")
    all_stats["customers"]["duplicate_customers"] = int(dup_mask.sum())
    # We keep duplicate customer rows (they have distinct customer_ids that
    # may already be referenced by orders) but flag them for reporting.
    customers_clean["is_duplicate"] = dup_mask
    all_stats["customers"]["cleaned_count"] = len(customers_clean)

    invalid_emails = validate_emails(customers_clean)

    print("Cleaning products...")
    products_clean, products_stats = clean_products(products)
    all_stats["products"] = products_stats

    print("Cleaning orders...")
    orders_clean, orders_stats = clean_orders(orders)
    all_stats["orders"] = orders_stats

    print("Cleaning order_items...")
    order_items_clean, order_items_stats = clean_order_items(order_items, orders_clean, products_clean)
    all_stats["order_items"] = order_items_stats

    # Save cleaned CSVs
    customers_clean.to_csv(CLEAN_DIR / "customers_clean.csv", index=False)
    products_clean.to_csv(CLEAN_DIR / "products_clean.csv", index=False)
    orders_clean.to_csv(CLEAN_DIR / "orders_clean.csv", index=False)
    order_items_clean.to_csv(CLEAN_DIR / "order_items_clean.csv", index=False)
    print("\nCleaned CSVs written to data/cleaned/")

    generate_validation_report(all_stats, invalid_emails, OUTPUT_DIR / "validation_report.txt")

    print("\nData cleaning complete.")


if __name__ == "__main__":
    main()
