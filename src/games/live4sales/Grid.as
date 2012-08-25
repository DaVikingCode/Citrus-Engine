package games.live4sales {

	import starling.display.Sprite;
	import starling.extensions.utils.Line;

	/**
	 * @author Aymeric
	 */
	public class Grid extends Sprite {

		public function Grid() {
			
			_addNewLine(96, 130, 0, 190);
			_addNewLine(192, 130, 0, 190);
			_addNewLine(288, 130, 0, 190);
			_addNewLine(384, 130, 0, 190);
			
			_addNewLine(0, 168, 480, 0);
			_addNewLine(0, 206, 480, 0);
			_addNewLine(0, 244, 480, 0);
			_addNewLine(0, 282, 480, 0);
		}

		private function _addNewLine(posX:uint, posY:uint, posXEnd:uint, posYEnd:uint):void {
			
			var line:Line = new Line();
			addChild(line);
			
			line.x = posX;
			line.y = posY;
			line.lineTo(posXEnd, posYEnd);
		}
	}
}
