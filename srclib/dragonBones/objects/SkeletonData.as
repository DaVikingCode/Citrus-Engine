package dragonBones.objects {
	
	import flash.utils.ByteArray;
	

	/**
	 * A set of armature datas and animation datas
	 */
	public class SkeletonData
	{
		private var _armatureDatas:Object;
		private var _animationDatas:Object;
		private var _armatureList:Vector.<String>;
		private var _animationList:Vector.<String>;
		
		internal var _name:String;
		public function get name():String
		{
			return _name;
		}
		
		public function get totalArmatures():uint
		{
			return _armatureList.length;
		}
		
		public function get totalAnimation():uint
		{
			return _animationList.length;
		}
		
		public function get armatureList():Vector.<String>
		{
			return _armatureList.concat();
		}
		
		public function get animationList():Vector.<String>
		{
			return _animationList.concat();
		}
		
		public function SkeletonData()
		{
			_armatureDatas = { };
			_animationDatas = { };
			_armatureList = new Vector.<String>;
			_animationList = new Vector.<String>;
		}
		
		public function dispose():void
		{
			for each(var armatureData:ArmatureData in _armatureDatas)
			{
				armatureData.dispose();
			}
			for each(var animationData:AnimationData in _animationDatas)
			{
				animationData.dispose();
			}
			_armatureDatas = null;
			_animationDatas = null;
			_armatureList = null;
			_animationList = null;
		}
		
		public function getArmatureData(name:String):ArmatureData
		{
			return _armatureDatas[name];
		}
		
		public function getAramtureDataAt(index:int):ArmatureData
		{
			var name:String = _armatureList.length > index?_armatureList[index]:null;
			return getArmatureData(name);
		}
		
		public function getAnimationData(name:String):AnimationData
		{
			return _animationDatas[name];
		}
		
		public function getAnimationDataAt(index:int):AnimationData
		{
			var name:String = _animationList.length > index?_animationList[index]:null;
			return getAnimationData(name);
		}
		
		internal function addArmatureData(data:ArmatureData):void
		{
			var name:String = data.name;
			_armatureDatas[name] = data;
			if(_armatureList.indexOf(name) < 0)
			{
				_armatureList.push(name);
			}
		}
		
		internal function addAnimationData(data:AnimationData):void
		{
			var name:String = data.name;
			_animationDatas[name] = data;
			if(_animationList.indexOf(name) < 0)
			{
				_animationList.push(name);
			}
		}
	}
}