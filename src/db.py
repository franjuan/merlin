"""Database utilities for Merlin."""

from importlib import resources


def get_kmymoney_schema() -> str:
    """Load the KMyMoney SQLite schema from resources."""
    with resources.files("src.resources").joinpath("kmymoney_schema.sql").open("r", encoding="utf-8") as f:
        return f.read()
