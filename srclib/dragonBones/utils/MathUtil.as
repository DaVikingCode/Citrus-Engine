package dragonBones.utils
{
	/** @private */
	final public class MathUtil
	{
		/** @private */
		public static function getEaseValue(value:Number, easing:Number):Number
		{
			var valueEase:Number = 1;
			if(easing > 1)    //ease in out
			{
				valueEase = 0.5 * (1 - Math.cos(value * Math.PI));
				easing -= 1;
			}
			else if (easing > 0)    //ease out
			{
				valueEase = 1 - Math.pow(1-value,2);
			}
			else if (easing < 0)    //ease in
			{
				easing *= -1;
				valueEase =  Math.pow(value,2);
			}
			
			return (valueEase - value) * easing + value;
		}
	}
	
}