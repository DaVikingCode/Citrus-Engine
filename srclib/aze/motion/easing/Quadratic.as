package aze.motion.easing 
{
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
	 */
	final public class Quadratic
	{
		static public function easeIn(k:Number):Number 
		{
			return k * k;
		}
		static public function easeOut(k:Number):Number 
		{
			return -k * (k - 2);
		}
		static public function easeInOut(k:Number):Number 
		{
			if ((k *= 2) < 1) return 0.5 * k * k;
			return -0.5 * (--k * (k - 2) - 1);
		}
	}

}