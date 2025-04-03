"""Common types."""

from typing import NamedTuple


class Vector2(NamedTuple):
    x: float
    y: float


class RGB(NamedTuple):
    r: int
    g: int
    b: int


# Auto-verify import path
if __name__ == "__main__":
    print(f"{__package__} import check passed")
