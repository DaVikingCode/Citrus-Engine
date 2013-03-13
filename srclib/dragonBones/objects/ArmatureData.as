package dragonBones.objects
{
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/** @private */
	public class ArmatureData
	{
		dragonBones_internal var _boneDataList:DataList;
		
		public function get boneNames():Vector.<String>
		{
			return _boneDataList.dataNames.concat();
		}
		
		public function ArmatureData()
		{
			_boneDataList = new DataList();
		}
		
		public function dispose():void
		{
			for each(var boneName:String in _boneDataList.dataNames)
			{
				var boneData:BoneData = _boneDataList.getData(boneName) as BoneData;
				boneData.dispose();
			}
			
			_boneDataList.dispose();
		}
		
		public function getBoneData(name:String):BoneData
		{
			return _boneDataList.getData(name) as BoneData;
		}
		
		public function updateBoneList():void
		{
			var boneNames:Vector.<String> = _boneDataList.dataNames;
			
			var sortList:Array = [];
			for each(var boneName:String in boneNames)
			{
				var boneData:BoneData = _boneDataList.getData(boneName) as BoneData;
				var levelValue:int = boneData.node.z;
				var level:int = 0;
				while(boneData)
				{
					level ++;
					levelValue += 1000 * level;
					boneData = getBoneData(boneData.parent);
				}
				sortList.push({level:levelValue, boneName:boneName});
			}
			
			var length:int = sortList.length;
			if(length > 0)
			{
				sortList.sortOn("level", Array.NUMERIC);
				boneNames.length = 0;
				var i:int = 0;
				while(i < length)
				{
					boneNames[i] = sortList[i].boneName;
					i ++;
				}
			}
		}
	}
}