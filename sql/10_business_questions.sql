-- Final business-question queries. Snapshot results; no data changes.
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;

-- Q1: Delivery timing and latest review. Score denominators exclude missing reviews.
SELECT delivery_result,delivered_orders,reviewed_orders,round(review_coverage_pct,2) AS review_coverage_pct,
 round(average_review_score,2) AS average_review_score,round(low_review_rate_pct,2) AS low_review_rate_pct
FROM analytics.delivery_and_reviews
ORDER BY CASE delivery_result WHEN 'early' THEN 1 WHEN 'on_time' THEN 2 WHEN 'late' THEN 3 ELSE 4 END;

-- Q2: Separate rankings: delivered item revenue excludes freight and is not profit.
SELECT seller_id,seller_city,seller_state,delivered_item_revenue,delivered_units,delivered_orders,
 dense_rank() OVER(ORDER BY delivered_item_revenue DESC) AS revenue_rank,
 dense_rank() OVER(ORDER BY delivered_units DESC) AS units_rank,
 dense_rank() OVER(ORDER BY delivered_orders DESC) AS orders_rank
FROM analytics.seller_performance ORDER BY delivered_item_revenue DESC,seller_id LIMIT 10;
SELECT 'units' AS ranking,seller_id,delivered_units,delivered_orders,delivered_item_revenue
FROM analytics.seller_performance ORDER BY delivered_units DESC,seller_id LIMIT 5;
SELECT 'orders' AS ranking,seller_id,delivered_orders,delivered_units,delivered_item_revenue
FROM analytics.seller_performance ORDER BY delivered_orders DESC,seller_id LIMIT 5;
WITH ranked AS (SELECT *,row_number() OVER(ORDER BY delivered_item_revenue DESC,seller_id) AS position FROM analytics.seller_performance)
SELECT sum(delivered_item_revenue) AS delivered_item_revenue,
 round(100.0*sum(delivered_item_revenue) FILTER(WHERE position<=10)/nullif(sum(delivered_item_revenue),0),2) AS top_10_revenue_share_pct
FROM ranked;

-- Q3: Cancellation counts and rates are distinct. Status is order-level, not proof of seller fault.
SELECT seller_id,total_linked_orders,canceled_orders,round(cancellation_rate_pct,2) AS cancellation_rate_pct
FROM analytics.seller_performance WHERE canceled_orders>0
ORDER BY canceled_orders DESC,total_linked_orders DESC,seller_id LIMIT 10;
-- Provisional minimum: 30 linked orders. This is a screening rule, not statistical significance.
SELECT seller_id,total_linked_orders,canceled_orders,round(cancellation_rate_pct,2) AS cancellation_rate_pct
FROM analytics.seller_performance WHERE eligible_for_rate_ranking AND canceled_orders>0
ORDER BY cancellation_rate_pct DESC,canceled_orders DESC,seller_id LIMIT 10;
SELECT count(*) AS canceled_orders,
 count(*) FILTER(WHERE item_count>0) AS seller_attributable,
 count(*) FILTER(WHERE item_count=0) AS unattributable,
 round(100.0*count(*) FILTER(WHERE item_count>0)/nullif(count(*),0),2) AS seller_coverage_pct
FROM analytics.order_summary WHERE order_status='canceled';

-- Q4: Actual minus estimated calendar date. Positive late, negative early.
SELECT delivery_result,count(*) AS orders,
 round(100.0*count(*)/sum(count(*)) FILTER(WHERE delivery_result<>'missing_dates') OVER(),2) AS pct_of_usable_deliveries,
 round(avg(delivery_delta_days),2) AS average_days,
 percentile_cont(0.5) WITHIN GROUP(ORDER BY delivery_delta_days) AS median_days,
 min(delivery_delta_days) AS min_days,max(delivery_delta_days) AS max_days
FROM analytics.order_summary WHERE order_status='delivered' AND delivery_result<>'missing_dates'
GROUP BY delivery_result ORDER BY CASE delivery_result WHEN 'early' THEN 1 WHEN 'on_time' THEN 2 ELSE 3 END;
SELECT count(*) AS delivered_orders,count(delivery_delta_days) AS usable_delivery_dates,
 count(*) FILTER(WHERE delivery_result='missing_dates') AS missing_delivery_dates,
 round(avg(delivery_delta_days),2) AS overall_average_delta_days,
 percentile_cont(0.5) WITHIN GROUP(ORDER BY delivery_delta_days) AS overall_median_delta_days
FROM analytics.order_summary WHERE order_status='delivered';
COMMIT;
