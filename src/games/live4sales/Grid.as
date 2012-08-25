package games.live4sales {

	import starling.display.Sprite;
	import starling.extensions.utils.Line;

	/**
	 * @author Aymeric
	 */
	public class Grid extends Sprite {

		public function Grid() {
			
			//96 width
			//38 height
			
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
		
		public function casePosition(posX:uint, posY:uint):uint {
			//trace(posX, posY);
			
			var position:uint = 0;
			
			if (posY < 130)
				return position;
			else if (posX < 96 && posY < 168)
				position = 11;
			else if (posX < 192 && posY < 168)
				position = 21;
			else if (posX < 288 && posY < 168)
				position = 31;
			else if (posX < 384 && posY < 168)
				position = 41;
			else if (posX < 480 && posY < 168)
				position = 51;
			else if (posX < 96 && posY < 206)
				position = 12;
			else if (posX < 192 && posY < 206)
				position = 22;
			else if (posX < 288 && posY < 206)
				position = 32;
			else if (posX < 384 && posY < 206)
				position = 42;
			else if (posX < 480 && posY < 206)
				position = 52;
			else if (posX < 96 && posY < 244)
				position = 13;
			else if (posX < 192 && posY < 244)
				position = 23;
			else if (posX < 288 && posY < 244)
				position = 33;
			else if (posX < 384 && posY < 244)
				position = 43;
			else if (posX < 480 && posY < 244)
				position = 53;
			else if (posX < 96 && posY < 282)
				position = 14;
			else if (posX < 192 && posY < 282)
				position = 24;
			else if (posX < 288 && posY < 282)
				position = 34;
			else if (posX < 384 && posY < 282)
				position = 44;
			else if (posX < 480 && posY < 282)
				position = 54;
			else if (posX < 96 && posY < 320)
				position = 15;
			else if (posX < 192 && posY < 320)
				position = 25;
			else if (posX < 288 && posY < 320)
				position = 35;
			else if (posX < 384 && posY < 320)
				position = 45;
			else if (posX < 480 && posY < 320)
				position = 55;
			
			return position;
		}
	}
}
