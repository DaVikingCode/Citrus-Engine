package dragonBones.objects
{
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/** @private */
	public class MovementBoneData
	{
		dragonBones_internal static const HIDE_DATA:MovementBoneData = new MovementBoneData();
		
		dragonBones_internal var _frameList:Vector.<FrameData>;
		
		public var scale:Number;
		public var delay:Number;
		
		public function MovementBoneData()
		{
			scale = 1;
			delay = 0;
			
			_frameList = new Vector.<FrameData>;
		}
		
		public function dispose():void
		{
			_frameList.length = 0;
		}
		
		public function setValues(scale:Number = 1, delay:Number = 0):void
		{
			this.scale = scale > 0?scale:1;
			this.delay = (delay || 0) % 1;
			if (this.delay > 0)
			{
				this.delay -= 1;
			}
			this.delay *= -1;
		}
	}
	
}