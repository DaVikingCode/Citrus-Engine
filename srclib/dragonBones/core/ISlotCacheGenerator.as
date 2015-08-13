package dragonBones.core
{
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import dragonBones.objects.DBTransform;

	public interface ISlotCacheGenerator extends ICacheUser
	{
		function get global():DBTransform;
		function get globalTransformMatrix():Matrix;
		function get colorChanged():Boolean;
		function get colorTransform():ColorTransform;
		function get displayIndex():int;
	}
}