package ash.tick
{
	/**
	 * The interface for a tick provider. A tick provider dispatches a regular update tick
	 * to act as the heartbeat for the engine. It has methods to start and stop the tick and
	 * to add and remove listeners for the tick.
	 */
	public interface ITickProvider
	{
		function get playing() : Boolean;
		
		function add( listener : Function ) : void;
		function remove( listener : Function ) : void;
		
		function start() : void;
		function stop() : void;
	}
}
