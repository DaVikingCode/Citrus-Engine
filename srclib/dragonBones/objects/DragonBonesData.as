package dragonBones.objects 
{
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class DragonBonesData
	{
		public var name:String;
		public var isGlobalData:Boolean;
		
		private var _armatureDataList:Vector.<ArmatureData> = new Vector.<ArmatureData>(0, true);
		private var _displayDataDictionary:Dictionary = new Dictionary();
		
		public function DragonBonesData()
		{
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
			
			removeAllDisplayData();
			_displayDataDictionary = null;
		}
		
		public function get armatureDataList():Vector.<ArmatureData>
		{
			return _armatureDataList;
		}
		
		public function getArmatureDataByName(armatureName:String):ArmatureData
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
		
		public function getDisplayDataByName(name:String):DisplayData
		{
			return _displayDataDictionary[name];
		}
		
		public function addDisplayData(displayData:DisplayData):void
		{
			_displayDataDictionary[displayData.name] = displayData;
		}
		
		public function removeDisplayDataByName(name:String):void
		{
			delete _displayDataDictionary[name]
		}
		
		public function removeAllDisplayData():void
		{
			for(var name:String in _displayDataDictionary)
			{
				delete _displayDataDictionary[name];
			}
		}
	}
}