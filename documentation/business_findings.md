# Business question findings — 2026-11-05

Source: sql/10_business_questions.sql, executed successfully in a read-only repeatable-read transaction. Full results: business_question_results.txt. These are whole-dataset snapshot summaries, not current operational performance.

## 1. Delivery timing and customer reviews

| Delivery group | Orders | Reviewed orders | Average score | Share of reviews scoring 1–2 |
|---|---:|---:|---:|---:|
| Early | 88,644 | 88,163 | 4.29 | 9.22% |
| On estimated day | 1,292 | 1,280 | 4.03 | 12.42% |
| Late | 6,534 | 6,381 | 2.27 | 62.42% |

Late deliveries are associated with substantially worse reviews. This does not establish causation; product quality, seller, geography, and review timing could also matter. One latest review per order is selected. Missing reviews are excluded from score denominators. Eight delivered orders with missing actual dates remain separate.

## 2. Which sellers sell the most?

Highest delivered item revenue: 4869f7a5dfa277a7dca6462dcf3b52b2 (Guariba, SP), 226,987.93, from 1,148 units and 1,124 orders.

Highest delivered units AND order count: 6560211a19b47992c3666cc44a7e94c0, 1,996 units and 1,819 orders; revenue 120,702.83.

Total delivered item revenue: 13,221,498.11. The top ten sellers by revenue account for 13.27%. Revenue excludes freight; it is not profit or verified net revenue. Multi-seller orders count once per participating seller, so seller order counts must not be summed into a marketplace order total.

## 3. Which sellers have the most cancellations?

Highest count: cc419e0650a3c5ba77189a1882b7556a, nine cancellations from 1,706 linked orders (0.53%).

Highest rate among sellers with at least 30 linked orders: bacb1f0ed56ad24198f5810d2b3fe9a5, three cancellations from 42 orders (7.14%). The 30-order minimum is provisional, not a significance test. Small cancellation counts make rates unstable.

Count and rate rankings answer different questions. A busy seller can have more cancellations but a lower rate. The denominator includes all seller-linked order statuses in the snapshot, including unfinished orders; unavailable is separate from canceled. Cancellations do not establish seller fault.

Of 625 canceled orders, 461 (73.76%) can be assigned to sellers; 164 cannot. Returns are not explicitly recorded, so no return-rate claim is supported.

## 4. Actual versus estimated delivery

Among 96,470 delivered orders with usable dates:

| Result | Orders | Share | Average calendar days actual minus estimate | Median days |
|---|---:|---:|---:|---:|
| Early | 88,644 | 91.89% | -13.71 | -13 |
| On estimated day | 1,292 | 1.34% | 0.00 | 0 |
| Late | 6,534 | 6.77% | 10.62 | 7 |

Overall mean: 11.88 days early; median: 12 days early. Negative is early and positive is late. These differences measure promise accuracy, not purchase-to-delivery speed. Early arrivals could reflect conservative estimates; this summary alone cannot determine why estimates differ.

## Business interpretation and next step

Delivery reliability deserves further investigation because late orders have substantially worse review outcomes. Most orders arrive before the estimate, suggesting an opportunity to investigate promise accuracy. Seller performance should display revenue, volume, cancellation counts, rates, and denominators together.

The Power BI report is complete and manually checked against validated SQL results. It covers delivery and reviews, delivery timing, seller sales leaders, cancellation risk, and seller detail. Recommended follow-up: investigate late deliveries by seller, location, and product category; review high cancellation rates alongside order counts; assess delivery-estimate accuracy before changing customer promises.
