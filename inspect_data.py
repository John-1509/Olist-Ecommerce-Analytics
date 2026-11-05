
import csv
from pathlib import Path

DATA_DIR = Path("data/raw")

for file in sorted(DATA_DIR.glob("*.csv")):
    print("\n" + "=" * 70)
    print(f"TABLE: {file.name}")

    row_count = 0
    missing = {}

    with open(file, "r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)

        columns = reader.fieldnames
        print("COLUMNS:", columns)

        for row in reader:
            row_count += 1

            for column, value in row.items():
                if value is None or value.strip() == "":
                    missing[column] = missing.get(column, 0) + 1

    print("TOTAL ROWS:", row_count)
    print("MISSING VALUES:", missing or "None")
