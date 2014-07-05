package citrus.core.starling 
{
	import starling.animation.Juggler;
	
	/**
	 * A Custom Starling Juggler used by CitrusEngine for pausing.
	 */
	public class CitrusStarlingJuggler extends Juggler
	{
		public var paused:Boolean = false;
		
		public function CitrusStarlingJuggler() 
		{
			super();
		}
		
		override public function advanceTime(timeDelta:Number):void
		{
			if (!paused)
				super.advanceTime(timeDelta);
		}
		
	}

}