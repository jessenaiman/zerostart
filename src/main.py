from pydantic import BaseModel, field_validator

class GreetingConfig(BaseModel):
    """Demonstrates validation and OOP patterns"""
    default_name: str = "World"
    max_length: int = 20
    
    @field_validator('default_name')
    def validate_name(cls, value):
        if not value.isalpha():
            raise ValueError("Name must contain only letters")
        return value.capitalize()

class Greeter:
    def __init__(self, config: GreetingConfig):
        self.config = config
        
    def get_greeting(self, name: str | None = None) -> str:
        """Core business logic with type hints"""
        clean_name = self._sanitize_input(name)
        return f"Hello {clean_name}!"
    
    def _sanitize_input(self, name: str | None) -> str:
        """Private method demonstrating encapsulation"""
        if not name or len(name) > self.config.max_length:
            return self.config.default_name
        return name.strip()

def run_example():
    """Main entry point with proper error handling"""
    try:
        config = GreetingConfig()
        greeter = Greeter(config)
        
        user_input = input("Enter your name [World]: ").strip()
        print(greeter.get_greeting(user_input or None))
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    run_example()
[file content end]

**3. Educational Test Suite**
```python
[file name]: tests/test_main.py
[file content begin]
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

