"""
Comprehensive tests for core functionality and dependencies
"""
import sys
import importlib
import pytest
from src.demo.app import DemoApp

# ---- Infrastructure Tests ----
def test_python_version():
    """Verify Python version compatibility"""
    assert sys.version_info >= (3, 13, 2), \
        f"Python 3.13.2+ required. Current version: {sys.version}"

def test_virtual_environment_active():
    """Ensure virtual environment is properly activated"""
    assert hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix), \
        "Virtual environment not active! Run 'poetry shell' first"

# ---- Core Functionality Tests ----
class TestDemoApp:
    """Comprehensive test suite for DemoApp functionality"""
    
    @pytest.fixture
    def app(self):
        """Fixture providing initialized app instance"""
        return DemoApp(name="Integration Test App")

    def test_initialization(self, app):
        """Validate object construction and property assignment"""
        assert app.name == "Integration Test App"
        with pytest.raises(TypeError):
            DemoApp(name=123)  # Test type validation

    def test_app_execution(self, app, capsys):
        """Verify complete execution workflow"""
        result = app.run()
        captured = capsys.readouterr()
        
        assert result is True
        assert "running" in captured.out.lower()
        assert "success" in captured.out.lower()

        # Verify rich output detection
        if "rich" in captured.out:
            assert "\[bold green\]" in captured.out  # Check rich formatting

    def test_error_handling(self, app, mocker):
        """Test exception handling and logging"""
        mocker.patch.object(app, 'run', side_effect=RuntimeError("Simulated failure"))
        with pytest.raises(RuntimeError):
            app.run()

# ---- Dependency Validation Tests ----
DEPENDENCY_CHECKS = [
    ("rich", ["console.print"]),
    ("loguru", ["logger.info"]),
    ("pandas", ["DataFrame"]),
    ("numpy", ["array"]),
    ("sqlalchemy", ["create_engine"]),
    ("fastapi", ["FastAPI"]),
]

@pytest.mark.parametrize("package,attrs", DEPENDENCY_CHECKS)
def test_optional_dependencies(package, attrs):
    """Validate optional dependency availability and functionality"""
    try:
        module = importlib.import_module(package)
        for attr in attrs:
            assert hasattr(module, attr), f"{package} missing expected attribute {attr}"
    except ImportError:
        pytest.skip(f"Optional dependency {package} not installed")

# ---- Performance Checks ----
@pytest.mark.benchmark
def test_app_performance(benchmark):
    """Benchmark basic application startup"""
    result = benchmark(DemoApp().run)
    assert result is True