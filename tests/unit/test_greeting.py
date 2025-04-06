from unittest.mock import patch

import pytest

from src.main import Greeter, GreetingConfig


class TestGreetingSystem:
    """Test suite for the Greeter and GreetingConfig classes."""

    def test_default_greeting(self) -> None:
        """Verify the default greeting is returned correctly."""
        config = GreetingConfig()
        greeter = Greeter(config)
        assert greeter.get_greeting() == "Hello World!"

    def test_custom_greeting(self) -> None:
        """Check that a custom name overrides the default greeting."""
        config = GreetingConfig(default_name="Test")
        greeter = Greeter(config)
        assert greeter.get_greeting("Alice") == "Hello Alice!"

    @patch("builtins.input", return_value="")
    def test_empty_input(self, mock_input) -> None:
        """Ensure an empty input falls back to the default greeting."""
        config = GreetingConfig()
        greeter = Greeter(config)
        assert greeter.get_greeting("") == "Hello World!"

    def test_validation_error(self) -> None:
        """Test that invalid default_name raises a ValueError."""
        with pytest.raises(ValueError):
            GreetingConfig(default_name="123")

    def test_type_safety(self) -> None:
        """Verify that passing an invalid config type raises a TypeError."""
        with pytest.raises(TypeError):
            Greeter(config="bad_config")  # type: ignore
