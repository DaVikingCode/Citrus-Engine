package ash.integration.starling
{
	import ash.signals.Signal1;
	import ash.tick.ITickProvider;
	import starling.animation.IAnimatable;
	import starling.animation.Juggler;

	/**
	 * Uses a Starling juggler to provide a frame tick with a fixed frame duration. This tick ignores the length of
	 * the frame and dispatches the same time period for each tick.
	 */
	public class StarlingFixedTickProvider extends Signal1 implements ITickProvider, IAnimatable
	{
		private var juggler : Juggler;
		private var frameTime : Number;
		private var isPlaying : Boolean = false;
		
		/**
		 * Applies a time adjustement factor to the tick, so you can slow down or speed up the entire engine.
		 * The update tick time is multiplied by this value, so a value of 1 will run the engine at the normal rate.
		 */
		public var timeAdjustment : Number = 1;
		
		public function StarlingFixedTickProvider( juggler : Juggler, frameTime : Number )
		{
			super( Number );
			this.juggler = juggler;
			this.frameTime = frameTime;
		}
		
		public function start() : void
		{
			juggler.add( this );
			isPlaying = true;
		}
		
		public function stop() : void
		{
			isPlaying = false;
			juggler.remove( this );
		}
		
		public function advanceTime( frameTime : Number ) : void
		{
			dispatch( frameTime * timeAdjustment );
		}

		public function get playing() : Boolean
		{
			return isPlaying;
		}
	}
}
