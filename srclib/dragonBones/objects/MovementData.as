package dragonBones.objects
{
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/** @private */
	public class MovementData
	{
		private var _movementBoneDatas:Object;
		dragonBones_internal var _movementFrameList:Vector.<MovementFrameData>;
		
		internal var _name:String;
		public function get name():String
		{
			return _name;
		}
		
		public var duration:int;
		public var durationTo:int;
		public var durationTween:int;
		public var loop:Boolean;
		public var tweenEasing:Number;
		
		public function MovementData()
		{
			duration = 1;
			durationTo = 0;
			durationTween = 0;
			_movementBoneDatas = { };
			_movementFrameList = new Vector.<MovementFrameData>;
		}
		
		public function setValues(_duration:int = 1, _durationTo:int = 0, _durationTween:int = 0, _loop:Boolean = false, _tweenEasing:Number = NaN):void
		{
			duration = _duration > 0?_duration:1;
			durationTo = _durationTo >= 0?_durationTo:0;
			durationTween = _durationTween >= 0?_durationTween:0;
			loop = _loop;
			//the default NaN means no tween
			tweenEasing = _tweenEasing;
		}
		
		public function dispose():void
		{
			for each(var movementBoneData:MovementBoneData in _movementBoneDatas)
			{
				movementBoneData.dispose();
			}
			movementBoneData = null;
			_movementFrameList = null;
		}
		
		public function getMovementBoneData(name:String):MovementBoneData
		{
			return _movementBoneDatas[name];
		}
		
		internal function addMovementBoneData(data:MovementBoneData):void
		{
			var name:String = data.name;
			_movementBoneDatas[name] = data;
		}
	}
	
}