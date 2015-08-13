package dragonBones.utils
{
	import flash.geom.ColorTransform;

	public class ColorTransformUtil
	{
		static public var originalColor:ColorTransform = new ColorTransform();
		
		public static function cloneColor(color:ColorTransform):ColorTransform
		{
			return new ColorTransform(color.redMultiplier,color.greenMultiplier,color.blueMultiplier,color.alphaMultiplier,color.redOffset,color.greenOffset,color.blueOffset,color.alphaOffset)
		}
		
		public static function isEqual(color1:ColorTransform, color2:ColorTransform):Boolean
		{
			return 	color1.alphaOffset == color2.alphaOffset &&
					color1.redOffset == color2.redOffset &&
					color1.greenOffset == color2.greenOffset &&
					color1.blueOffset == color2.blueOffset &&
					color1.alphaMultiplier == color2.alphaMultiplier &&
					color1.redMultiplier == color2.redMultiplier &&
					color1.greenMultiplier == color2.greenMultiplier &&
					color1.blueMultiplier == color2.blueMultiplier;
		}
		
		public static function minus(color1:ColorTransform, color2:ColorTransform, outputColor:ColorTransform):void
		{
			outputColor.alphaOffset = color1.alphaOffset - color2.alphaOffset;
			outputColor.redOffset = color1.redOffset - color2.redOffset;
			outputColor.greenOffset = color1.greenOffset - color2.greenOffset;
			outputColor.blueOffset = color1.blueOffset - color2.blueOffset;
			
			outputColor.alphaMultiplier = color1.alphaMultiplier - color2.alphaMultiplier;
			outputColor.redMultiplier = color1.redMultiplier - color2.redMultiplier;
			outputColor.greenMultiplier = color1.greenMultiplier - color2.greenMultiplier;
			outputColor.blueMultiplier = color1.blueMultiplier - color2.blueMultiplier;
		}
		
		public function ColorTransformUtil()
		{
		}
	}
}