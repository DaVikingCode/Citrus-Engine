package dragonBones.objects
{
	import flash.geom.Matrix;
	
	/** @private */
	public class FrameCached
	{
		public var transform:DBTransform;
		public var matrix:Matrix;
		
		public function FrameCached()
		{
			
		}
		
		public function dispose():void
		{
			transform = null;
			matrix = null;
		}
	}
}