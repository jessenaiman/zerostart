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
