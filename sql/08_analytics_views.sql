-- Additive analytics views; staging remains unchanged.
-- Sales means delivered item revenue excluding freight, not profit/net revenue.
-- Cancellation denominator is all distinct seller-linked orders in this snapshot.
BEGIN;
CREATE VIEW analytics.order_summary AS
WITH items AS (
 SELECT order_id,count(*) AS item_count,count(DISTINCT seller_id) AS seller_count,
 sum(price) AS item_revenue,sum(freight_value) AS freight_total
 FROM staging.order_items GROUP BY order_id
), payments AS (
 SELECT order_id,count(*) AS payment_count,sum(payment_value) AS payment_total
 FROM staging.order_payments GROUP BY order_id
), reviews AS (
 SELECT *,row_number() OVER(PARTITION BY order_id ORDER BY review_answer_timestamp DESC NULLS LAST,
 review_creation_date DESC NULLS LAST,review_id DESC NULLS LAST) AS review_rank,
 count(*) OVER(PARTITION BY order_id) AS review_count
 FROM staging.order_reviews
)
SELECT o.*,coalesce(i.item_count,0) AS item_count,coalesce(i.seller_count,0) AS seller_count,
 i.item_revenue,i.freight_total,coalesce(p.payment_count,0) AS payment_count,p.payment_total,
 p.payment_total-(i.item_revenue+i.freight_total) AS payment_difference,
 CASE WHEN p.order_id IS NULL OR i.order_id IS NULL THEN NULL
 ELSE abs(p.payment_total-i.item_revenue-i.freight_total)>0.01 END AS payment_mismatch,
 r.review_id AS latest_review_id,r.review_score AS latest_review_score,
 r.review_answer_timestamp AS latest_review_answer_timestamp,coalesce(r.review_count,0) AS review_count,
 CASE WHEN o.order_status='delivered' AND o.order_delivered_customer_date IS NOT NULL
 AND o.order_estimated_delivery_date IS NOT NULL
 THEN o.order_delivered_customer_date::date-o.order_estimated_delivery_date::date END AS delivery_delta_days,
 CASE WHEN o.order_status<>'delivered' THEN 'not_delivered'
 WHEN o.order_delivered_customer_date IS NULL OR o.order_estimated_delivery_date IS NULL THEN 'missing_dates'
 WHEN o.order_delivered_customer_date::date<o.order_estimated_delivery_date::date THEN 'early'
 WHEN o.order_delivered_customer_date::date=o.order_estimated_delivery_date::date THEN 'on_time'
 ELSE 'late' END AS delivery_result,
 CASE WHEN o.order_status='delivered' AND o.order_delivered_customer_date>=o.order_purchase_timestamp
 THEN extract(epoch FROM (o.order_delivered_customer_date-o.order_purchase_timestamp))/86400.0 END AS delivery_elapsed_days,
 coalesce(o.order_delivered_carrier_date<o.order_purchase_timestamp,false) AS carrier_before_purchase,
 coalesce(o.order_delivered_customer_date<o.order_delivered_carrier_date,false) AS delivery_before_carrier
FROM staging.orders o LEFT JOIN items i USING(order_id) LEFT JOIN payments p USING(order_id)
LEFT JOIN reviews r ON r.order_id=o.order_id AND r.review_rank=1;

CREATE VIEW analytics.seller_performance AS
WITH seller_orders AS (
 SELECT seller_id,order_id,count(*) AS units,sum(price) AS item_revenue
 FROM staging.order_items GROUP BY seller_id,order_id
)
SELECT s.seller_id,s.seller_city,s.seller_state,
 count(so.order_id) AS total_linked_orders,
 count(*) FILTER(WHERE o.order_status='delivered') AS delivered_orders,
 coalesce(sum(so.units) FILTER(WHERE o.order_status='delivered'),0) AS delivered_units,
 coalesce(sum(so.item_revenue) FILTER(WHERE o.order_status='delivered'),0) AS delivered_item_revenue,
 count(*) FILTER(WHERE o.order_status='canceled') AS canceled_orders,
 count(*) FILTER(WHERE o.order_status='unavailable') AS unavailable_orders,
 count(*) FILTER(WHERE o.order_status NOT IN ('delivered','canceled','unavailable')) AS other_status_orders,
 100.0*count(*) FILTER(WHERE o.order_status='canceled')/nullif(count(so.order_id),0) AS cancellation_rate_pct,
 count(so.order_id)>=30 AS eligible_for_rate_ranking
FROM staging.sellers s LEFT JOIN seller_orders so USING(seller_id)
LEFT JOIN staging.orders o ON o.order_id=so.order_id
GROUP BY s.seller_id,s.seller_city,s.seller_state;

-- Order-weighted association, not a causal claim. Latest review only.
CREATE VIEW analytics.delivery_and_reviews AS
SELECT delivery_result,count(*) AS delivered_orders,
 count(latest_review_score) AS reviewed_orders,
 100.0*count(latest_review_score)/nullif(count(*),0) AS review_coverage_pct,
 avg(latest_review_score) AS average_review_score,
 count(*) FILTER(WHERE latest_review_score IN (1,2)) AS low_review_orders,
 100.0*count(*) FILTER(WHERE latest_review_score IN (1,2))/nullif(count(latest_review_score),0) AS low_review_rate_pct,
 avg(delivery_delta_days) AS average_delivery_delta_days,
 percentile_cont(0.5) WITHIN GROUP(ORDER BY delivery_delta_days) AS median_delivery_delta_days
FROM analytics.order_summary WHERE order_status='delivered' GROUP BY delivery_result;

COMMENT ON VIEW analytics.order_summary IS 'One row per order. Separate item/payment aggregation and latest review prevent join inflation. Calendar-day delivery delta; anomalies retained as flags.';
COMMENT ON VIEW analytics.seller_performance IS 'Delivered item revenue excludes freight. Cancellation rate uses all seller-linked orders; not seller fault or return rate. Ranking eligibility uses a provisional 30-order threshold.';
COMMENT ON VIEW analytics.delivery_and_reviews IS 'Order-weighted delivery/review association. Missing dates are a separate group; latest review only.';
COMMIT;
