package ash.fsm
{
	/**
	 * This component provider calls a function to get the component instance. The function must
	 * return a single component of the appropriate type.
	 */
	public class DynamicComponentProvider  implements IComponentProvider
	{
		private var _closure : Function;

		/**
		 * Constructor
		 * 
		 * @param closure The function that will return the component instance when called.
		 */
		public function DynamicComponentProvider( closure : Function )
		{
			_closure = closure;
		}

		/**
		 * Used to request a component from this provider
		 * 
		 * @return The instance returned by calling the function
		 */
		public function getComponent() : *
		{
			return _closure();
		}

		/**
		 * Used to compare this provider with others. Any provider that uses the function or method 
		 * closure to provide the instance is regarded as equivalent.
		 * 
		 * @return The function
		 */
		public function get identifier() : *
		{
			return _closure;
		}
	}
}