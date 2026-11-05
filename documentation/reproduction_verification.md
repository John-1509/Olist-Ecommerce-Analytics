# Reproduction verification — 2026-11-06

## Database rebuild

Created a separate, empty PostgreSQL 18.6 database. Ran scripts 01 through 10 in filename order from the project root, with psql -X and ON_ERROR_STOP=1. Every script exited successfully. Script 09's assertions passed: order grain, item and payment totals, delivered seller revenue and units, seller cancellation counts, and delivered-order totals. The rebuilt analytics.order_summary contained 99,441 rows.

The temporary audit database was removed after success. The existing olist_analytics database was not rebuilt or changed by this test. Local source CSV files were used; downloading a fresh copy of the dataset was not tested.

## Python installation and execution

Created a fresh Python 3.13 virtual environment outside the project. Installed requirements.txt successfully using pip; distribution wheels came from the local pip cache. pip check reported no broken requirements.

All three scripts completed with exit code zero from the project root:

- inspect_data.py
- key_audit.py
- investigate_duplicates.py

Installed pandas 3.1.0, numpy 2.5.4, python-dateutil 4.0.0, and tzdata 2026.6. Only pandas is a direct project dependency; transitive dependencies are not locked.

## Scope

This verifies local database reconstruction and Python execution on Windows. It does not verify another operating system, a cache-free package download, or a full Power BI refresh against the rebuilt database. The saved report and screenshots were checked separately.
