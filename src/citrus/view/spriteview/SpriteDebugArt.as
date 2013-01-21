package citrus.view.spriteview 
{

	import citrus.core.CitrusObject;
	import citrus.objects.CitrusSprite;

	import flash.display.MovieClip;
	
	/**
	 * This class is created by the SpriteView if a CitrusSprite has no view mentionned. It is made for a quick debugging object's view.
	 */
	public class SpriteDebugArt extends MovieClip 
	{
		
		public function SpriteDebugArt() 
		{
		}
		
		public function initialize(object:CitrusObject):void
		{
			var citrusSprite:CitrusSprite = object as CitrusSprite;
			
			if (citrusSprite)
			{
				graphics.lineStyle(1, 0x222222);
				graphics.beginFill(0x888888);
				graphics.drawRect(0, 0, citrusSprite.width, citrusSprite.height);
				graphics.endFill();
			}
		}
	}

}