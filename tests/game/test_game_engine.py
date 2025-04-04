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
