package ash.tick
{
	import ash.signals.Signal1;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getTimer;

	/**
	 * Uses the enter frame event to provide a frame tick where the frame duration is the time since the previous frame.
	 * There is a maximum frame time parameter in the constructor that can be used to limit
	 * the longest period a frame can be.
	 */
	public class FrameTickProvider extends Signal1 implements ITickProvider
	{
		private var displayObject : DisplayObject;
		private var previousTime : Number;
		private var maximumFrameTime : Number;
		private var isPlaying : Boolean = false;
		
		/**
		 * Applies a time adjustement factor to the tick, so you can slow down or speed up the entire engine.
		 * The update tick time is multiplied by this value, so a value of 1 will run the engine at the normal rate.
		 */
		public var timeAdjustment : Number = 1;
		
		public function FrameTickProvider( displayObject : DisplayObject, maximumFrameTime : Number = Number.MAX_VALUE )
		{
			super( Number );
			this.displayObject = displayObject;
			this.maximumFrameTime = maximumFrameTime;
		}
		
		public function start() : void
		{
			previousTime = getTimer();
			displayObject.addEventListener( Event.ENTER_FRAME, dispatchTick );
			isPlaying = true;
		}
		
		public function stop() : void
		{
			isPlaying = false;
			displayObject.removeEventListener( Event.ENTER_FRAME, dispatchTick );
		}
		
		private function dispatchTick( event : Event ) : void
		{
			var temp : Number = previousTime;
			previousTime = getTimer();
			var frameTime : Number = ( previousTime - temp ) / 1000;
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
