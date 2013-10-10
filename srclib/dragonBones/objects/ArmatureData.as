package dragonBones.objects
{
	final public class ArmatureData
	{
		public var name:String;
		
		private var _boneDataList:Vector.<BoneData>;
		public function get boneDataList():Vector.<BoneData>
		{
			return _boneDataList;
		}
		
		private var _skinDataList:Vector.<SkinData>;
		public function get skinDataList():Vector.<SkinData>
		{
			return _skinDataList;
		}
		
		private var _animationDataList:Vector.<AnimationData>;
		public function get animationDataList():Vector.<AnimationData>
		{
			return _animationDataList;
		}
		
		public function ArmatureData()
		{
			_boneDataList = new Vector.<BoneData>(0, true);
			_skinDataList = new Vector.<SkinData>(0, true);
			_animationDataList = new Vector.<AnimationData>(0, true);
		}
		
		public function dispose():void
		{
			var i:int = _boneDataList.length;
			while(i --)
			{
				_boneDataList[i].dispose();
			}
			i = _skinDataList.length;
			while(i --)
			{
				_skinDataList[i].dispose();
			}
			i = _animationDataList.length;
			while(i --)
			{
				_animationDataList[i].dispose();
			}
			_boneDataList.fixed = false;
			_boneDataList.length = 0;
			_skinDataList.fixed = false;
			_skinDataList.length = 0;
			_animationDataList.fixed = false;
			_animationDataList.length = 0;
			_boneDataList = null;
			_skinDataList = null;
			_animationDataList = null;
		}
		
		public function getBoneData(boneName:String):BoneData
		{
			var i:int = _boneDataList.length;
			while(i --)
			{
				if(_boneDataList[i].name == boneName)
				{
					return _boneDataList[i];
				}
			}
			return null;
		}
		
		public function getSkinData(skinName:String):SkinData
		{
			if(!skinName)
			{
				return _skinDataList[0];
			}
			var i:int = _skinDataList.length;
			while(i --)
			{
				if(_skinDataList[i].name == skinName)
				{
					return _skinDataList[i];
				}
			}
			
			return null;
		}
		
		public function getAnimationData(animationName:String):AnimationData
		{
			var i:int = _animationDataList.length;
			while(i --)
			{
				if(_animationDataList[i].name == animationName)
				{
					return _animationDataList[i];
				}
			}
			return null;
		}
		
		public function addBoneData(boneData:BoneData):void
		{
			if(!boneData)
			{
				throw new ArgumentError();
			}
			
			if (_boneDataList.indexOf(boneData) < 0)
			{
				_boneDataList.fixed = false;
				_boneDataList[_boneDataList.length] = boneData;
				_boneDataList.fixed = true;
			}
			else
			{
				throw new ArgumentError();
			}
		}
		
		public function addSkinData(skinData:SkinData):void
		{
			if(!skinData)
			{
				throw new ArgumentError();
			}
			
			if(_skinDataList.indexOf(skinData) < 0)
			{
				_skinDataList.fixed = false;
				_skinDataList[_skinDataList.length] = skinData;
				_skinDataList.fixed = true;
			}
			else
			{
				throw new ArgumentError();
			}
		}
		
		public function addAnimationData(animationData:AnimationData):void
		{
			if(!animationData)
			{
				throw new ArgumentError();
			}
			
			if(_animationDataList.indexOf(animationData) < 0)
			{
				_animationDataList.fixed = false;
				_animationDataList[_animationDataList.length] = animationData;
				_animationDataList.fixed = true;
			}
		}
		
		public function sortBoneDataList():void
		{
			var i:int = _boneDataList.length;
			if(i == 0)
			{
				return;
			}
			
			var helpArray:Array = [];
			while(i --)
			{
				var boneData:BoneData = _boneDataList[i];
				var level:int = 0;
				var parentData:BoneData = boneData;
				while(parentData && parentData.parent)
				{
					level ++;
					parentData = getBoneData(parentData.parent);
				}
				helpArray[i] = {level:level, boneData:boneData};
			}
			
			helpArray.sortOn("level", Array.NUMERIC);
			
			i = helpArray.length;
			while(i --)
			{
				_boneDataList[i] = helpArray[i].boneData;
			}
		}
	}
}