package ash.fsm
{
	import ash.core.Entity;
	import flash.utils.Dictionary;


	/**
	 * This is a state machine for an entity. The state machine manages a set of states,
	 * each of which has a set of component providers. When the state machine changes the state, it removes
	 * components associated with the previous state and adds components associated with the new state.
	 */
	public class EntityStateMachine
	{
		private var states : Dictionary;
		/**
		 * The current state of the state machine.
		 */
		private var currentState : EntityState;
		/**
		 * The entity whose state machine this is
		 */
		public var entity : Entity;

		/**
		 * Constructor. Creates an EntityStateMachine.
		 */
		public function EntityStateMachine( entity : Entity ) : void
		{
			this.entity = entity;
			states = new Dictionary();
		}

		/**
		 * Add a state to this state machine.
		 * 
		 * @param name The name of this state - used to identify it later in the changeState method call.
		 * @param state The state.
		 * @return This state machine, so methods can be chained.
		 */
		public function addState( name : String, state : EntityState ) : EntityStateMachine
		{
			states[ name ] = state;
			return this;
		}
		
		/**
		 * Create a new state in this state machine.
		 * 
		 * @param name The name of the new state - used to identify it later in the changeState method call.
		 * @return The new EntityState object that is the state. This will need to be configured with
		 * the appropriate component providers.
		 */
		public function createState( name : String ) : EntityState
		{
			var state : EntityState = new EntityState();
			states[ name ] = state;
			return state;
		}

		/**
		 * Change to a new state. The components from the old state will be removed and the components
		 * for the new state will be added.
		 * 
		 * @param name The name of the state to change to.
		 */
		public function changeState( name : String ) : void
		{
			var newState : EntityState = states[ name ];
			if ( !newState )
			{
				throw( new Error( "Entity state " + name + " doesn't exist" ) );
			}
			if( newState == currentState )
			{
				newState = null;
				return;
			}
			var toAdd : Dictionary;
			var type : Class;
			var t : *;
			if ( currentState )
			{
				toAdd = new Dictionary();
				for( t in newState.providers )
				{
					type = Class( t );
					toAdd[ type ] = newState.providers[ type ];
				}
				for( t in currentState.providers )
				{
					type = Class( t );
					var other : IComponentProvider = toAdd[ type ];

					if ( other && other.identifier == currentState.providers[ type ].identifier )
					{
						delete toAdd[ type ];
					}
					else
					{
						entity.remove( type );
					}
				}
			}
			else
			{
				toAdd = newState.providers;
			}
			for( t in toAdd )
			{
				type = Class( t );
				entity.add( IComponentProvider( toAdd[ type ] ).getComponent(), type );
			}
			currentState = newState;
		}
	}
}
