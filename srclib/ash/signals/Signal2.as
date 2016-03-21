/*
 * Based on ideas used in Robert Penner's AS3-signals - https://github.com/robertpenner/as3-signals
 */

package ash.signals
{
	/**
	 * Provides a fast signal for use where two parameters are dispatched with the signal.
	 */
	public class Signal2 extends SignalBase
	{
		private var type1 : Class;
		private var type2 : Class;

		public function Signal2( type1 : Class, type2 : Class )
		{
			this.type1 = type1;
			this.type2 = type2;
		}

		public function dispatch( object1 : *, object2 : * ) : void
		{
			startDispatch();
			var node : ListenerNode;
			for ( node = head; node; node = node.next )
			{
				node.listener( object1, object2 );
				if( node.once )
				{
					remove( node.listener );
				}
			}
			endDispatch();
		}
	}
}
