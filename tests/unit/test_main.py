from io import StringIO
from unittest.mock import patch
from src.omega_project.main import main


def test_main():
    with patch("sys.stdout", new=StringIO()) as mock_stdout:
        with patch("builtins.input", return_value="World"):
            main()
        output = mock_stdout.getvalue()
        assert "Hello, World!" in output
