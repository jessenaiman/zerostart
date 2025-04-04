#!/bin/bash
# ZeroStart Game Setup Script
# This script sets up a basic game development environment
# Run this after the main zerostart.sh for game-specific setup
set -euo pipefail

# Colors and Symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
ARROW="➜"; CHECK="✓"; CROSS="❌"

function show_header() {
    echo -e "${CYAN}"
    echo "========================================"
    echo "  ZeroStart Game Development Setup"
    echo "========================================"
    echo -e "${NC}"
}

activate_venv() {
    echo -e "\n${YELLOW}${ARROW} Activating virtual environment${NC}"
    if [ ! -d ".venv" ]; then
        echo -e "${RED}${CROSS} Virtual environment not found. Run zerostart.sh first${NC}"
        exit 1
    fi
    
    # Platform-specific activation
    if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        source .venv/bin/activate
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        source .venv/Scripts/activate
        .venv\Scripts\activate  
    else
        echo -e "${RED}${CROSS} Unsupported OS for auto-activation${NC}"
        echo "Please activate manually:"
        echo "  Linux/Mac: source .venv/bin/activate"
        echo "  Windows: .venv\\Scripts\\activate"
        exit 1
    fi
    echo -e "${GREEN}${CHECK} Virtual environment activated${NC}"
}

install_game_packages() {
    echo -e "\n${YELLOW}${ARROW} Installing game development packages${NC}"
    
    # Check if Poetry is installed
    if ! command -v poetry &>/dev/null; then
        echo -e "${RED}${CROSS} Poetry not found. Run zerostart.sh first${NC}"
        exit 1
    fi
    
    # Install game development packages
    poetry add --group game arcade pyglet asciimatics rich alive-progress numpy
    
    echo -e "${GREEN}${CHECK} Game development packages installed${NC}"
}

create_game_structure() {
    echo -e "\n${YELLOW}${ARROW} Creating game directory structure${NC}"
    
    # Create directories
    mkdir -p src/game/{engine,ui,assets}
    mkdir -p tests/game
    mkdir -p assets/{images,sounds,fonts}
    
    # Create __init__.py files
    touch src/game/__init__.py
    touch src/game/engine/__init__.py
    touch src/game/ui/__init__.py
    touch src/game/assets/__init__.py
    touch tests/game/__init__.py
    
    echo -e "${GREEN}${CHECK} Game directory structure created${NC}"
}

