package dragonBones.objects
{
	/** @private */
	public class Frame
	{
		public var position:Number;
		public var duration:Number;
		
		public var action:String;
		public var event:String;
		public var sound:String;
		
		public function Frame()
		{
			position = 0;
			duration = 0;
		}
		
		public function dispose():void
		{
		}
	}
}