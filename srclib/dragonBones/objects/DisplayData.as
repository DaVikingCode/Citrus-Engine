package dragonBones.objects
{
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/** @private */
	public class DisplayData
	{
		public var pivotX:int;
		public var pivotY:int;
		
		dragonBones_internal var _isArmature:Boolean;
		public function get isArmature():Boolean
		{
			return _isArmature;
		}
		
		public function DisplayData()
		{
		}
	}
}