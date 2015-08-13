package dragonBones.objects
{
	import flash.geom.Point;
	
	public final class TransformTimeline extends Timeline
	{
		public var name:String;
		public var transformed:Boolean;
		
		//第一帧的Transform
		public var originTransform:DBTransform;
		
		//第一帧的骨头的轴点
		public var originPivot:Point;
		
		public var offset:Number;
		
		public function TransformTimeline()
		{
			super();
			
			originTransform = new DBTransform();
			originTransform.scaleX = 1;
			originTransform.scaleY = 1;
			
			originPivot = new Point();
			offset = 0;
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			originTransform = null;
			originPivot = null;
		}
	}
}