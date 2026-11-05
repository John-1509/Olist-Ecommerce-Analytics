# Olist data quality audit — 2026-11-05

Source: sql/06_data_quality_audit.sql, executed in one read-only repeatable-read transaction. Full results: data_quality_audit_results.txt. No source or staging data was changed.

## Findings

- 99,441 orders; 96,478 delivered. Eight delivered orders have no actual delivery timestamp. No actual delivery precedes purchase. Carrier handoff precedes purchase in 166 orders; actual delivery precedes carrier handoff in 23. These counts may overlap.
- Of 96,470 delivered orders with actual and estimated dates: 88,644 early, 1,292 on the estimated calendar day, 6,534 late (6.77%). Calendar-day actual-minus-estimated ranges from -147 to +188 days. A direct timestamp comparison would incorrectly classify the 1,292 on-day deliveries as late for a calendar-day promise metric.
- 99,224 review rows cover 98,673 orders. 547 orders have multiple reviews (maximum three). No exact duplicate rows or invalid scores. Selecting the latest answer timestamp, then latest creation timestamp, produces no ties in this snapshot. Review IDs alone are not unique.
- 625 canceled orders: 461 have order items and can be linked to sellers; 164 cannot. No canceled order with items spans multiple sellers. Across delivered orders, 1,275 involve multiple sellers. Cancellation status does not establish seller responsibility; returns are not explicitly recorded.
- All item prices are positive; freight is nonnegative; item join keys are populated. There are nine zero-value payment rows, two zero-installment rows, and one delivered order with no payment record.
- For 98,665 orders with both items and payments, 303 have payment-versus-items-plus-freight differences greater than 0.01; maximum absolute difference 182.81. These are flags for investigation, not automatic corrections.
- 610 products lack a category; another 13 have a category without an English translation.
- 1,000,163 geolocation rows cover 19,015 ZIP prefixes. All coordinates satisfy global ranges; 31 fall outside an approximate Brazil bounding box. The box is a screening heuristic, not a country-boundary test.

## Proposed analytics rules

1. Seller sales: rank delivered-order item revenue excluding freight; show units and distinct seller orders separately. This is gross item revenue, not profit or verified net revenue.
2. Cancellation: show counts and rates over distinct seller-linked orders, with a minimum-order threshold before ranking rates. Show the 164 unattributable cancellations separately. Treat unavailable as a separate status. The snapshot does not capture eventual outcomes for open orders.
3. Delivery: use delivered orders with both dates and actual date minus estimated date. Positive is late; zero is on time; negative is early. Report the eight missing actual dates separately. Keep elapsed purchase-to-delivery time as a separate metric.
4. Reviews: retain every staging row; select one latest review per order in an analytics view before joining. Relate lateness to scores as an association, not causation. Report missing review coverage.
5. Aggregate items and payments separately before joining orders. Never join raw one-to-many item, payment, and review rows together for sums. Do not directly join full geolocation to orders by ZIP; aggregate to one row per ZIP first if needed.

## Next work

Inspect payment discrepancies and date-sequence exceptions before using affected fields. Then implement analytics views and validation queries using the documented metric rules. Do not delete anomalies without a recorded decision.
