package dragonBones.objects
{
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/** @private */
	final public class BoneData
	{
		dragonBones_internal var _displayNames:Vector.<String>;
		
		dragonBones_internal var _parent:String;
		
		public function get parent():String
		{
			return _parent;
		}
		
		public var node:BoneTransform;
		
		public function BoneData()
		{
			_displayNames = new Vector.<String>;
			node = new BoneTransform();
		}
		
		public function dispose():void
		{
			_displayNames.length = 0;
		}
	}
}