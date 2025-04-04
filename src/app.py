from loguru import logger

class DemoApp:
    """A demonstration application for ZeroStart.

    This class shows how to structure an application with logging and proper docstrings.

    Attributes:
        name (str): The name of the application.
    """
    def __init__(self, name: str) -> None:
        """Initialize the DemoApp with a name.

        Args:
            name (str): The name of the application.
        """
        self.name = name
        logger.info(f"Initializing {self.name}")

    def run(self) -> bool:
        """Run the application.

        Returns:
            bool: True if the application runs successfully.
        """
        logger.info(f"{self.name} is running")
        print(f"{self.name} is running successfully")
        return True