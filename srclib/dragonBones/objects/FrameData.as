package dragonBones.objects
{
	
	/** @private */
	final public class FrameData extends TweenNode
	{
		public var duration:int;
		
		public var tweenEasing:Number;
		
		public var displayIndex:int;
		public var movement:String;
		
		public var event:String;
		
		public var sound:String;
		public var soundEffect:String;
		
		public function FrameData()
		{
			super();
			
			duration = 1;
			//NaN: no tweens;  -1: ease out; 0: linear; 1: ease in; 2: ease in&out
			tweenEasing = 0;
		}
	}
	
}