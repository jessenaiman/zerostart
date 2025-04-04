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
