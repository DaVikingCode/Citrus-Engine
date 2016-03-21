package ash.signals
{
	/**
	 * A node in the list of listeners in a signal.
	 */
	internal class ListenerNode
	{
		public var previous : ListenerNode;
		public var next : ListenerNode;
		public var listener : Function;
		public var once : Boolean;
	}
}
