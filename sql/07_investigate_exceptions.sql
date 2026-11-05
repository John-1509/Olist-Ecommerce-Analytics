-- Read-only exception investigation; no corrections are inferred from flags.
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
WITH i AS (SELECT order_id,sum(price+freight_value) total FROM staging.order_items GROUP BY 1),
p AS (SELECT order_id,sum(payment_value) total,count(*) payment_rows FROM staging.order_payments GROUP BY 1)
SELECT o.order_status,p.payment_rows,count(*) AS orders,
 count(*) FILTER(WHERE p.total>i.total) AS paid_more,count(*) FILTER(WHERE p.total<i.total) AS paid_less,
 min(p.total-i.total) AS min_difference,max(p.total-i.total) AS max_difference
FROM i JOIN p USING(order_id) JOIN staging.orders o USING(order_id)
WHERE abs(p.total-i.total)>0.01 GROUP BY 1,2 ORDER BY 1,2;
WITH i AS (SELECT order_id,sum(price+freight_value) total FROM staging.order_items GROUP BY 1),
p AS (SELECT order_id,sum(payment_value) total,string_agg(DISTINCT payment_type,', ' ORDER BY payment_type) types FROM staging.order_payments GROUP BY 1)
SELECT o.order_id,o.order_status,i.total AS items_and_freight,p.total AS payments,p.total-i.total AS difference,p.types
FROM i JOIN p USING(order_id) JOIN staging.orders o USING(order_id)
WHERE abs(p.total-i.total)>0.01 ORDER BY abs(p.total-i.total) DESC,o.order_id LIMIT 10;
SELECT order_status,count(*) FILTER(WHERE order_delivered_carrier_date<order_purchase_timestamp) AS carrier_before_purchase,
 count(*) FILTER(WHERE order_delivered_customer_date<order_delivered_carrier_date) AS delivery_before_carrier,
 count(*) FILTER(WHERE order_delivered_carrier_date<order_purchase_timestamp OR order_delivered_customer_date<order_delivered_carrier_date) AS either_flag
FROM staging.orders GROUP BY 1 ORDER BY 1;
SELECT order_id,order_status,order_purchase_timestamp,order_delivered_carrier_date,order_delivered_customer_date,
 order_delivered_carrier_date-order_purchase_timestamp AS purchase_to_carrier,
 order_delivered_customer_date-order_delivered_carrier_date AS carrier_to_delivery
FROM staging.orders WHERE order_delivered_carrier_date<order_purchase_timestamp OR order_delivered_customer_date<order_delivered_carrier_date
ORDER BY order_delivered_customer_date-order_delivered_carrier_date NULLS LAST,order_id LIMIT 10;
SELECT order_id,order_status,order_purchase_timestamp,order_delivered_customer_date
FROM staging.orders o WHERE NOT EXISTS(SELECT 1 FROM staging.order_payments p WHERE p.order_id=o.order_id);
COMMIT;
