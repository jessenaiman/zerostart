import pytest
from unittest.mock import patch
from src.main import GreetingConfig, Greeter

class TestGreetingSystem:
    def test_default_greeting(self):
        config = GreetingConfig()
        greeter = Greeter(config)
        assert greeter.get_greeting() == "Hello World!"
    
    def test_custom_greeting(self):
        config = GreetingConfig(default_name="Test")
        greeter = Greeter(config)
        assert greeter.get_greeting("Alice") == "Hello Alice!"
    
    @patch('builtins.input', return_value='')
    def test_empty_input(self, mock_input):
        config = GreetingConfig()
        greeter = Greeter(config)
        assert greeter.get_greeting("") == "Hello World!"
    
    def test_validation_error(self):
        with pytest.raises(ValueError):
            GreetingConfig(default_name="123")

    def test_type_safety(self):
        with pytest.raises(TypeError):
            Greeter(config="bad_config")  # type: ignore