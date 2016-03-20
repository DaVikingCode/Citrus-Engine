package dragonBones.core {

	import dragonBones.objects.DBTransform;

	import flash.geom.ColorTransform;
	import flash.geom.Matrix;

	public interface ISlotCacheGenerator extends ICacheUser
	{
		function get global():DBTransform;
		function get globalTransformMatrix():Matrix;
		function get colorChanged():Boolean;
		function get colorTransform():ColorTransform;
		function get displayIndex():int;
	}
}