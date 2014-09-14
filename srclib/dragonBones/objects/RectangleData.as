package dragonBones.objects
{
	import flash.geom.Point;
	
	public final class RectangleData implements IAreaData
	{
		public var name:String;
		
		public var width:Number;
		public var height:Number;
		public var transform:DBTransform;
		public var pivot:Point;
		
		public function RectangleData()
		{
			width = 0;
			height = 0;
			transform = new DBTransform();
			pivot = new Point();
		}
		
		public function dispose():void
		{
			transform = null;
			pivot = null;
		}
	}
}