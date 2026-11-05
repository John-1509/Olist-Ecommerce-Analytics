
import csv
from pathlib import Path

DATA_DIR = Path("data/raw")

tests = {
    "olist_customers_dataset.csv": [
        ("customer_id",),
        ("customer_unique_id",),
    ],
    "olist_orders_dataset.csv": [
        ("order_id",),
        ("customer_id",),
    ],
    "olist_order_items_dataset.csv": [
        ("order_id",),
        ("order_item_id",),
        ("order_id", "order_item_id"),
    ],
    "olist_order_payments_dataset.csv": [
        ("order_id",),
        ("order_id", "payment_sequential"),
    ],
    "olist_order_reviews_dataset.csv": [
        ("review_id",),
        ("order_id",),
    ],
    "olist_products_dataset.csv": [
        ("product_id",),
    ],
    "olist_sellers_dataset.csv": [
        ("seller_id",),
    ],
    "olist_geolocation_dataset.csv": [
        ("geolocation_zip_code_prefix",),
        ("geolocation_lat", "geolocation_lng"),
    ],
    "product_category_name_translation.csv": [
        ("product_category_name",),
        ("product_category_name_english",),
    ],
}

for filename, candidates in tests.items():
    print(f"\n{'=' * 65}")
    print(filename)

    with open(DATA_DIR / filename, encoding="utf-8-sig", newline="") as f:
        rows = list(csv.DictReader(f))

    for columns in candidates:
        values = [
            tuple(row[c] for c in columns)
            for row in rows
        ]

        unique_count = len(set(values))
        null_count = sum(
            any(value == "" for value in key)
            for key in values
        )

        print(
            f"{columns}: "
            f"{unique_count}/{len(values)} unique, "
            f"{null_count} NULL-containing rows"
        )
