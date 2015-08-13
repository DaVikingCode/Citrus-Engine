package dragonBones.objects
{
	import flash.geom.Point;
	
	/** @private */
	final public class TransformFrame extends Frame
	{
		//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
		public var tweenEasing:Number;
		public var tweenRotate:int;
		public var tweenScale:Boolean;
//		public var displayIndex:int;
		public var visible:Boolean;
		
		public var global:DBTransform;
		public var transform:DBTransform;
		public var pivot:Point;
		public var scaleOffset:Point;
		
		
		public function TransformFrame()
		{
			super();
			
			tweenEasing = 10;
			tweenRotate = 0;
//			tweenScale = true;
//			displayIndex = 0;
			visible = true;
			
			global = new DBTransform();
			transform = new DBTransform();
			pivot = new Point();
			scaleOffset = new Point();
		}
		
		override public function dispose():void
		{
			super.dispose();
			global = null;
			transform = null;
			pivot = null;
			scaleOffset = null;
		}
	}
	
}