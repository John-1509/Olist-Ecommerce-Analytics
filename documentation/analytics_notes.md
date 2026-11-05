# Analytics views and exception decisions — 2026-11-05

## Exception investigation

303 orders differ between total payments and item prices plus freight by more than 0.01: 299 delivered, two canceled, two shipped. Of the delivered exceptions, 282 have one payment row and 17 have two. Differences are not explained merely by one-to-many joins: both sources were aggregated independently. The largest absolute difference is 182.81. The dataset alone does not establish why these amounts differ; do not invent discounts, refunds, or rounding explanations.

166 orders show carrier handoff before purchase (165 delivered, one shipped). Another 23 delivered orders show customer delivery before carrier handoff; counts can overlap. No actual customer delivery precedes purchase. Retain source timestamps and expose flags. Do not use flagged carrier sequences for carrier transit-time conclusions without further review.

Decision: retain all records. Seller sales uses delivered item prices, not payments, so payment mismatches do not change that metric. Delivery-versus-estimate uses actual and estimated calendar dates, not carrier timestamps. Missing dates remain a separate group. Do not substitute missing payments with zero revenue.

## Views

- analytics.order_summary: one row per order, separately aggregated items/payments, latest review, delivery delta, elapsed delivery days, and exception flags. Item revenue includes all statuses here; filter delivered for sales.
- analytics.seller_performance: all sellers, delivered item revenue excluding freight, delivered units/orders, canceled/unavailable/other-status counts, and cancellation rate over all distinct seller-linked orders. A provisional 30-linked-order threshold marks eligibility for rate ranking. Seller orders across multiple sellers must not be summed as unique marketplace orders. Cancellations do not establish seller fault, and 164 canceled orders lack seller attribution.
- analytics.delivery_and_reviews: delivered orders grouped as early/on_time/late/missing_dates, one latest review per order, review coverage, average score, low-score share (1–2), and calendar-day delivery deltas. Review timing may precede delivery; this is descriptive association only.

Raw and staging data are unchanged. Views are live and update when underlying data changes.

## Validation and initial findings

sql/09_validate_analytics.sql asserts one row per order and reconciles marketplace item revenue, payment totals, delivered seller revenue/units, seller cancellation counts, and delivered-order totals. All checks passed. Full output: analytics_validation_results.txt.

- Order summary: 99,441 rows; all-status item prices total 13,591,643.70; payment values total 16,008,872.12. These are different measures: payments can include freight and must not be compared directly to item prices alone.
- Among orders with a selected review, early deliveries average 4.294/5, on-time 4.034/5, late 2.270/5. Review coverage is 99.46%, 99.07%, and 97.66%, respectively.
- Among reviewed late deliveries, 62.42% score 1–2, versus 9.22% of reviewed early deliveries.
- Late deliveries have a median seven calendar days after estimate; early deliveries a median 13 days before estimate.
- Highest delivered item revenue: seller 4869f7a5dfa277a7dca6462dcf3b52b2, 226,987.93 across 1,124 delivered orders and 1,148 items. Counts and rate rankings answer different questions; inspect sample sizes before drawing conclusions.

## Reproduction and next step

After scripts 01–06, run 07 to investigate exceptions, 08 once to create the views, and 09 to validate them. Script 08 deliberately uses CREATE VIEW (no replacement) to protect existing view definitions on accidental reruns. Scripts 07 and 09 are read-only. On 2026-11-06, all ten SQL scripts passed in a new, empty PostgreSQL 18.6 database, including the reconciliation assertions in script 09. The rebuilt order summary had 99,441 rows; the temporary database was removed.

Business-question queries are saved in sql/10_business_questions.sql. The Power BI report includes Delivery & reviews, Delivery timing, Seller leaders, Cancellation risk, and Seller detail. SQL reconciliation checks passed again on 2026-11-06. On 2026-11-06, the saved customer-review chart filter and updated screenshot were verified to exclude Missing dates. The displayed delivery comparison covers 96,470 orders with usable dates; eight delivered orders with missing dates remain documented in the SQL findings. Preserve analytical grain when extending the model; do not recreate one-to-many revenue inflation.
