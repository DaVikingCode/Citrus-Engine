package ash.tick
{
	import ash.signals.Signal1;
	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * Uses the enter frame event to provide a frame tick with a fixed frame duration. This tick ignores the length of
	 * the frame and dispatches the same time period for each tick.
	 */
	public class FixedTickProvider extends Signal1 implements ITickProvider
	{
		private var displayObject : DisplayObject;
		private var frameTime : Number;
		private var isPlaying : Boolean = false;
		
		/**
		 * Applies a time adjustement factor to the tick, so you can slow down or speed up the entire engine.
		 * The update tick time is multiplied by this value, so a value of 1 will run the engine at the normal rate.
		 */
		public var timeAdjustment : Number = 1;
		
		public function FixedTickProvider( displayObject : DisplayObject, frameTime : Number )
		{
			super( Number );
			this.displayObject = displayObject;
			this.frameTime = frameTime;
		}
		
		public function start() : void
		{
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
			dispatch( frameTime * timeAdjustment );
		}

		public function get playing() : Boolean
		{
			return isPlaying;
		}
	}
}
