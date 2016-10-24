package aze.motion.specials 
{
	import aze.motion.EazeTween;
	import aze.motion.specials.EazeSpecial;
	import flash.geom.Rectangle;
	
	/**
	 * Rectangle tweening (typically for DisplayObject.scrollRect)
	 * @author Igor Almeida / http://ialmeida.com
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class PropertyRect extends EazeSpecial
	{
		static public function register():void
		{
			EazeTween.specialProperties["__rect"] = PropertyRect;
		}

		private var original:Rectangle;
		private var targetRect:Rectangle
		private var tmpRect:Rectangle;

		public function PropertyRect(target:Object, property:*, value:*, next:EazeSpecial):void
		{
			super(target, property, value, next);
			targetRect = value && (value is Rectangle) ? value.clone() : new Rectangle();
		}

		override public function init(reverse:Boolean):void 
		{
			original = target[property] is Rectangle 
				? target[property].clone() as Rectangle
				: new Rectangle(0, 0, target.width, target.height);
			
			if (reverse)
			{
				tmpRect = original;
				original = targetRect;
				targetRect = tmpRect;
			}
			tmpRect = new Rectangle();
		}

		override public function update(ke:Number, isComplete:Boolean):void 
		{
			if (isComplete) target.scrollRect = targetRect;
			else
			{
				tmpRect.x = original.x + (targetRect.x - original.x) * ke;
				tmpRect.y = original.y + (targetRect.y - original.y) * ke;
				tmpRect.width = original.width + (targetRect.width - original.width) * ke;
				tmpRect.height = original.height + (targetRect.height - original.height) * ke;
				target[property] = tmpRect;
			}
		}
		
		override public function dispose():void 
		{
			original = targetRect = tmpRect = null;
			super.dispose();
		}
	}
}