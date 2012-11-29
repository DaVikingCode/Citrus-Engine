package dragonBones.objects
{
	/** @private */
	public class MovementFrameData
	{
		public var start:int;
		public var duration:int;
		public var movement:String;
		public var event:String;
		public var sound:String;
		public var soundEffect:String;
		
		public function MovementFrameData()
		{
		}
		
		public function setValues(start:int, duration:int, movement:String, event:String, sound:String):void
		{
			this.start = start;
			this.duration = duration;
			this.movement = movement;
			this.event = event;
			this.sound = sound;
		}
	}
}