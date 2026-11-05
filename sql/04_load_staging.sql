-- Reconstructed reproduction script. Run once on empty staging tables.

BEGIN;

INSERT INTO staging.customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_state, customer_city)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_state,
    customer_city
FROM raw.customers;

INSERT INTO staging.orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp::timestamp without time zone,
    order_approved_at::timestamp without time zone,
    order_delivered_carrier_date::timestamp without time zone,
    order_delivered_customer_date::timestamp without time zone,
    order_estimated_delivery_date::timestamp without time zone
FROM raw.orders;

INSERT INTO staging.products (product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
SELECT
    product_id,
    product_category_name,
    product_name_lenght::integer,
    product_description_lenght::integer,
    product_photos_qty::integer,
    product_weight_g::integer,
    product_length_cm::numeric,
    product_height_cm::numeric,
    product_width_cm::numeric
FROM raw.products;

INSERT INTO staging.sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM raw.sellers;

INSERT INTO staging.order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
SELECT
    order_id,
    order_item_id::integer,
    product_id,
    seller_id,
    shipping_limit_date::timestamp without time zone,
    price::numeric,
    freight_value::numeric
FROM raw.order_items;

INSERT INTO staging.order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
SELECT
    order_id,
    payment_sequential::integer,
    payment_type,
    payment_installments::integer,
    payment_value::numeric
FROM raw.order_payments;

INSERT INTO staging.order_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
SELECT
    review_id,
    order_id,
    review_score::integer,
    review_comment_title,
    review_comment_message,
    review_creation_date::timestamp without time zone,
    review_answer_timestamp::timestamp without time zone
FROM raw.order_reviews;

INSERT INTO staging.category_translation (product_category_name, product_category_name_english)
SELECT
    product_category_name,
    product_category_name_english
FROM raw.category_translation;

INSERT INTO staging.geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat::numeric,
    geolocation_lng::numeric,
    geolocation_city,
    geolocation_state
FROM raw.geolocation;

COMMIT;
