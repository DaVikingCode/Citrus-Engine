package ash.fsm
{

	/**
	 * This component provider always returns the same instance of the component. The instance
	 * is passed to the provider at initialisation.
	 */
	public class ComponentInstanceProvider implements IComponentProvider
	{
		private var instance : *;
		
		/**
		 * Constructor
		 * 
		 * @param instance The instance to return whenever a component is requested.
		 */
		public function ComponentInstanceProvider( instance : * )
		{
			this.instance = instance;
		}
		
		/**
		 * Used to request a component from this provider
		 * 
		 * @return The instance
		 */
		public function getComponent() : *
		{
			return instance;
		}
		
		/**
		 * Used to compare this provider with others. Any provider that returns the same component
		 * instance will be regarded as equivalent.
		 * 
		 * @return The instance
		 */
		public function get identifier() : *
		{
			return instance;
		}
	}
}
