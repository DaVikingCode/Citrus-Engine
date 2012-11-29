package dragonBones.objects
{
	
	/** @private */
	public class AnimationData
	{
		private var _movementDatas:Object;
		private var _movementList:Vector.<String>;
		
		internal var _name:String;
		public function get name():String
		{
			return _name;
		}
		
		public function get totalMovements():uint
		{
			return _movementList.length;
		}
		
		public function get movementList():Vector.<String>
		{
			return _movementList.concat();
		}
		
		public function AnimationData()
		{
			_movementDatas = { };
			_movementList = new Vector.<String>;
		}
		
		public function dispose():void
		{
			for each(var movementData:MovementData in _movementDatas)
			{
				movementData.dispose();
			}
			_movementDatas = null;
			_movementList = null;
		}
		
		public function getMovementData(name:String):MovementData
		{
			return _movementDatas[name];
		}
		
		public function getMovementDataAt(index:int):MovementData
		{
			var name:String = _movementList.length > index?_movementList[index]:null;
			return getMovementData(name);
		}
		
		internal function addMovementData(data:MovementData):void
		{
			var name:String = data.name;
			_movementDatas[name] = data;
			if(_movementList.indexOf(name) < 0)
			{
				_movementList.push(name);
			}
		}
		
	}
	
}