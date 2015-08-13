package dragonBones.objects
{
	import flash.geom.Point;
	
	public final class SlotTimeline extends Timeline
	{
		public var name:String;
		public var transformed:Boolean;
		
		public var offset:Number;
		
		public function SlotTimeline()
		{
			super();
			offset = 0;
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}