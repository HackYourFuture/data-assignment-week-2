"""Pure transform functions over a list of dicts.

Tasks (see chapter Task 3):
  Build at least these four pure, composable transforms. Each MUST:
    - take a list of dicts and return a NEW list (never mutate the input)
    - be free of I/O (no file reads, no prints)
    - be testable with hand-rolled data (see tests/test_transforms.py)

Use the {**row, "key": value} spread pattern to create new dicts instead of
mutating the originals. This is the central pattern from chapter 6.
"""


def remove_invalid(rows: list[dict]) -> list[dict]:
    """Remove rows with empty product_name OR negative price.

    Empty here means missing, "", or whitespace-only.
    """
    # TODO: implement. Return a new list, do not mutate `rows`.
    raise NotImplementedError


def clean_fields(rows: list[dict]) -> list[dict]:
    """Clean string fields:

    - product_name: strip + title-case
    - customer_email: strip + lowercase
    - category: default to "Unknown" if missing or empty

    Use the {**row, ...} spread pattern. Do not mutate the input.
    """
    # TODO: implement.
    raise NotImplementedError


def calculate_revenue(rows: list[dict], vat_rate: float = 0.21) -> list[dict]:
    """Add 'revenue' (price * quantity) and 'vat' (revenue * vat_rate) fields.

    Round both to 2 decimal places. Coerce price/quantity from string if needed.
    """
    # TODO: implement.
    raise NotImplementedError


def filter_zero_quantity(rows: list[dict]) -> list[dict]:
    """Remove rows where quantity is 0."""
    # TODO: implement.
    raise NotImplementedError
