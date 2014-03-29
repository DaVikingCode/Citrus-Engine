package citrus.core.starling 
{
	import starling.animation.Juggler;
	/**
	 * A Custom Starling Juggler used by CitrusEngine for pausing.
	 */
	public class CitrusStarlingJuggler extends Juggler
	{
		protected var _paused:Boolean = false;
		public function CitrusStarlingJuggler() 
		{
			super();
		}
		
		override public function advanceTime(timeDelta:Number):void
		{
			if(!_paused)
				super.advanceTime(timeDelta);
		}
		
		public function set paused(value:Boolean):void
		{
			_paused = value;
		}
		
		public function get paused():Boolean
		{
			return _paused;
		}
		
	}

}