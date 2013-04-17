package dragonBones.textures
{
	import flash.geom.Rectangle;
	
	//1.4
	/** @private */
	public class SubTextureData extends Rectangle
	{
		public var pivotX:Number;
		public var pivotY:Number;
		
		public function SubTextureData(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0)
		{
			super(x, y, width, height);
			pivotX = 0;
			pivotY = 0;
		}
	}
}