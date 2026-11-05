-- Read-only: counts should match and unmatched relationships should be zero.

SELECT 'customers' AS table_name, (SELECT count(*) FROM raw.customers) AS raw_rows, (SELECT count(*) FROM staging.customers) AS staging_rows
UNION ALL
SELECT 'orders' AS table_name, (SELECT count(*) FROM raw.orders) AS raw_rows, (SELECT count(*) FROM staging.orders) AS staging_rows
UNION ALL
SELECT 'products' AS table_name, (SELECT count(*) FROM raw.products) AS raw_rows, (SELECT count(*) FROM staging.products) AS staging_rows
UNION ALL
SELECT 'sellers' AS table_name, (SELECT count(*) FROM raw.sellers) AS raw_rows, (SELECT count(*) FROM staging.sellers) AS staging_rows
UNION ALL
SELECT 'order_items' AS table_name, (SELECT count(*) FROM raw.order_items) AS raw_rows, (SELECT count(*) FROM staging.order_items) AS staging_rows
UNION ALL
SELECT 'order_payments' AS table_name, (SELECT count(*) FROM raw.order_payments) AS raw_rows, (SELECT count(*) FROM staging.order_payments) AS staging_rows
UNION ALL
SELECT 'order_reviews' AS table_name, (SELECT count(*) FROM raw.order_reviews) AS raw_rows, (SELECT count(*) FROM staging.order_reviews) AS staging_rows
UNION ALL
SELECT 'category_translation' AS table_name, (SELECT count(*) FROM raw.category_translation) AS raw_rows, (SELECT count(*) FROM staging.category_translation) AS staging_rows
UNION ALL
SELECT 'geolocation' AS table_name, (SELECT count(*) FROM raw.geolocation) AS raw_rows, (SELECT count(*) FROM staging.geolocation) AS staging_rows

;

SELECT 'orders.customer_id' AS relationship, count(*) AS unmatched FROM staging.orders child WHERE child.customer_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM staging.customers parent WHERE parent.customer_id=child.customer_id);

SELECT 'order_items.order_id' AS relationship, count(*) AS unmatched FROM staging.order_items child WHERE child.order_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM staging.orders parent WHERE parent.order_id=child.order_id);

SELECT 'order_items.product_id' AS relationship, count(*) AS unmatched FROM staging.order_items child WHERE child.product_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM staging.products parent WHERE parent.product_id=child.product_id);

SELECT 'order_items.seller_id' AS relationship, count(*) AS unmatched FROM staging.order_items child WHERE child.seller_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM staging.sellers parent WHERE parent.seller_id=child.seller_id);

SELECT 'order_payments.order_id' AS relationship, count(*) AS unmatched FROM staging.order_payments child WHERE child.order_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM staging.orders parent WHERE parent.order_id=child.order_id);

SELECT 'order_reviews.order_id' AS relationship, count(*) AS unmatched FROM staging.order_reviews child WHERE child.order_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM staging.orders parent WHERE parent.order_id=child.order_id);