create_game_engine() {
    echo -e "\n${YELLOW}${ARROW} Creating game engine files${NC}"
    
    # Create game_loop.py
    cat > src/game/engine/game_loop.py << 'EOF'
"""
Game loop implementation.

This module handles the main game loop and timing.
"""
from loguru import logger
from typing import Callable, Optional, List, Dict, Any
import time


class GameLoop:
    """Main game loop controller.
    
    This class manages the game's main loop, including timing, updates,
    and rendering cycles.
    
    Attributes:
        target_fps: Target frames per second
        update_rate: Fixed update rate for game logic
        running: Whether the game loop is currently running
    """
    
    def __init__(self, target_fps: int = 60, update_rate: int = 120):
        """Initialize the game loop.
        
        Args:
            target_fps: Target frames per second for rendering
            update_rate: Fixed update rate for game logic in updates per second
        """
        self.target_fps = target_fps
        self.update_rate = update_rate
        self.running = False
        self.frame_time = 1.0 / target_fps
        self.update_time = 1.0 / update_rate
        self._render_callback: Optional[Callable[[], None]] = None
        self._update_callback: Optional[Callable[[float], None]] = None
        self._input_callback: Optional[Callable[[], None]] = None
        logger.info(f"GameLoop initialized with {target_fps} FPS, {update_rate} UPS")
    
    def set_render_callback(self, callback: Callable[[], None]) -> None:
        """Set the callback for rendering.
        
        Args:
            callback: Function to call for rendering
        """
        self._render_callback = callback
    
    def set_update_callback(self, callback: Callable[[float], None]) -> None:
        """Set the callback for game updates.
        
        Args:
            callback: Function to call for updates, takes delta time in seconds
        """
        self._update_callback = callback
    
    def set_input_callback(self, callback: Callable[[], None]) -> None:
        """Set the callback for input processing.
        
        Args:
            callback: Function to call for input processing
        """
        self._input_callback = callback
    
    def start(self) -> None:
        """Start the game loop."""
        if self._update_callback is None:
            raise ValueError("Update callback must be set before starting the game loop")
        
        if self._render_callback is None:
            logger.warning("No render callback set")
        
        self.running = True
        logger.info("Starting game loop")
        
        last_time = time.time()
        lag = 0.0
        
        while self.running:
            current_time = time.time()
            elapsed = current_time - last_time
            last_time = current_time
            lag += elapsed
            
            # Process input
            if self._input_callback:
                self._input_callback()
            
            # Update game logic at fixed time steps
            while lag >= self.update_time:
                if self._update_callback:
                    self._update_callback(self.update_time)
                lag -= self.update_time
            
            # Render at target FPS
            if self._render_callback:
                self._render_callback()
            
            # Sleep to maintain target FPS
            time_to_sleep = self.frame_time - (time.time() - current_time)
            if time_to_sleep > 0:
                time.sleep(time_to_sleep)
    
    def stop(self) -> None:
        """Stop the game loop."""
        self.running = False
        logger.info("Game loop stopped")
EOF

    # Create entity.py
    cat > src/game/engine/entity.py << 'EOF'
"""
Entity component system.

This module implements a simple entity component system for game objects.
"""
from typing import Dict, Any, List, Optional, Set
from uuid import uuid4
from loguru import logger


class Component:
    """Base class for all components.
    
    Components are data containers attached to entities.
    """
    
    def __str__(self) -> str:
        """Return string representation of the component."""
        return f"{self.__class__.__name__}"


class PositionComponent(Component):
    """Component for storing position data.
    
    Attributes:
        x: X position
        y: Y position
    """
    
    def __init__(self, x: float = 0.0, y: float = 0.0):
        """Initialize position component.
        
        Args:
            x: X position
            y: Y position
        """
        self.x = x
        self.y = y


class VelocityComponent(Component):
    """Component for storing velocity data.
    
    Attributes:
        dx: X velocity
        dy: Y velocity
    """
    
    def __init__(self, dx: float = 0.0, dy: float = 0.0):
        """Initialize velocity component.
        
        Args:
            dx: X velocity
            dy: Y velocity
        """
        self.dx = dx
        self.dy = dy


class RenderComponent(Component):
    """Component for storing rendering data.
    
    Attributes:
        visible: Whether the entity is visible
        sprite: Name of the sprite to use
        z_index: Render order (higher values are rendered on top)
    """
    
    def __init__(self, visible: bool = True, sprite: str = "default", z_index: int = 0):
        """Initialize render component.
        
        Args:
            visible: Whether the entity is visible
            sprite: Name of the sprite to use
            z_index: Render order (higher values are rendered on top)
        """
        self.visible = visible
        self.sprite = sprite
        self.z_index = z_index


class Entity:
    """Game entity with components.
    
    An entity is a container for components that define its behavior.
    
    Attributes:
        id: Unique identifier for this entity
        components: Dictionary of components by type
    """
    
    def __init__(self, entity_id: Optional[str] = None):
        """Initialize a new entity.
        
        Args:
            entity_id: Optional ID for the entity, generated if not provided
        """
        self.id = entity_id if entity_id else str(uuid4())
        self.components: Dict[str, Component] = {}
        logger.debug(f"Entity {self.id} created")
    
    def add_component(self, component: Component) -> None:
        """Add a component to this entity.
        
        Args:
            component: Component to add
        """
        component_type = component.__class__.__name__
        self.components[component_type] = component
        logger.debug(f"Added {component_type} to entity {self.id}")
    
    def remove_component(self, component_type: str) -> None:
        """Remove a component from this entity.
        
        Args:
            component_type: Type of component to remove
        """
        if component_type in self.components:
            del self.components[component_type]
            logger.debug(f"Removed {component_type} from entity {self.id}")
    
    def get_component(self, component_type: str) -> Optional[Component]:
        """Get a component by type.
        
        Args:
            component_type: Type of component to get
            
        Returns:
            The component if found, None otherwise
        """
        return self.components.get(component_type)
    
    def has_component(self, component_type: str) -> bool:
        """Check if entity has a component.
        
        Args:
            component_type: Type of component to check for
            
        Returns:
            True if entity has component, False otherwise
        """
        return component_type in self.components


class EntityManager:
    """Manages all entities in the game.
    
    Attributes:
        entities: Dictionary of all entities by ID
    """
    
    def __init__(self):
        """Initialize the entity manager."""
        self.entities: Dict[str, Entity] = {}
        logger.info("EntityManager initialized")
    
    def create_entity(self, entity_id: Optional[str] = None) -> Entity:
        """Create a new entity and add it to the manager.
        
        Args:
            entity_id: Optional ID for the entity
            
        Returns:
            Newly created entity
        """
        entity = Entity(entity_id)
        self.entities[entity.id] = entity
        return entity
    
    def remove_entity(self, entity_id: str) -> None:
        """Remove an entity from the manager.
        
        Args:
            entity_id: ID of entity to remove
        """
        if entity_id in self.entities:
            del self.entities[entity_id]
            logger.debug(f"Removed entity {entity_id}")
    
    def get_entity(self, entity_id: str) -> Optional[Entity]:
        """Get an entity by ID.
        
        Args:
            entity_id: ID of entity to get
            
        Returns:
            Entity if found, None otherwise
        """
        return self.entities.get(entity_id)
    
    def get_entities_with_components(self, *component_types: str) -> List[Entity]:
        """Get all entities that have all the specified components.
        
        Args:
            *component_types: Component types to filter by
            
        Returns:
            List of entities with all components
        """
        result = []
        for entity in self.entities.values():
            if all(entity.has_component(ct) for ct in component_types):
                result.append(entity)
        return result
EOF

    echo -e "${GREEN}${CHECK} Game engine files created${NC}"
}

