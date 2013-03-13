package dragonBones.objects
{
	internal final class DataList
	{
		private var _dataDic:Object;
		public var dataNames:Vector.<String>;
		
		public function DataList()
		{
			_dataDic = {};
			dataNames = new Vector.<String>;
		}
		
		public function dispose():void
		{
			_dataDic = {};
			dataNames.length = 0;
		}
		
		public function getData(dataName:String):Object
		{
			return _dataDic[dataName];
		}
		
		public function getDataAt(index:int):Object
		{
			return _dataDic[dataNames[index]];
		}
		
		public function addData(data:Object, dataName:String):void
		{
			if(data && dataName)
			{
				_dataDic[dataName] = data;
				if(dataNames.indexOf(dataName) < 0)
				{
					dataNames.push(dataName);
				}
			}
		}
		
		public function removeData(data:Object):void
		{
			if(data)
			{
				for(var dataName:String in _dataDic)
				{
					if(_dataDic[dataName] == data)
					{
						removeDataByName(dataName);
						return;
					}
				}
			}
		}
		
		public function removeDataByName(dataName:String):void
		{
			var data:Object = _dataDic[dataName];
			if(data)
			{
				delete _dataDic[dataName];
				dataNames.splice(dataNames.indexOf(dataName), 1);
			}
		}
	}
}