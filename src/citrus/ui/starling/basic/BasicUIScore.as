package citrus.ui.starling.basic
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.display.DisplayObject;
	import citrus.ui.starling.basic.BasicUIGroup;

	/**
	 * @author Michelangelo Capraro (m&#64;mcapraro.com)
	 */
	public class BasicUIScore extends BasicUIGroup
	{
		private var _textures:Array;
		private var _score:int = 0;
		
		public function BasicUIScore(numberTextures:Array, position:String = null)
		{
			super(HORIZONTAL, position);
			
			_textures = numberTextures;
			_padding = 2;
			
			if (numberTextures.length < 10) {
				throw new ArgumentError(String(this) + " not enough textures.");
			}
			
			refreshImages();
		}

		private function refreshImages():void
		{
			var scoreString:String = _score.toString();
			
			(_content as Sprite).removeChildren(0, -1, true);
			_elements = new Array();
			
			for (var i:int = 0; i < scoreString.length; i++) {
				add(new Image(_textures[parseInt(scoreString.charAt(i))]));
			}
			
			position = position;
		}

		public function get score():int
		{
			return _score;
		}

		public function set score(score:int):void
		{
			_score = score;
			refreshImages();
		}
	}
}
