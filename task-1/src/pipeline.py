"""Pipeline entry point.

Tasks (see chapter Task 4):
  1. Load configuration (INPUT_PATH, OUTPUT_PATH) from config.py.
  2. Read the messy CSV into a list of dicts.
  3. Run the transform chain (remove_invalid -> clean_fields ->
     filter_zero_quantity -> calculate_revenue).
  4. Convert each cleaned dict into a Transaction instance (this exercises
     the dataclass __post_init__ validation as a final guard).
  5. Save the result as a CSV at OUTPUT_PATH.
  6. Print a summary: total transactions, total revenue, total VAT.

The transform layer never opens files or prints. All I/O lives here.

Run from the task-1/ directory:
    python -m src.pipeline
"""
import csv
from dataclasses import asdict
from pathlib import Path

from .config import INPUT_PATH, OUTPUT_PATH
from .models import Transaction
from .transforms import (
    calculate_revenue,
    clean_fields,
    filter_zero_quantity,
    remove_invalid,
)


def read_csv(path: str) -> list[dict]:
    """Read a CSV file into a list of dicts. I/O only — no business rules."""
    # TODO: implement using csv.DictReader.
    raise NotImplementedError


def write_csv(rows: list[dict], path: str) -> None:
    """Write a list of dicts to CSV. I/O only — no business rules."""
    # TODO: implement using csv.DictWriter.
    raise NotImplementedError


def run() -> None:
    raw = read_csv(INPUT_PATH)
    data = remove_invalid(raw)
    data = clean_fields(data)
    data = filter_zero_quantity(data)
    data = calculate_revenue(data)

    # Materialise as Transaction instances so the dataclass __post_init__
    # acts as a final guard before serialisation.
    # TODO: cast price / quantity / revenue / vat to the right types here
    # if your transforms left them as strings, then iterate over `data`
    # to build Transaction(**row) for each cleaned row.
    transactions = [Transaction(**row) for row in data]

    # Output dir must exist. Use pathlib for cross-platform safety.
    Path(OUTPUT_PATH).parent.mkdir(parents=True, exist_ok=True)
    write_csv([asdict(t) for t in transactions], OUTPUT_PATH)

    total_revenue = sum(t.revenue for t in transactions)
    total_vat = sum(t.vat for t in transactions)
    print(f"Processed {len(transactions)} transactions")
    print(f"Total revenue: €{total_revenue:.2f}")
    print(f"Total VAT:     €{total_vat:.2f}")


if __name__ == "__main__":
    run()
