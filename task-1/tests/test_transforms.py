"""Tests for the pure transform functions (chapter Task 5).

Write at least 4 tests:
  - test_remove_invalid_drops_empty_names
  - test_clean_fields_normalizes_names
  - test_calculate_revenue_adds_fields
  - test_no_mutation
"""
import pytest

from src.transforms import (
    calculate_revenue,
    clean_fields,
    filter_zero_quantity,
    remove_invalid,
)


def test_remove_invalid_drops_empty_names():
    # TODO: feed in 3 rows (one valid, one empty product_name, one
    # whitespace-only product_name); assert only the valid one survives.
    raise NotImplementedError


def test_clean_fields_normalizes_names():
    # TODO: feed a row with messy product_name and uppercase email; assert
    # the output has stripped + title-cased name and lowercase email.
    raise NotImplementedError


def test_calculate_revenue_adds_fields():
    # TODO: feed a row with price=100, quantity=3; assert output has
    # revenue=300.0 and vat=63.0 (default VAT rate is 0.21).
    raise NotImplementedError


def test_no_mutation():
    # TODO: feed in a list, run any transform on it, assert the original
    # list is unchanged. This is the most important test in the file.
    raise NotImplementedError