create_game_ui() {
    echo -e "\n${YELLOW}${ARROW} Creating game UI files${NC}"
    
    # Create terminal_ui.py
    cat > src/game/ui/terminal_ui.py << 'EOF'
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
EOF

    echo -e "${GREEN}${CHECK} Game UI files created${NC}"
}

create_main_game() {
    echo -e "\n${YELLOW}${ARROW} Creating main game file${NC}"
    
    # Create game.py
    cat > src/game/game.py << 'EOF'
"""
Main game implementation.

This module ties together all game components.
"""
from typing import Dict, Any, List, Optional
import time
import sys
from pathlib import Path
from loguru import logger

from .engine.game_loop import GameLoop
from .engine.entity import EntityManager, PositionComponent, VelocityComponent, RenderComponent
from .ui.terminal_ui import TerminalUI


class Game:
    """Main game class.
    
    This class integrates all game systems.
    
    Attributes:
        name: Game name
        entity_manager: Manager for game entities
        game_loop: Game loop controller
        ui: User interface
    """
    
    def __init__(self, name: str = "ZeroStart Game"):
        """Initialize the game.
        
        Args:
            name: Name of the game
        """
        self.name = name
        self.entity_manager = EntityManager()
        self.game_loop = GameLoop(target_fps=30, update_rate=60)
        self.ui = TerminalUI()
        self.score = 0
        self.time_elapsed = 0.0
        self.game_over = False
        self._setup_game_loop()
        logger.info(f"Game '{name}' initialized")
    
    def _setup_game_loop(self) -> None:
        """Set up game loop callbacks."""
        self.game_loop.set_update_callback(self.update)
        self.game_loop.set_render_callback(self.render)
        self.game_loop.set_input_callback(self.process_input)
    
    def initialize(self) -> None:
        """Initialize the game state."""
        logger.info("Initializing game")
        
        # Create player entity
        player = self.entity_manager.create_entity("player")
        player.add_component(PositionComponent(x=10.0, y=10.0))
        player.add_component(VelocityComponent(dx=0.0, dy=0.0))
        player.add_component(RenderComponent(sprite="player"))
        
        # Create obstacle entity
        obstacle = self.entity_manager.create_entity("obstacle")
        obstacle.add_component(PositionComponent(x=15.0, y=15.0))
        obstacle.add_component(RenderComponent(sprite="obstacle"))
        
        logger.info("Game initialized with player and obstacle")
    
    def update(self, delta_time: float) -> None:
        """Update game state.
        
        Args:
            delta_time: Time since last update in seconds
        """
        self.time_elapsed += delta_time
        
        # Update positions based on velocities
        entities = self.entity_manager.get_entities_with_components(
            "PositionComponent", "VelocityComponent"
        )
        
        for entity in entities:
            pos = entity.get_component("PositionComponent")
            vel = entity.get_component("VelocityComponent")
            if pos and vel:
                pos.x += vel.dx * delta_time
                pos.y += vel.dy * delta_time
                
                # Boundary checks
                pos.x = max(0, min(pos.x, 20))
                pos.y = max(0, min(pos.y, 20))
        
        # Simple collision detection
        player = self.entity_manager.get_entity("player")
        obstacle = self.entity_manager.get_entity("obstacle")
        
        if player and obstacle:
            player_pos = player.get_component("PositionComponent")
            obstacle_pos = obstacle.get_component("PositionComponent")
            
            if player_pos and obstacle_pos:
                dx = player_pos.x - obstacle_pos.x
                dy = player_pos.y - obstacle_pos.y
                distance = (dx * dx + dy * dy) ** 0.5
                
                if distance < 1.0:
                    logger.info("Collision detected!")
                    self.score += 10
                    # Move obstacle to a new position
                    obstacle_pos.x = (obstacle_pos.x + 5) % 20
                    obstacle_pos.y = (obstacle_pos.y + 5) % 20
    
    def render(self) -> None:
        """Render the current game state."""
        self.ui.clear()
        
        # Prepare game data
        game_data = {
            "title": self.name,
            "entities": list(self.entity_manager.entities.values()),
            "stats": {
                "Score": self.score,
                "Time": f"{self.time_elapsed:.1f}s",
                "Entities": len(self.entity_manager.entities)
            },
            "message": "WASD to move, Q to quit"
        }
        
        self.ui.display_game_screen(game_data)
    
    def process_input(self) -> None:
        """Process user input."""
        import time
        if sys.stdin.isatty():
            import os
            if os.name == 'nt':
                import msvcrt
                if msvcrt.kbhit():
                    key = msvcrt.getch().decode('utf-8').lower()
                    self._handle_key(key)
            else:
                import select
                if select.select([sys.stdin], [], [], 0)[0]:
                    key = sys.stdin.read(1).lower()
                    self._handle_key(key)
    
    def _handle_key(self, key: str) -> None:
        """Handle a key press.
        
        Args:
            key: Key that was pressed
        """
        player = self.entity_manager.get_entity("player")
        if not player:
            return
        
        vel = player.get_component("VelocityComponent")
        if not vel:
            return
        
        # Movement controls (WASD)
        speed = 5.0
        if key == 'w':
            vel.dy = -speed
        elif key == 's':
            vel.dy = speed
        elif key == 'a':
            vel.dx = -speed
        elif key == 'd':
            vel.dx = speed
        elif key == ' ':  # Space to stop
            vel.dx = 0.0
            vel.dy = 0.0
        elif key == 'q':  # Quit
            logger.info("Player quit the game")
            self.game_loop.stop()
            self.game_over = True
    
    def run(self) -> None:
        """Run the game."""
        try:
            # Show title screen
            self.ui.show_title(self.name)
            
            # Initialize game
            self.initialize()
            
            # Start game loop
            self.game_loop.start()
        except KeyboardInterrupt:
            logger.info("Game interrupted by user")
        except Exception as e:
            logger.error(f"Game error: {e}")
        finally:
            logger.info("Game ended")
            
            # Show final score
            self.ui.clear()
            self.ui.show_message(f"Game Over! Final Score: {self.score}", level="success")


def main() -> None:
    """Entry point for the game."""
    # Configure logging
    logger.remove()  # Remove default handler
    logger.add(sys.stderr, level="INFO")
    logger.add("logs/game.log", rotation="1 MB")
    
    # Create logs directory if it doesn't exist
    Path("logs").mkdir(exist_ok=True)
    
    # Create and run game
    game = Game("ZeroStart Adventure")
    game.run()


if __name__ == "__main__":
    main()
EOF

    # Create a simple game launcher
    cat > src/game_launcher.py << 'EOF'
"""
Game launcher.

This module provides a simple entry point to start the game.
"""
from game.game import main

if __name__ == "__main__":
    main()
EOF

    echo -e "${GREEN}${CHECK} Main game files created${NC}"
}

