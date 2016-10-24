package aze.motion.easing 
{
	/**
	 * ...
	 * @author mr.doob
	 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
	 */
	final public class Bounce
	{
		static public function easeIn(k:Number):Number 
		{
			return 1 - Bounce.easeOut(1 - k);
		}
		static public function easeOut(k:Number):Number 
		{
			if((k /= 1) < 0.363636364/*(1/2.75)*/)
			{
				return (7.5625 * k * k);
			}
			else if(k < 0.727272727/*(2/2.75)*/)
			{
				return (7.5625 * (k -= 0.545454545/*(1.5/2.75)*/) * k + .75);
			}
			else if(k < 0.909090909/*(2.5/2.75)*/)
			{
				return (7.5625 * (k -= 0.818181818/*(2.25/2.75)*/) * k + .9375);
			}
			else
			{
				return (7.5625 * (k -= 0.954545455/*(2.625/2.75)*/) * k + .984375);
			}
		}
		static public function easeInOut(k:Number):Number 
		{
			if(k < .5) return Bounce.easeIn(k * 2) * .5;
			else return Bounce.easeOut(k * 2 - 1) * .5 + .5;
		}
	}
}