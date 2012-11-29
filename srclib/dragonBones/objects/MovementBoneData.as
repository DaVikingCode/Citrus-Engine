package dragonBones.objects
{
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/** @private */
	public class MovementBoneData
	{
		dragonBones_internal var _frameList:Vector.<FrameData>;
		
		internal var _duration:int;
		public function get duration():int
		{
			return _duration;
		}
		
		internal var _name:String;
		public function get name():String
		{
			return _name;
		}
		
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
			_frameList = null;
		}
		
		public function setValues(_scale:Number = 1, _delay:Number = 0):void
		{
			scale = _scale > 0?_scale:1;
			delay = (_delay || 0) % 1;
			if (delay > 0)
			{
				delay -= 1;
			}
		}
		
	}
	
}