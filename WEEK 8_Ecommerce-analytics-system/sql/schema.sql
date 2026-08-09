-- ============================================================
-- schema.sql
-- E-Commerce Order Analytics System - Database Schema
-- ============================================================
-- This schema defines the four core tables used by the analytics
-- system, with PRIMARY KEY, FOREIGN KEY, NOT NULL, and CHECK
-- constraints applied where appropriate.
--
-- Note: order_items.order_id does NOT have a hard FOREIGN KEY
-- constraint enforced at the SQLite engine level for this specific
-- load, because the cleaned dataset can intentionally still contain
-- a few flagged edge-case rows used for testing the CLI/validation
-- logic. load_database.py enforces referential integrity in Python
-- BEFORE insertion and reports exactly what it finds/rejects, which
-- is more transparent for an analytics project than a silent DB-level
-- rejection. The FOREIGN KEY constraints ARE still declared below so
-- the intended relational design is documented and can be turned on
-- (PRAGMA foreign_keys = ON) for stricter environments.
-- ============================================================

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id        INTEGER PRIMARY KEY,
    customer_name       TEXT NOT NULL,
    email               TEXT NOT NULL,
    registration_date   TEXT NOT NULL,
    customer_type       TEXT NOT NULL CHECK (customer_type IN ('REGULAR', 'PREMIUM', 'VIP')),
    is_duplicate        INTEGER DEFAULT 0
);

CREATE TABLE products (
    product_id      INTEGER PRIMARY KEY,
    product_name    TEXT NOT NULL,
    category        TEXT NOT NULL,
    subcategory     TEXT,
    cost_price      REAL NOT NULL CHECK (cost_price >= 0)
);

CREATE TABLE orders (
    order_id        INTEGER PRIMARY KEY,
    customer_id     INTEGER,
    order_date      TEXT NOT NULL,
    status          TEXT NOT NULL CHECK (status IN ('PLACED','SHIPPED','DELIVERED','CANCELLED','RETURNED')),
    region_code     TEXT NOT NULL,
    is_future_date  INTEGER DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id     INTEGER PRIMARY KEY,
    order_id          INTEGER NOT NULL,
    product_id        INTEGER NOT NULL,
    quantity          INTEGER NOT NULL CHECK (quantity != 0),
    unit_price        REAL NOT NULL CHECK (unit_price >= 0),
    discount_percent  REAL NOT NULL CHECK (discount_percent >= 0 AND discount_percent <= 100),
    is_return         INTEGER DEFAULT 0,
    discount_valid    INTEGER DEFAULT 1,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category);
