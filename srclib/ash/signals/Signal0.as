/*
 * Based on ideas used in Robert Penner's AS3-signals - https://github.com/robertpenner/as3-signals
 */

package ash.signals
{
	/**
	 * Provides a fast signal for use where no parameters are dispatched with the signal.
	 */
	public class Signal0 extends SignalBase
	{
		public function Signal0()
		{
		}

		public function dispatch() : void
		{
			startDispatch();
			var node : ListenerNode;
			for ( node = head; node; node = node.next )
			{
				node.listener();
				if( node.once )
				{
					remove( node.listener );
				}
			}
			endDispatch();
		}
	}
}
