package dragonBones.objects
{
	
	/** @private */
	public class ArmatureData
	{
		private var _boneDatas:Object;
		private var _boneList:Array;
		
		internal var _name:String;
		public function get name():String
		{
			return _name;
		}
		
		public function get totalBonws():uint
		{
			return _boneList.length;
		}
		
		public function get boneList():Array
		{
			return _boneList.concat();
		}
		
		public function ArmatureData()
		{
			_name = name;
			_boneDatas = { };
		}
		
		public function dispose():void
		{
			for each(var boneData:BoneData in _boneDatas)
			{
				boneData.dispose();
			}
			_boneDatas = null;
			_boneList = null;
		}
		
		public function getBoneData(name:String):BoneData
		{
			return _boneDatas[name];
		}
		
		public function getBoneDataAt(index:uint):BoneData
		{
			return _boneDatas[_boneList[index]];
		}
		
		internal function addBoneData(data:BoneData):void
		{
			var name:String = data.name;
			_boneDatas[name] = data;
		}
		
		internal function updateBoneList():void
		{
			_boneList = [];
			for(var boneName:String in _boneDatas)
			{
				var depth:int = 0;
				var parentData:BoneData = _boneDatas[boneName];
				while(parentData)
				{
					depth ++;
					parentData = _boneDatas[parentData.parent];
				}
				_boneList.push({depth:depth, boneName:boneName});
			}
			_boneList.sortOn("depth", Array.NUMERIC);
			
			var i:int = _boneList.length;
			while(-- i >= 0)
			{
				_boneList[i] = _boneList[i].boneName;
			}
		}
	}
}