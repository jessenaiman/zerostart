"""
Tests for the demo application.

These tests verify that the sample app works correctly.
"""
import pytest
from src.demo.app import DemoApp


def test_app_initialization():
    """Test that the app initializes correctly."""
    app = DemoApp(name="Test App")
    assert app.name == "Test App"


def test_app_run():
    """Test that the app runs without errors."""
    app = DemoApp()
    result = app.run()
    assert result is True
