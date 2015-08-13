package dragonBones.core
{
	public interface ICacheableArmature extends IArmature
	{
		function get enableCache():Boolean;
		function set enableCache(value:Boolean):void;
		
		function get enableEventDispatch():Boolean;
		function set enableEventDispatch(value:Boolean):void;
		
		function getSlotDic():Object;
	}
}