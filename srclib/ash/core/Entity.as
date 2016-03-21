package ash.core
{
	import ash.signals.Signal2;

	import flash.utils.Dictionary;

	/**
	 * An entity is composed from components. As such, it is essentially a collection object for components. 
	 * Sometimes, the entities in a game will mirror the actual characters and objects in the game, but this 
	 * is not necessary.
	 * 
	 * <p>Components are simple value objects that contain data relevant to the entity. Entities
	 * with similar functionality will have instances of the same components. So we might have 
	 * a position component</p>
	 * 
	 * <p><code>public class PositionComponent
	 * {
	 *   public var x : Number;
	 *   public var y : Number;
	 * }</code></p>
	 * 
	 * <p>All entities that have a position in the game world, will have an instance of the
	 * position component. Systems operate on entities based on the components they have.</p>
	 */
	public class Entity
	{
		private static var nameCount : int = 0;
		
		/**
		 * Optional, give the entity a name. This can help with debugging and with serialising the entity.
		 */
		private var _name : String;
		/**
		 * This signal is dispatched when a component is added to the entity.
		 */
		public var componentAdded : Signal2;
		/**
		 * This signal is dispatched when a component is removed from the entity.
		 */
		public var componentRemoved : Signal2;
		/**
		 * Dispatched when the name of the entity changes. Used internally by the engine to track entities based on their names.
		 */
		internal var nameChanged : Signal2;
		
		internal var previous : Entity;
		internal var next : Entity;
		internal var components : Dictionary;

		/**
		 * The constructor
		 * 
		 * @param name The name for the entity. If left blank, a default name is assigned with the form _entityN where N is an integer.
		 */
		public function Entity( name : String = "" )
		{
			componentAdded = new Signal2( Entity, Class );
			componentRemoved = new Signal2( Entity, Class );
			nameChanged = new Signal2( Entity, String );
			components = new Dictionary();
			if( name )
			{
				_name = name;
			}
			else
			{
				_name = "_entity" + (++nameCount);
			}
		}
		
		/**
		 * All entities have a name. If no name is set, a default name is used. Names are used to
		 * fetch specific entities from the engine, and can also help to identify an entity when debugging.
		 */
		public function get name() : String
		{
			return _name;
		}
		public function set name( value : String ) : void
		{
			if( _name != value )
			{
				var previous : String = _name;
				_name = value;
				nameChanged.dispatch( this, previous );
			}
		}

		/**
		 * Add a component to the entity.
		 * 
		 * @param component The component object to add.
		 * @param componentClass The class of the component. This is only necessary if the component
		 * extends another component class and you want the framework to treat the component as of 
		 * the base class type. If not set, the class type is determined directly from the component.
		 * 
		 * @return A reference to the entity. This enables the chaining of calls to add, to make
		 * creating and configuring entities cleaner. e.g.
		 * 
		 * <code>var entity : Entity = new Entity()
		 *     .add( new Position( 100, 200 )
		 *     .add( new Display( new PlayerClip() );</code>
		 */
		public function add( component : Object, componentClass : Class = null ) : Entity
		{
			if ( !componentClass )
			{
				componentClass = Class( component.constructor );
			}
			if ( components[ componentClass ] )
			{
				remove( componentClass );
			}
			components[ componentClass ] = component;
			componentAdded.dispatch( this, componentClass );
			return this;
		}

		/**
		 * Remove a component from the entity.
		 * 
		 * @param componentClass The class of the component to be removed.
		 * @return the component, or null if the component doesn't exist in the entity
		 */
		public function remove( componentClass : Class ) : *
		{
			var component : * = components[ componentClass ];
			if ( component )
			{
				delete components[ componentClass ];
				componentRemoved.dispatch( this, componentClass );
				return component;
			}
			return null;
		}

		/**
		 * Get a component from the entity.
		 * 
		 * @param componentClass The class of the component requested.
		 * @return The component, or null if none was found.
		 */
		public function get( componentClass : Class ) : *
		{
			return components[ componentClass ];
		}
		
		/**
		 * Get all components from the entity.
		 * 
		 * @return An array containing all the components that are on the entity.
		 */
		public function getAll() : Array
		{
			var componentArray : Array = new Array();
			for each( var component : * in components )
			{
				componentArray[ componentArray.length ] = component;
			}
			return componentArray;
		}

		/**
		 * Does the entity have a component of a particular type.
		 * 
		 * @param componentClass The class of the component sought.
		 * @return true if the entity has a component of the type, false if not.
		 */
		public function has( componentClass : Class ) : Boolean
		{
			return components[ componentClass ] != null;
		}
	}
}
