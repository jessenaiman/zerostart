import pytest
from typing import Any
from pathlib import Path

def test_linting_compliance():
    """Demonstrate proper error formatting"""
    # Deliberate violation (commented out for initial pass)
    # bad_code = "print( 'Hello World' )"  # Extra spaces
    # expected = "print('Hello World')"
    good_code = "print('Hello World')"
    
    # This would fail with Ruff if uncommented:
    # assert bad_code.strip() == expected, \
    #    "Linter error: Shows exact position\n" \
    #    "Expected: {}\n" \
    #    "Received: {}\n" \
    #    "Fix with: ruff --fix".format(expected, bad_code)
    assert good_code == "print('Hello World')"

def test_type_annotations():
    """Show mypy error example"""
    # Uncomment to see type error:
    # def add(a: int, b: int) -> str:
    #     return a + b
    def add(a: int, b: int) -> int:
        return a + b
    
    assert add(2, 3) == 5

def test_ci_requirements():
    """Verify critical CI components"""
    assert Path("pyproject.toml").exists(), "Missing Poetry config"
    assert Path(".github/workflows/ci.yml").exists(), "Missing CI pipeline"
    assert Path(".pre-commit-config.yaml").exists(), "Missing pre-commit"
    
@pytest.fixture
def example_fixture():
    """Show proper test failure context"""
    data = {"valid": True}
    yield data
    # Cleanup demo would go here

def test_fixture_usage(example_fixture):
    assert example_fixture["valid"], \
        "Fixture failed: Shows test setup context\n" \
        "Check fixture initialization"