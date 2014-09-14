package dragonBones.objects 
{
	import flash.geom.Point;

	public class SkeletonData
	{
		public var name:String;
		
		private var _subTexturePivots:Object;
		
		public function get armatureNames():Vector.<String>
		{
			var nameList:Vector.<String> = new Vector.<String>;
			for each(var armatureData:ArmatureData in _armatureDataList)
			{
				nameList[nameList.length] = armatureData.name;
			}
			return nameList;
		}
		
		private var _armatureDataList:Vector.<ArmatureData>;
		public function get armatureDataList():Vector.<ArmatureData>
		{
			return _armatureDataList;
		}
		
		public function SkeletonData()
		{
			_armatureDataList = new Vector.<ArmatureData>(0, true);
			_subTexturePivots = {};
		}
		
		public function dispose():void
		{
			for each(var armatureData:ArmatureData in _armatureDataList)
			{
				armatureData.dispose();
			}
			_armatureDataList.fixed = false;
			_armatureDataList.length = 0;
			
			_armatureDataList = null;
			_subTexturePivots = null;
		}
		
		public function getArmatureData(armatureName:String):ArmatureData
		{
			var i:int = _armatureDataList.length;
			while(i --)
			{
				if(_armatureDataList[i].name == armatureName)
				{
					return _armatureDataList[i];
				}
			}
			
			return null;
		}
		
		public function addArmatureData(armatureData:ArmatureData):void
		{
			if(!armatureData)
			{
				throw new ArgumentError();
			}
			
			if(_armatureDataList.indexOf(armatureData) < 0)
			{
				_armatureDataList.fixed = false;
				_armatureDataList[_armatureDataList.length] = armatureData;
				_armatureDataList.fixed = true;
			}
			else
			{
				throw new ArgumentError();
			}
		}
		
		public function removeArmatureData(armatureData:ArmatureData):void
		{
			var index:int = _armatureDataList.indexOf(armatureData);
			if(index >= 0)
			{
				_armatureDataList.fixed = false;
				_armatureDataList.splice(index, 1);
				_armatureDataList.fixed = true;
			}
		}
		
		public function removeArmatureDataByName(armatureName:String):void
		{
			var i:int = _armatureDataList.length;
			while(i --)
			{
				if(_armatureDataList[i].name == armatureName)
				{
					_armatureDataList.fixed = false;
					_armatureDataList.splice(i, 1);
					_armatureDataList.fixed = true;
				}
			}
		}
		
		public function getSubTexturePivot(subTextureName:String):Point
		{
			return _subTexturePivots[subTextureName];
		}
		
		public function addSubTexturePivot(x:Number, y:Number, subTextureName:String):Point
		{
			var point:Point = _subTexturePivots[subTextureName];
			if(point)
			{
				point.x = x;
				point.y = y;
			}
			else
			{
				_subTexturePivots[subTextureName] = point = new Point(x, y);
			}
			
			return point;
		}
		
		public function removeSubTexturePivot(subTextureName:String):void
		{
			if(subTextureName)
			{
				delete _subTexturePivots[subTextureName];
			}
			else
			{
				for(subTextureName in _subTexturePivots)
				{
					delete _subTexturePivots[subTextureName];
				}
			}
		}
	}
}