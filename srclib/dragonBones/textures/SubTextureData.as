package dragonBones.textures
{
	import flash.geom.Rectangle;

	//1.4
	/** @private */
	public class SubTextureData extends Rectangle
	{
		public var pivotX:int;
		public var pivotY:int;
		
		public function SubTextureData(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0)
		{
			super(x, y, width, height);
		}
	}
}