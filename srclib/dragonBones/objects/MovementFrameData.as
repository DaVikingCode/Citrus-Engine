package dragonBones.objects
{
	/** @private */
	public class MovementFrameData
	{
		public var duration:Number;
		public var movement:String;
		public var event:String;
		public var sound:String;
		public var soundEffect:String;
		
		public function MovementFrameData()
		{
		}
		
		public function setValues(duration:Number, movement:String, event:String, sound:String):void
		{
			this.duration = duration;
			this.movement = movement;
			this.event = event;
			this.sound = sound;
		}
	}
}