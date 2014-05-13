package dragonBones.objects
{
	/** @private */
	public final class SlotData
	{
		public var name:String;
		public var parent:String;
		public var zOrder:Number;
        public var blendMode:String;
		
		private var _displayDataList:Vector.<DisplayData>;
		public function get displayDataList():Vector.<DisplayData>
		{
			return _displayDataList;
		}
		
		public function SlotData()
		{
			_displayDataList = new Vector.<DisplayData>(0, true);
			zOrder = 0;
		}
		
		public function dispose():void
		{
			var i:int = _displayDataList.length;
			while(i --)
			{
				_displayDataList[i].dispose();
			}
			_displayDataList.fixed = false;
			_displayDataList.length = 0;
			_displayDataList = null;
		}
		
		public function addDisplayData(displayData:DisplayData):void
		{
			if(!displayData)
			{
				throw new ArgumentError();
			}
			if (_displayDataList.indexOf(displayData) < 0)
			{
				_displayDataList.fixed = false;
				_displayDataList[_displayDataList.length] = displayData;
				_displayDataList.fixed = true;
			}
			else
			{
				throw new ArgumentError();
			}
		}
		
		public function getDisplayData(displayName:String):DisplayData
		{
			var i:int = _displayDataList.length;
			while(i --)
			{
				if(_displayDataList[i].name == displayName)
				{
					return _displayDataList[i];
				}
			}
			
			return null;
		}
	}
}