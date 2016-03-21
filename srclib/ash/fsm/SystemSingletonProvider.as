package ash.fsm
{
	import ash.core.System;

	/**
	 * This System provider always returns the same instance of the System. The instance
	 * is created when first required and is of the type passed in to the constructor.
	 */
	public class SystemSingletonProvider implements ISystemProvider
	{
		private var componentType : Class;
		private var instance : System;
		private var systemPriority : int = 0;

		/**
		 * Constructor
		 *
		 * @param type The type of the single System instance
		 */
		public function SystemSingletonProvider( type : Class )
		{
			this.componentType = type;
		}

		/**
		 * Used to request a System from this provider
		 *
		 * @return The single instance
		 */
		public function getSystem() : System
		{
			if ( !instance )
			{
				instance = new componentType();
			}
			return instance;
		}

		/**
		 * Used to compare this provider with others. Any provider that returns the same single
		 * instance will be regarded as equivalent.
		 *
		 * @return The single instance
		 */
		public function get identifier() : *
		{
			return getSystem();
		}

		/**
		 * The priority at which the System should be added to the Engine
		 */
		public function get priority() : int
		{
			return systemPriority;
		}

		/**
		 * @private
		 */
		public function set priority( value : int ) : void
		{
			systemPriority = value;
		}
	}
}
