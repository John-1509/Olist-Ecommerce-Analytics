-- Read-only analytics checks. Raises an error if core invariants fail.
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
DO $$
BEGIN
 IF (SELECT count(*) FROM analytics.order_summary)<>(SELECT count(*) FROM staging.orders)
 OR EXISTS(SELECT order_id FROM analytics.order_summary GROUP BY order_id HAVING count(*)>1)
 THEN RAISE EXCEPTION 'Order grain validation failed'; END IF;
 IF (SELECT sum(item_revenue) FROM analytics.order_summary) IS DISTINCT FROM (SELECT sum(price) FROM staging.order_items)
 THEN RAISE EXCEPTION 'Item revenue inflated or lost'; END IF;
 IF (SELECT sum(payment_total) FROM analytics.order_summary) IS DISTINCT FROM (SELECT sum(payment_value) FROM staging.order_payments)
 THEN RAISE EXCEPTION 'Payment total inflated or lost'; END IF;
 IF (SELECT sum(delivered_item_revenue) FROM analytics.seller_performance) IS DISTINCT FROM
 (SELECT sum(i.price) FROM staging.order_items i JOIN staging.orders o USING(order_id) WHERE o.order_status='delivered')
 THEN RAISE EXCEPTION 'Seller revenue reconciliation failed'; END IF;
 IF (SELECT sum(delivered_units) FROM analytics.seller_performance)<>(SELECT count(*) FROM staging.order_items i JOIN staging.orders o USING(order_id) WHERE o.order_status='delivered')
 THEN RAISE EXCEPTION 'Seller units reconciliation failed'; END IF;
 IF (SELECT sum(canceled_orders) FROM analytics.seller_performance)<>(SELECT count(*) FROM (SELECT DISTINCT i.seller_id,i.order_id FROM staging.order_items i JOIN staging.orders o USING(order_id) WHERE o.order_status='canceled') c)
 THEN RAISE EXCEPTION 'Seller cancellation reconciliation failed'; END IF;
 IF (SELECT sum(delivered_orders) FROM analytics.delivery_and_reviews)<>(SELECT count(*) FROM staging.orders WHERE order_status='delivered')
 THEN RAISE EXCEPTION 'Delivery summary reconciliation failed'; END IF;
END $$;
SELECT count(*) AS order_rows,sum(item_revenue) AS item_revenue,sum(payment_total) AS payment_total,
 count(*) FILTER(WHERE payment_mismatch) AS payment_mismatches FROM analytics.order_summary;
SELECT * FROM analytics.delivery_and_reviews ORDER BY delivery_result;
SELECT seller_id,delivered_item_revenue,delivered_units,delivered_orders FROM analytics.seller_performance ORDER BY delivered_item_revenue DESC,seller_id LIMIT 5;
SELECT seller_id,total_linked_orders,canceled_orders,round(cancellation_rate_pct,2) AS cancellation_rate_pct
FROM analytics.seller_performance WHERE eligible_for_rate_ranking ORDER BY cancellation_rate_pct DESC,canceled_orders DESC,seller_id LIMIT 5;
COMMIT;