create_game_test() {
    echo -e "\n${YELLOW}${ARROW} Creating game tests${NC}"
    
    # Create test file
    cat > tests/game/test_game_engine.py << 'EOF'
"""
Tests for the game engine components.

These tests verify that the game engine works correctly.
"""
import pytest
from unittest.mock import MagicMock, patch
import sys
from pathlib import Path

# Ensure src is in the path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from src.game.engine.game_loop import GameLoop
from src.game.engine.entity import (
    EntityManager, Entity, Component,
    PositionComponent, VelocityComponent, RenderComponent
)


class TestGameEngine:
    """Test the game engine components."""
    
    def test_game_loop_initialization(self):
        """Test that the game loop initializes correctly."""
        loop = GameLoop(target_fps=60, update_rate=120)
        assert loop.target_fps == 60
        assert loop.update_rate == 120
        assert loop.running is False
        assert loop.frame_time == 1.0 / 60
        assert loop.update_time == 1.0 / 120
    
    def test_entity_creation(self):
        """Test entity creation and component management."""
        entity = Entity("test_entity")
        assert entity.id == "test_entity"
        assert len(entity.components) == 0
        
        # Add components
        pos = PositionComponent(x=10, y=20)
        entity.add_component(pos)
        assert "PositionComponent" in entity.components
        assert entity.has_component("PositionComponent")
        
        # Get component
        retrieved_pos = entity.get_component("PositionComponent")
        assert retrieved_pos == pos
        assert retrieved_pos.x == 10
        assert retrieved_pos.y == 20
        
        # Remove component
        entity.remove_component("PositionComponent")
        assert not entity.has_component("PositionComponent")
        assert entity.get_component("PositionComponent") is None
    
    def test_entity_manager(self):
        """Test the entity manager."""
        manager = EntityManager()
        assert len(manager.entities) == 0
        
        # Create entities
        entity1 = manager.create_entity("entity1")
        entity2 = manager.create_entity("entity2")
        
        assert len(manager.entities) == 2
        assert manager.get_entity("entity1") is entity1
        assert manager.get_entity("entity2") is entity2
        
        # Add components
        entity1.add_component(PositionComponent())
        entity1.add_component(VelocityComponent())
        entity2.add_component(PositionComponent())
        
        # Test filtering
        entities_with_pos = manager.get_entities_with_components("PositionComponent")
        assert len(entities_with_pos) == 2
        assert entity1 in entities_with_pos
        assert entity2 in entities_with_pos
        
        entities_with_pos_vel = manager.get_entities_with_components(
            "PositionComponent", "VelocityComponent"
        )
        assert len(entities_with_pos_vel) == 1
        assert entity1 in entities_with_pos_vel
        assert entity2 not in entities_with_pos_vel
        
        # Remove entity
        manager.remove_entity("entity1")
        assert len(manager.entities) == 1
        assert manager.get_entity("entity1") is None
        assert manager.get_entity("entity2") is not None
EOF

    echo -e "${GREEN}${CHECK} Game tests created${NC}"
}

