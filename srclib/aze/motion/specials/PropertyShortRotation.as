package aze.motion.specials 
{
	import aze.motion.EazeTween;
	import aze.motion.specials.EazeSpecial;
	
	/**
	 * Short rotation tweening
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class PropertyShortRotation extends EazeSpecial
	{
		static public function register():void
		{
			EazeTween.specialProperties["__short"] = PropertyShortRotation;
		}
		
		private var fvalue:Number;
		private var radius:Number;
		private var start:Number;
		private var delta:Number;
		
		public function PropertyShortRotation(target:Object, property:*, value:*, next:EazeSpecial) 
		{
			super(target, property, value, next);
			fvalue = value[0];
			radius = value[1] ? Math.PI : 180;
		}
		
		override public function init(reverse:Boolean):void 
		{
			start = target[property];
			var end:Number;
			if (reverse) { end = start; target[property] = start = fvalue; }
			else { end = fvalue; }
			while (end - start > radius) start += radius * 2;
			while (end - start < -radius) start -= radius * 2;
			delta = end - start;
		}
		
		override public function update(ke:Number, isComplete:Boolean):void 
		{
			target[property] = start + ke * delta;
		}
	}

}