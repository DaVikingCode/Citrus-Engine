package citrus.ui.starling
{
	import starling.display.Image;
	import citrus.ui.starling.UIGroup;

	/**
	 * @author Michelangelo Capraro (m&#64;mcapraro.com)
	 */
	public class UIScore extends UIGroup
	{
		private var _textures:Array;
		private var _score:int = 0;
		
		public function UIScore(numberTextures:Array)
		{
			super(HORIZONTAL);
			
			_textures = numberTextures;
			_padding = 2;
			
			if (numberTextures.length < 10) {
				throw new ArgumentError(String(this) + " not enough textures.");
			}
			
			refreshImages();
		}

		private function refreshImages():void
		{
			trace("UIScore: refreshImages");			
			var scoreString:String = _score.toString();
			
			var i:int;
			var elm:UIElement;
			
			var newDigits:int = scoreString.length - _elements.length;
			
			trace("UIScore: refreshImages: newDigits [" + newDigits + "]");
			
			if (newDigits < 0) {
				for (i = 0; i < Math.abs(newDigits); i++) {
					elm = _elements.splice(0, 1)[0];
					elm.destroy();
				}
			} else if (newDigits > 0) {
				for (i = 0; i < Math.abs(newDigits); i++) {
					add(new Image(_textures[0]));
				}
			}
						
			for (i = 0; i < scoreString.length; i++) {
				Image(UIElement(_elements[i]).content).texture = _textures[parseInt(scoreString.charAt(i))];
			}
			
			if (newDigits > 0) refresh();
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

		override public function destroy():void
		{
			super.destroy();
			_textures = null;
		}
	}
}