update_pyproject() {
    echo -e "\n${YELLOW}${ARROW} Updating pyproject.toml with game script${NC}"
    
    # Use Python to update pyproject.toml
    python3 -c "
import sys
try:
    import toml
except ImportError:
    print('Installing toml package...')
    import subprocess
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'toml'])
    import toml

try:
    with open('pyproject.toml', 'r') as f:
        config = toml.load(f)
except FileNotFoundError:
    config = {}

# Ensure the structure exists
if 'tool' not in config:
    config['tool'] = {}
if 'poetry' not in config['tool']:
    config['tool']['poetry'] = {}
if 'scripts' not in config['tool']['poetry']:
    config['tool']['poetry']['scripts'] = {}

# Add scripts
scripts = config['tool']['poetry']['scripts']
scripts['game'] = 'src.game_launcher:main'

with open('pyproject.toml', 'w') as f:
    toml.dump(config, f)

print('pyproject.toml updated with game script')
" || echo -e "${YELLOW}${WARNING} Could not update pyproject.toml with game script${NC}"
}

# --- Main Execution ---
show_header
activate_venv
install_game_packages
create_game_structure
create_game_engine
create_game_ui
create_main_game
create_game_test
update_pyproject

echo -e "\n${GREEN}${CHECK} Game setup complete!${NC}"
echo -e "\nYou can now run the game with: ${CYAN}poetry run game${NC}"
echo -e "You can also run the tests with: ${CYAN}poetry run pytest tests/game${NC}"