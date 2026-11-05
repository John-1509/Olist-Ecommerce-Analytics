# SQL reproduction and analysis scope

Scripts reproduce the current pipeline; they are not an exact history of pgAdmin commands.

Run in order against a NEW, EMPTY database:
1. 01_database_structure.sql: existing raw table and schema definitions.
2. 02_load_raw.sql: CSV imports. Uses psql commands; run from the project root, not pgAdmin Query Tool.
3. 03_staging_structure.sql: exported current staging definitions, primary keys, and foreign keys.
4. 04_load_staging.sql: explicit column mappings and casts; parent tables load first in one transaction.
5. 05_validate_staging.sql: read-only row counts and relationship checks.

Example from the project root; replace NEW_DATABASE with a new database:

```powershell
psql -X -h localhost -U postgres -d NEW_DATABASE -v ON_ERROR_STOP=1 -f sql/01_database_structure.sql
```

Repeat for subsequent files. No passwords are stored. The current olist_analytics database is already loaded: do not rerun scripts 01-04 there.

## Business questions

- How often are delivered orders late, and how does lateness relate to review scores?
- Which sellers sell the most? Report item revenue, units, and distinct orders separately; define included statuses.
- Which sellers have the most canceled orders and highest cancellation rates? Status is at order level. Attribute via order items, without implying seller fault. Canceled orders without items cannot be assigned to sellers. These tables do not explicitly track returns.
- What is actual minus estimated delivery? Positive means late, negative means early. Define calendar-day versus elapsed-time metrics before calculating.

Before analytics, document duplicate reviews, geolocation anomalies, missing values, and metric rules.

## Data quality audit

Run 06_data_quality_audit.sql against the loaded database. It is read-only. Results and proposed metric rules are in ../documentation/data_quality_audit.md and data_quality_audit_results.txt.


## Analytics

07_investigate_exceptions.sql is read-only. 08_analytics_views.sql creates three live analytics views; run once. 09_validate_analytics.sql checks grain and reconciles totals without changing data. See ../documentation/analytics_notes.md for metric definitions, limitations, and results.


## Business questions

10_business_questions.sql answers the four agreed questions using the analytics views. It is read-only. Findings: ../documentation/business_findings.md. Full output: ../documentation/business_question_results.txt.

