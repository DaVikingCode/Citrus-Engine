package dragonBones.objects
{
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	/** @private */
	final public class TransformFrame extends Frame
	{
		public var tweenEasing:Number;
		public var tweenRotate:int;
		public var displayIndex:int;
		public var visible:Boolean;
		public var zOrder:Number;
		
		public var global:DBTransform;
		public var transform:DBTransform;
		public var pivot:Point;
		public var color:ColorTransform;
		
		
		public function TransformFrame()
		{
			super();
			
			tweenEasing = 0;
			tweenRotate = 0;
			displayIndex = 0;
			visible = true;
			zOrder = NaN;
			
			global = new DBTransform();
			transform = new DBTransform();
			pivot = new Point();
		}
		
		override public function dispose():void
		{
			super.dispose();
			global = null;
			transform = null;
			//SkeletonData pivots
			pivot = null;
			color = null;
		}
	}
	
}