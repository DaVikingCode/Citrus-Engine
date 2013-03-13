package dragonBones.objects 
{
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/**
	 * A set of armature data and animation data
	 */
	public class SkeletonData
	{
		dragonBones_internal var _armatureDataList:DataList;
		dragonBones_internal var _animationDataList:DataList;
		dragonBones_internal var _displayDataList:DataList;
		
		dragonBones_internal var _name:String;
		public function get name():String
		{
			return _name;
		}
		
		dragonBones_internal var _frameRate:uint;
		public function get frameRate():uint
		{
			return _frameRate;
		}
		
		public function get armatureNames():Vector.<String>
		{
			return _armatureDataList.dataNames.concat();
		}
		
		public function get animationNames():Vector.<String>
		{
			return _animationDataList.dataNames.concat();
		}
		
		public function SkeletonData()
		{
			_armatureDataList = new DataList();
			_animationDataList = new DataList();
			_displayDataList = new DataList();
		}
		
		public function dispose():void
		{
			for each(var armatureName:String in _armatureDataList.dataNames)
			{
				var armatureData:ArmatureData = _armatureDataList.getData(armatureName) as ArmatureData;
				armatureData.dispose();
			}
			
			for each(var animationName:String in _animationDataList.dataNames)
			{
				var animationData:AnimationData = _animationDataList.getData(animationName) as AnimationData;
				animationData.dispose();
			}
			
			_armatureDataList.dispose();
			_animationDataList.dispose();
			_displayDataList.dispose();
		}
		
		public function getArmatureData(name:String):ArmatureData
		{
			return _armatureDataList.getData(name) as ArmatureData;
		}
		
		public function getAnimationData(name:String):AnimationData
		{
			return _animationDataList.getData(name) as AnimationData;
		}
		
		public function getDisplayData(name:String):DisplayData
		{
			return _displayDataList.getData(name) as DisplayData;
		}
	}
}