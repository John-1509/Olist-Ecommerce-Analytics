# Olist Ecommerce Analytics

An end-to-end analysis using PostgreSQL, SQL, and Power BI.

![Delivery and customer reviews](<powerbi/screenshots/Delivery & reviews.png>)

## Business questions
- How does delivery timing relate to customer reviews?
- Which sellers lead in sales?
- Which sellers have the most cancellations by count and rate?
- How does actual delivery compare with estimated delivery?

## Main findings
- Late orders average 2.27 review stars versus 4.29 for early orders.
- 6.77% of delivered orders with usable dates arrive late.
- The top ten sellers generate 13.27% of delivered item sales.
- Cancellation count and rate identify different sellers.

## Workflow
Raw data → typed staging tables → quality audit →
validated analytics views → SQL analysis → Power BI report.

## Project files
- `sql/`: numbered SQL scripts and execution instructions.
- `documentation/`: audits, metric definitions, and business findings.
- `powerbi/Olist Ecommerce Analytics.pbix`: interactive report.

## Limitations
Historical dataset, not current marketplace performance.
Returns are not explicitly recorded.
Some cancellations lack seller attribution.
Sales exclude freight and do not represent profit.
Associations do not establish causation.
## Data source and attribution

Data: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), published by Olist on Kaggle. The source lists [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). Credit Olist and retain the source license when sharing source data or adaptations. This project aggregates the data, applies documented type conversions, selects the latest review per order, and adds analytical metrics and presentation labels. It is an independent educational portfolio project, not an official Olist report.

Raw CSV files are excluded from Git. The PBIX contains imported data; excluding CSV files does not remove data embedded in the report. Source-data licensing still applies to that content. No separate license for the original project code is granted here.

## Reproduce the analysis

1. Install PostgreSQL 18 with `psql` available. Schema exports use PostgreSQL 18 commands. The existing database was validated on PostgreSQL 18.6.
2. Download the dataset above. Extract its nine CSV files, with original names, into `data/raw/`.
3. Create a new, empty database. Run the ten numbered SQL scripts in order from the project root using `psql -X -v ON_ERROR_STOP=1`. See [SQL instructions](sql/README.md). Do not rerun loading scripts against an already loaded database.
4. Read [metric definitions and validation](documentation/analytics_notes.md) and [business findings](documentation/business_findings.md).
5. Open `powerbi/Olist Ecommerce Analytics.pbix` in Power BI Desktop. The imported snapshot can be viewed without a database connection. To refresh against your database, use **Transform data > Data source settings > Change Source**, set your PostgreSQL server and database, and supply your own credentials. The report imports the three `analytics` views. Preserve the report's existing Power Query steps.

### Optional Python exploration

The SQL pipeline does not depend on Python. For the three exploratory scripts, use Python 3.13 and run from the project root:

```powershell
python -m venv .venv
.venv/Scripts/python.exe -m pip install -r requirements.txt
.venv/Scripts/python.exe inspect_data.py
.venv/Scripts/python.exe key_audit.py
.venv/Scripts/python.exe investigate_duplicates.py
```

`inspect_data.py` and `key_audit.py` use the standard library. `investigate_duplicates.py` requires pandas. On 2026-11-06, requirements installed successfully in a fresh Python 3.13 environment, pip check passed, and all three scripts completed successfully. Installation used cached distribution wheels.

## Validation status

Read-only SQL checks confirm order grain, item and payment totals, seller sales and units, seller cancellation counts, and delivered-order totals. On 2026-11-06, all ten SQL scripts completed successfully in a new, empty PostgreSQL 18.6 database; the rebuilt order summary contained 99,441 rows. The temporary database was then removed. See [reproduction verification](documentation/reproduction_verification.md). Screenshots are static previews; the PBIX is the interactive deliverable.
