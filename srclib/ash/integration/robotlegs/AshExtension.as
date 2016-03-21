package ash.integration.robotlegs
{
	import org.swiftsuspenders.Injector;
	import ash.core.Engine;
	import ash.integration.swiftsuspenders.SwiftSuspendersEngine;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IExtension;
	import robotlegs.bender.framework.impl.UID;


	/**
	 * A Robotlegs extension to enable the use of Ash inside a Robotlegs project. This
	 * wraps the SwiftSuspenders integration, passing the Robotlegs context's injector to
	 * the engine for injecting into systems.
	 */
	public class AshExtension implements IExtension
	{
		private const _uid : String = UID.create( AshExtension );

		public function extend( context : IContext ) : void
		{
			context.injector.map( Engine ).toValue( new SwiftSuspendersEngine( context.injector as Injector ) );
		}

		public function toString() : String
		{
			return _uid;
		}
	}
}
