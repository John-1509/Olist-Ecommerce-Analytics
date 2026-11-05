-- Olist data quality audit. No data is modified.
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;

-- Delivery completeness and sequence. Calendar-day lateness avoids treating
-- delivery during the promised day as late because its estimate is midnight.
SELECT count(*) AS orders,
 count(*) FILTER (WHERE order_status='delivered') AS delivered,
 count(*) FILTER (WHERE order_status='delivered' AND order_delivered_customer_date IS NULL) AS delivered_missing_actual,
 count(*) FILTER (WHERE order_status='delivered' AND order_estimated_delivery_date IS NULL) AS delivered_missing_estimate,
 count(*) FILTER (WHERE order_delivered_customer_date < order_purchase_timestamp) AS actual_before_purchase,
 count(*) FILTER (WHERE order_delivered_carrier_date < order_purchase_timestamp) AS carrier_before_purchase,
 count(*) FILTER (WHERE order_delivered_customer_date < order_delivered_carrier_date) AS actual_before_carrier,
 count(*) FILTER (WHERE order_approved_at < order_purchase_timestamp) AS approved_before_purchase
FROM staging.orders;

SELECT CASE WHEN order_delivered_customer_date::date < order_estimated_delivery_date::date THEN 'early'
 WHEN order_delivered_customer_date::date = order_estimated_delivery_date::date THEN 'on_time'
 ELSE 'late' END AS delivery_result,
 count(*) AS orders,
 min(order_delivered_customer_date::date-order_estimated_delivery_date::date) AS min_days,
 max(order_delivered_customer_date::date-order_estimated_delivery_date::date) AS max_days
FROM staging.orders WHERE order_status='delivered'
 AND order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL
GROUP BY 1 ORDER BY 1;

SELECT count(*) AS delivered_on_estimated_day_with_nonmidnight_time
FROM staging.orders WHERE order_status='delivered'
 AND order_delivered_customer_date::date=order_estimated_delivery_date::date
 AND order_delivered_customer_date>order_estimated_delivery_date;

-- Reviews: row identity, repeated orders, and latest-answer ties.
SELECT count(*) AS reviews,count(DISTINCT review_id) AS distinct_review_ids,
 count(DISTINCT order_id) AS reviewed_orders,
 count(*) FILTER (WHERE review_score IS NULL OR review_score NOT BETWEEN 1 AND 5) AS invalid_scores,
 count(*) FILTER (WHERE review_answer_timestamp < review_creation_date) AS answer_before_creation
FROM staging.order_reviews;
SELECT count(*) AS orders_with_multiple_reviews,max(n) AS max_reviews_per_order
FROM (SELECT order_id,count(*) n FROM staging.order_reviews GROUP BY order_id HAVING count(*)>1) x;
SELECT count(*) AS exact_duplicate_groups,coalesce(sum(n-1),0) AS extra_identical_rows
FROM (SELECT count(*) n FROM staging.order_reviews GROUP BY review_id,order_id,review_score,review_comment_title,review_comment_message,review_creation_date,review_answer_timestamp HAVING count(*)>1) x;
WITH ranked AS (SELECT order_id,review_score,dense_rank() OVER(PARTITION BY order_id ORDER BY review_answer_timestamp DESC NULLS LAST,review_creation_date DESC NULLS LAST) AS position FROM staging.order_reviews)
SELECT count(*) AS orders_with_latest_timestamp_ties,
 count(*) FILTER(WHERE scores>1) AS tied_orders_with_conflicting_scores
FROM (SELECT order_id,count(DISTINCT review_score) scores FROM ranked WHERE position=1 GROUP BY order_id HAVING count(*)>1) x;

-- Seller coverage. Order statuses do not identify a return or seller fault.
WITH items AS (SELECT order_id,count(DISTINCT seller_id) sellers FROM staging.order_items GROUP BY order_id)
SELECT o.order_status,count(*) AS orders,count(*) FILTER(WHERE i.order_id IS NULL) AS without_items,
 count(*) FILTER(WHERE i.sellers>1) AS multi_seller_orders
FROM staging.orders o LEFT JOIN items i USING(order_id) GROUP BY 1 ORDER BY 1;

-- Amounts and count checks. Zero is flagged for interpretation, not deletion.
SELECT count(*) FILTER(WHERE price IS NULL OR price<=0) AS missing_or_nonpositive_price,
 count(*) FILTER(WHERE freight_value IS NULL OR freight_value<0) AS invalid_freight,
 min(price) AS min_price,max(price) AS max_price,max(freight_value) AS max_freight,
 count(*) FILTER(WHERE product_id IS NULL OR seller_id IS NULL OR order_id IS NULL) AS missing_join_keys
FROM staging.order_items;
SELECT count(*) FILTER(WHERE payment_value=0) AS zero_payment_rows,
 count(*) FILTER(WHERE payment_value IS NULL OR payment_value<0) AS invalid_payment_rows,
 count(*) FILTER(WHERE payment_installments=0) AS zero_installment_rows,
 min(payment_value) AS min_payment,max(payment_value) AS max_payment
FROM staging.order_payments;
WITH items AS (SELECT order_id,sum(price+freight_value) total FROM staging.order_items GROUP BY order_id),
 payments AS (SELECT order_id,sum(payment_value) total FROM staging.order_payments GROUP BY order_id)
SELECT count(*) AS orders_with_both,
 count(*) FILTER(WHERE abs(i.total-p.total)>0.01) AS difference_over_one_cent,
 max(abs(i.total-p.total)) AS largest_difference
FROM items i JOIN payments p USING(order_id);
SELECT order_status,count(*) AS orders_without_payments FROM staging.orders o
WHERE NOT EXISTS(SELECT 1 FROM staging.order_payments p WHERE p.order_id=o.order_id)
GROUP BY 1;

-- Category coverage and coordinate sanity.
SELECT count(*) FILTER(WHERE p.product_category_name IS NULL) AS products_without_category,
 count(*) FILTER(WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL) AS products_without_translation
FROM staging.products p LEFT JOIN staging.category_translation t USING(product_category_name);
SELECT count(*) AS geolocation_rows,count(DISTINCT geolocation_zip_code_prefix) AS zip_prefixes,
 count(*) FILTER(WHERE geolocation_lat NOT BETWEEN -90 AND 90 OR geolocation_lng NOT BETWEEN -180 AND 180) AS invalid_global_coordinates,
 count(*) FILTER(WHERE geolocation_lat NOT BETWEEN -34 AND 6 OR geolocation_lng NOT BETWEEN -74 AND -28) AS outside_rough_brazil_box
FROM staging.geolocation;
COMMIT;
