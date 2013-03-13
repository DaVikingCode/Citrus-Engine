package dragonBones.objects
{
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/** @private */
	public class MovementData
	{
		dragonBones_internal var _movementBoneDataList:DataList;
		dragonBones_internal var _movementFrameList:Vector.<MovementFrameData>;
		
		public var duration:Number;
		public var durationTo:Number;
		public var durationTween:Number;
		public var loop:Boolean;
		public var tweenEasing:Number;
		
		public function MovementData()
		{
			duration = 0;
			durationTo = 0;
			durationTween = 0;
			
			_movementBoneDataList = new DataList();
			_movementFrameList = new Vector.<MovementFrameData>;
		}
		
		public function dispose():void
		{
			for each(var movementBoneName:String in _movementBoneDataList.dataNames)
			{
				var movementBoneData:MovementBoneData = _movementBoneDataList.getData(movementBoneName) as MovementBoneData;
				movementBoneData.dispose();
			}
			
			_movementBoneDataList.dispose();
			_movementFrameList.length = 0;
		}
		
		public function getMovementBoneData(name:String):MovementBoneData
		{
			return _movementBoneDataList.getData(name) as MovementBoneData;
		}
	}
	
}