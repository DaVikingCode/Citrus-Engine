package aze.motion.easing 
{
	/**
	 * ...
	 * @author Philippe / http://philippe.elsass.me
	 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
	 */
	final public class Back
	{
		static public var easeIn:Function = easeInWith();
		static public var easeOut:Function = easeOutWith();
		static public var easeInOut:Function = easeInOutWith();
		
		static public function easeInWith(s:Number = 1.70158):Function
		{
			return function (k:Number):Number 
				{
					return k * k * ((s + 1) * k - s);
				}
		}
		static public function easeOutWith(s:Number = 1.70158):Function
		{
			return function (k:Number):Number 
				{
					return (k = k - 1) * k * ((s + 1) * k + s) + 1;
				}
		}
		static public function easeInOutWith(s:Number = 1.70158):Function
		{
			s *= 1.525;
			return function (k:Number):Number 
				{
					if ((k *= 2) < 1) return 0.5 * (k * k * ((s + 1) * k - s));
					return 0.5 * ((k -= 2) * k * ((s + 1) * k + s) + 2);
				}
		}
	}
/*
		public function calculate(t:Number, b:Number, c:Number, d:Number):Number
		{
			if ((t /= d / 2) < 1) {
				return c / 2 * (t * t * (((s * 1.525) + 1) * t - s * 1.525)) + b;
			}
			return c / 2 * ((t -= 2) * t * (((s * 1.525) + 1) * t + s * 1.525) + 2) + b;
		}*/
}