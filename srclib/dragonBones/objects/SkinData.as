package dragonBones.objects
{
	/** @private */
	final public class SkinData
	{
		public var name:String;
		
		private var _slotDataList:Vector.<SlotData>;
		public function get slotDataList():Vector.<SlotData>
		{
			return _slotDataList;
		}
		
		public function SkinData()
		{
			_slotDataList = new Vector.<SlotData>(0, true);
		}
		
		public function dispose():void
		{
			var i:int = _slotDataList.length;
			while(i --)
			{
				_slotDataList[i].dispose();
			}
			_slotDataList.fixed = false;
			_slotDataList.length = 0;
			_slotDataList = null;
		}
		
		public function getSlotData(slotName:String):SlotData
		{
			var i:int = _slotDataList.length;
			while(i --)
			{
				if(_slotDataList[i].name == slotName)
				{
					return _slotDataList[i];
				}
			}
			return null;
		}
		
		public function addSlotData(slotData:SlotData):void
		{
			if(!slotData)
			{
				throw new ArgumentError();
			}
			
			if (_slotDataList.indexOf(slotData) < 0)
			{
				_slotDataList.fixed = false;
				_slotDataList[_slotDataList.length] = slotData;
				_slotDataList.fixed = true;
			}
			else
			{
				throw new ArgumentError();
			}
		}
	}
}