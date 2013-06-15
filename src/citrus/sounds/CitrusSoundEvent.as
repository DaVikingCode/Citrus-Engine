package citrus.sounds 
{
	import flash.events.Event;

	public class CitrusSoundEvent
	{
		public static const SOUND_COMPLETE:String = "SOUND_COMPLETE";
		public static const REPEAT_COMPLETE:String = "REPEAT_COMPLETE";
		
		public var type:String;
		public var soundName:String;
		public var timesToRepeat:uint;
		public var repeatCount:uint;
		public var repeatLeft:uint;
		
		public function CitrusSoundEvent(type:String,sound:CitrusSound) 
		{
			this.type = type;
			soundName = sound.name;
			timesToRepeat = sound.timesToRepeat;
			repeatCount = sound.repeatCount;
			repeatLeft = timesToRepeat - repeatCount;
		}
		
	}

}