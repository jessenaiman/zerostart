"""
Terminal UI for the game.

This module provides terminal-based UI elements using rich and asciimatics.
"""
from typing import List, Tuple, Optional, Callable, Dict, Any
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.layout import Layout
from loguru import logger

try:
    from asciimatics.screen import Screen
    from asciimatics.scene import Scene
    from asciimatics.effects import Print
    from asciimatics.renderers import FigletText
    ASCIIMATICS_AVAILABLE = True
except ImportError:
    logger.warning("Asciimatics not available, falling back to simple UI")
    ASCIIMATICS_AVAILABLE = False


class TerminalUI:
    """Terminal-based UI for the game.
    
    This class provides a simple terminal UI using rich and asciimatics.
    
    Attributes:
        console: Rich console for output
        width: Terminal width
        height: Terminal height
    """
    
    def __init__(self):
        """Initialize the terminal UI."""
        self.console = Console()
        self.width = self.console.width
        self.height = self.console.height
        self._layout = Layout()
        self._configure_layout()
        logger.info(f"TerminalUI initialized with size {self.width}x{self.height}")
    
    def _configure_layout(self) -> None:
        """Configure the layout for the UI."""
        self._layout.split(
            Layout(name="header", size=3),
            Layout(name="main"),
            Layout(name="footer", size=3)
        )
        self._layout["main"].split_row(
            Layout(name="game", ratio=3),
            Layout(name="sidebar", ratio=1)
        )
    
    def show_title(self, title: str) -> None:
        """Show a title screen with the given title.
        
        Args:
            title: Title to display
        """
        if ASCIIMATICS_AVAILABLE:
            def _inner_show(screen: Screen) -> None:
                effects = [
                    Print(
                        screen,
                        FigletText(title, font="big"),
                        screen.height // 2 - 8,
                        colour=Screen.COLOUR_GREEN,
                        bg=Screen.COLOUR_BLACK,
                    ),
                    Print(
                        screen,
                        FigletText("Press any key to start", font="small"),
                        screen.height // 2 + 3,
                        colour=Screen.COLOUR_CYAN,
                        bg=Screen.COLOUR_BLACK,
                    ),
                ]
                screen.play([Scene(effects, -1)], stop_on_resize=True)
            
            try:
                Screen.wrapper(_inner_show)
            except Exception as e:
                logger.error(f"Error showing title: {e}")
                # Fallback if asciimatics fails
                self.console.print(Panel(f"[bold green]{title}[/bold green]"))
                self.console.print("[cyan]Press Enter to start[/cyan]")
                input()
        else:
            # Fallback for when asciimatics is not available
            self.console.print(Panel(f"[bold green]{title}[/bold green]"))
            self.console.print("[cyan]Press Enter to start[/cyan]")
            input()
    
    def display_menu(self, title: str, options: List[str]) -> int:
        """Display a menu and return the selected option index.
        
        Args:
            title: Title of the menu
            options: List of menu options
            
        Returns:
            Index of selected option
        """
        self.console.print(Panel(f"[bold]{title}[/bold]"))
        
        for i, option in enumerate(options):
            self.console.print(f"[cyan]{i+1}.[/cyan] {option}")
        
        while True:
            try:
                choice = int(self.console.input("[yellow]Enter choice:[/yellow] "))
                if 1 <= choice <= len(options):
                    return choice - 1
                self.console.print("[red]Invalid choice![/red]")
            except ValueError:
                self.console.print("[red]Please enter a number![/red]")
    
    def display_game_screen(self, game_data: Dict[str, Any]) -> None:
        """Display the main game screen with the provided data.
        
        Args:
            game_data: Dictionary of game data to display
        """
        # Header
        self._layout["header"].update(
            Panel(Text(f"[bold]{game_data.get('title', 'Game')}[/bold]", justify="center"))
        )
        
        # Game area
        game_content = ""
        for entity in game_data.get("entities", []):
            pos = entity.get_component("PositionComponent")
            if pos:
                x, y = int(pos.x), int(pos.y)
                game_content += f"Entity at ({x}, {y})\n"
        
        self._layout["game"].update(Panel(game_content or "No entities"))
        
        # Sidebar
        stats = game_data.get("stats", {})
        sidebar_content = "\n".join(f"{k}: {v}" for k, v in stats.items())
        self._layout["sidebar"].update(Panel(sidebar_content or "No stats"))
        
        # Footer
        self._layout["footer"].update(
            Panel(Text(game_data.get("message", ""), justify="center"))
        )
        
        # Render layout
        self.console.print(self._layout)
    
    def clear(self) -> None:
        """Clear the screen."""
        self.console.clear()
    
    def prompt(self, message: str) -> str:
        """Prompt the user for input.
        
        Args:
            message: Prompt message
            
        Returns:
            User input
        """
        return self.console.input(f"[yellow]{message}:[/yellow] ")
    
    def show_message(self, message: str, level: str = "info") -> None:
        """Show a message to the user.
        
        Args:
            message: Message to display
            level: Message level (info, warning, error)
        """
        colors = {
            "info": "blue",
            "warning": "yellow",
            "error": "red",
            "success": "green"
        }
        color = colors.get(level, "white")
        self.console.print(f"[{color}]{message}[/{color}]")
