"""Module providing greeting functionality with proper type hints."""

from pydantic import BaseModel, field_validator


class GreetingConfig(BaseModel):
    """Demonstrates validation and OOP patterns."""

    default_name: str = "World"
    max_length: int = 20

    @field_validator("default_name")
    def validate_name(cls, value: str) -> str:
        """Validate that default_name contains only letters."""
        if not value.isalpha():
            raise ValueError("Name must contain only letters")
        return value.capitalize()


class Greeter:
    """Handle greeting generation with configuration."""

    def __init__(self, config: GreetingConfig) -> None:
        """Initialize Greeter with a GreetingConfig instance."""
        self.config = config

    def get_greeting(self, name: str | None = None) -> str:
        """Generate greeting with sanitized input."""
        clean_name = self._sanitize_input(name)
        return f"Hello {clean_name}!"

    def _sanitize_input(self, name: str | None) -> str:
        """Sanitize input name according to config constraints."""
        if not name or len(name) > self.config.max_length:
            return self.config.default_name
        return name.strip()


def run_example() -> None:
    """Run greeting example with error handling."""
    try:
        config = GreetingConfig()
        greeter = Greeter(config)

        user_input = input("Enter your name [World]: ").strip()
        print(greeter.get_greeting(user_input or None))
    except Exception as e:
        print(f"Error: {e!s}")


if __name__ == "__main__":
    run_example()
