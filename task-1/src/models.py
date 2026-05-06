"""Data model for a sales transaction.

Tasks (see chapter Task 2):
  1. Define a Transaction dataclass with the fields listed below.
  2. Use __post_init__ to enforce: price >= 0 and product_name non-empty.

The pipeline converts cleaned dicts into Transaction instances at the
boundary, so the dataclass is the schema-of-record for everything that
gets written to the output CSV.
"""
from dataclasses import dataclass


# TODO 1: Define a @dataclass called Transaction with these fields:
#   transaction_id: int
#   product_name: str
#   category: str
#   price: float
#   quantity: int
#   customer_email: str
#   date: str
#   revenue: float = 0.0
#   vat: float = 0.0
#
# TODO 2: Add __post_init__ that raises ValueError when:
#   - self.price < 0  (with a message naming the bad value)
#   - not self.product_name.strip()  (empty / whitespace-only product name)


# Replace this stub with your dataclass:
@dataclass
class Transaction:
    transaction_id: int  # TODO: replace this stub with the full field list above
