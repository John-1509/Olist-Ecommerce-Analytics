
import pandas as pd
from pathlib import Path

DATA_DIR = Path("data/raw")

# 1. Review table
reviews = pd.read_csv(DATA_DIR / "olist_order_reviews_dataset.csv")

print("\n=== REVIEW DUPLICATES ===")

for column in ["review_id", "order_id"]:
    duplicated = reviews[reviews.duplicated(column, keep=False)]

    print(f"\n{column}")
    print("Rows involved:", len(duplicated))
    print("Distinct duplicated values:", duplicated[column].nunique())

    print(
        duplicated.groupby(column)
        .size()
        .sort_values(ascending=False)
        .head(10)
    )

print("\n=== REVIEW ID AND ORDER ID RELATIONSHIPS ===")

print("Distinct review IDs:", reviews["review_id"].nunique())
print("Distinct order IDs:", reviews["order_id"].nunique())

# 2. Geolocation table
geo = pd.read_csv(DATA_DIR / "olist_geolocation_dataset.csv")

print("\n=== GEOLOCATION DUPLICATES ===")

for column in [
    "geolocation_zip_code_prefix",
    ["geolocation_lat", "geolocation_lng"]
]:
    duplicated = geo[geo.duplicated(column, keep=False)]

    print(f"\n{column}")
    print("Rows involved:", len(duplicated))

# 3. Referential integrity
print("\n=== REFERENTIAL INTEGRITY ===")

checks = [
    ("orders", "customer_id", "customers", "customer_id"),
    ("order_items", "order_id", "orders", "order_id"),
    ("order_items", "product_id", "products", "product_id"),
    ("order_items", "seller_id", "sellers", "seller_id"),
    ("order_payments", "order_id", "orders", "order_id"),
    ("order_reviews", "order_id", "orders", "order_id"),
]

for child, child_col, parent, parent_col in checks:
    child_df = pd.read_csv(DATA_DIR / f"olist_{child}_dataset.csv")
    parent_df = pd.read_csv(DATA_DIR / f"olist_{parent}_dataset.csv")

    missing = ~child_df[child_col].isin(parent_df[parent_col])

    print(
        f"{child}.{child_col} -> {parent}.{parent_col}: "
        f"{missing.sum()} unmatched records"
    )

print("\n=== EXAMPLE DUPLICATE REVIEW IDs ===")

duplicate_ids = (
    reviews.loc[
        reviews.duplicated("review_id", keep=False),
        "review_id"
    ].unique()[:3]
)

print(
    reviews[reviews["review_id"].isin(duplicate_ids)]
    .sort_values(["review_id", "review_creation_date"])
    .to_string(index=False)
)

print("\n=== EXAMPLE DUPLICATE ORDER IDs ===")

duplicate_orders = (
    reviews.loc[
        reviews.duplicated("order_id", keep=False),
        "order_id"
    ].unique()[:3]
)

print(
    reviews[reviews["order_id"].isin(duplicate_orders)]
    .sort_values(["order_id", "review_creation_date"])
    .to_string(index=False)
)