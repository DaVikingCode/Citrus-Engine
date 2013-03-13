package dragonBones.objects
{
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/** @private */
	public class AnimationData
	{
		dragonBones_internal var _movementDataList:DataList;
		
		public function get movementList():Vector.<String>
		{
			return _movementDataList.dataNames.concat();
		}
		
		public function AnimationData()
		{
			_movementDataList = new DataList();
		}
		
		public function dispose():void
		{
			for each(var movementName:String in _movementDataList.dataNames)
			{
				var movementData:MovementData = _movementDataList.getData(movementName) as MovementData;
				movementData.dispose();
			}
			
			_movementDataList.dispose();
		}
		
		public function getMovementData(name:String):MovementData
		{
			return _movementDataList.getData(name) as MovementData;
		}
	}
	
}