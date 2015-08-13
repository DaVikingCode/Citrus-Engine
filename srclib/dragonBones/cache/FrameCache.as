package dragonBones.cache
{
	import flash.geom.Matrix;
	
	import dragonBones.objects.DBTransform;

	public class FrameCache
	{
		private static const ORIGIN_TRAMSFORM:DBTransform = new DBTransform();
		private static const ORIGIN_MATRIX:Matrix = new Matrix();
		
		public var globalTransform:DBTransform = new DBTransform();
		public var globalTransformMatrix:Matrix = new Matrix();
		public function FrameCache()
		{
		}
		
		//浅拷贝提高效率
		public function copy(frameCache:FrameCache):void
		{
			globalTransform = frameCache.globalTransform;
			globalTransformMatrix = frameCache.globalTransformMatrix;
		}
		
		public function clear():void
		{
			globalTransform = ORIGIN_TRAMSFORM;
			globalTransformMatrix = ORIGIN_MATRIX;
		}
	}
}