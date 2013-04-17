package dragonBones.objects
{
	import flash.geom.ColorTransform;
	
	/** @private */
	final public class FrameData
	{
		public var duration:Number;
		public var tweenEasing:Number;
		public var tweenRotate:int;
		public var displayIndex:int;
		public var movement:String;
		public var visible:Boolean;
		public var event:String;
		public var sound:String;
		public var soundEffect:String;
		public var node:BoneTransform;
		public var colorTransform:ColorTransform;
		
		public function FrameData()
		{
			duration = 0;
			//NaN: no tweens;  -1: ease out; 0: linear; 1: ease in; 2: ease in&out
			tweenEasing = 0;
			node = new BoneTransform();
			colorTransform = new ColorTransform();
		}
	}

}