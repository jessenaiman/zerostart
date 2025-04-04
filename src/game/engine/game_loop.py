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
