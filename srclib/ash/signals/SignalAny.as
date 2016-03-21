/*
 * Based on ideas used in Robert Penner's AS3-signals - https://github.com/robertpenner/as3-signals
 */

package ash.signals
{
	/**
	 * Provides a fast signal for use where any number of parameters are dispatched with the signal.
	 */
	public class SignalAny extends SignalBase
	{
		protected var classes : Array;

		public function SignalAny( ...classes )
		{
			this.classes = classes;
		}

		public function dispatch( ...objects ) : void
		{
			startDispatch();
			var node : ListenerNode;
			for ( node = head; node; node = node.next )
			{
				node.listener.apply( null, objects );
				if( node.once )
				{
					remove( node.listener );
				}
			}
			endDispatch();
		}
	}
}
