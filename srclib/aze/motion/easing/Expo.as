package aze.motion.easing 
{
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
	 */
	final public class Expo
	{
		static public function easeIn(k:Number):Number 
		{
			return k == 0 ? 0 : Math.pow(2, 10 * (k - 1));
		}
		static public function easeOut(k:Number):Number 
		{
			return k == 1 ? 1 : -Math.pow(2, -10 * k) + 1;
		}
		static public function easeInOut(k:Number):Number 
		{
			if (k == 0) return 0;
			if (k == 1) return 1;
			if ((k *= 2) < 1) return 0.5 * Math.pow(2, 10 * (k - 1));
			return 0.5 * (-Math.pow(2, -10 * (k - 1)) + 2);
		}
	}

}