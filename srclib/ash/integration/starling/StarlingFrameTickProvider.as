package ash.integration.starling
{
	import ash.signals.Signal1;
	import ash.tick.ITickProvider;
	import starling.animation.IAnimatable;
	import starling.animation.Juggler;

	/**
	 * Uses a Starling juggler to provide a frame tick where the frame duration is the time since the previous frame.
	 * There is a maximum frame time parameter in the constructor that can be used to limit
	 * the longest period a frame can be.
	 */
	public class StarlingFrameTickProvider extends Signal1 implements ITickProvider, IAnimatable
	{
		private var juggler : Juggler;
		private var maximumFrameTime : Number;
		private var isPlaying : Boolean = false;
		
		/**
		 * Applies a time adjustement factor to the tick, so you can slow down or speed up the entire engine.
		 * The update tick time is multiplied by this value, so a value of 1 will run the engine at the normal rate.
		 */
		public var timeAdjustment : Number = 1;
		
		public function StarlingFrameTickProvider( juggler : Juggler, maximumFrameTime : Number = Number.MAX_VALUE )
		{
			super( Number );
			this.juggler = juggler;
			this.maximumFrameTime = maximumFrameTime;
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
			if( frameTime > maximumFrameTime )
			{
				frameTime = maximumFrameTime;
			}
			dispatch( frameTime * timeAdjustment );
		}

		public function get playing() : Boolean
		{
			return isPlaying;
		}
	}
}
