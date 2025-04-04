"""
Sample application that opens a window.

This demonstrates that the project is set up correctly.
"""
import sys
from pathlib import Path
import logging

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)


class DemoApp:
    """
    A simple demo application.
    
    This class provides a minimal working example to demonstrate
    that the ZeroStart setup is functioning correctly.
    """
    
    def __init__(self, name="ZeroStart Demo"):
        """
        Initialize the demo application.
        
        Args:
            name: Name of the application
        """
        self.name = name
        logger.info("Demo application initialized")
    
    def run(self):
        """Run the demo application."""
        try:
            logger.info(f"Running {self.name}")
            logger.info("Application started successfully")
            
            # If rich is installed, use it for fancy output
            try:
                from rich.console import Console
                from rich.panel import Panel
                
                console = Console()
                console.print(Panel(f"[bold green]{self.name} is running![/bold green]"))
                console.print("[bold cyan]This sample app confirms ZeroStart is working correctly![/bold cyan]")
            except ImportError:
                print(f"{self.name} is running!")
                print("This sample app confirms ZeroStart is working correctly!")
            
            return True
        except Exception as e:
            logger.error(f"Error running application: {e}")
            return False


def main():
    """Main entry point for the demo application."""
    app = DemoApp()
    success = app.run()
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
