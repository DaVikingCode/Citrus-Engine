package ash.integration.swiftsuspenders
{
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import org.swiftsuspenders.Injector;

	/**
	 * A custom engine class for games that use SwiftSuspenders for dependency injection.
	 * Pass a SwiftSuspenders injector to the constructor, and the engine will automatically
	 * apply injection rules to the systems when they are added to the engine.
	 */
	public class SwiftSuspendersEngine extends Engine
	{
		protected var injector : Injector;
		
		public function SwiftSuspendersEngine( injector : Injector )
		{
			super();
			this.injector = injector;
			injector.map( NodeList ).toProvider( new NodeListProvider( this ) );
		}
		
		override public function addSystem( system : System, priority : int ) : void
		{
			injector.injectInto( system );
			super.addSystem( system, priority );
		}
	}
}
