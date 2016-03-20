package dragonBones.objects
{
	/** @private */
	public class Frame
	{
		public var position:int;
		public var duration:int;
		
		public var action:String;
		public var event:String;
		public var sound:String;
		public var curve:CurveData;
		
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