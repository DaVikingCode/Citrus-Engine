package games.live4sales.utils {

	import starling.display.Sprite;
	import starling.extensions.utils.Line;

	/**
	 * @author Aymeric
	 */
	public class Grid extends Sprite {

		public static var tabObjects:Array;

		public static var tabBaddies:Array;

		private static const CASE_WIDTH:uint = 96;
		private static const CASE_HEIGHT:uint = 38;
		private static const OFFSET_Y:uint = 130;

		public function Grid() {

			tabObjects = new Array(6);
			tabObjects[0] = [false]; //always false
			tabObjects[1] = [false, false, false, false, false];
			tabObjects[2] = [false, false, false, false, false];
			tabObjects[3] = [false, false, false, false, false];
			tabObjects[4] = [false, false, false, false, false];
			tabObjects[5] = [false, false, false, false, false];

			tabBaddies = new Array(6);
			tabBaddies[0] = false; //always false
			tabBaddies[1] = false;
			tabBaddies[2] = false;
			tabBaddies[3] = false;
			tabBaddies[4] = false;
			tabBaddies[5] = false;

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

		public static function getCaseId(posX:uint, posY:int):Array {

			var caseId:Array = [0, 0];
			var idLine:uint = 0;
			var idColumn:uint = 0;
			posY -= OFFSET_Y;
			if (posY < 0)
				return caseId;
			idLine = Math.floor(posY / CASE_HEIGHT) + 1;
			idColumn = Math.floor(posX / CASE_WIDTH) + 1;
			return (caseId = [idLine, idColumn]);

		}

		public static function getCaseCenter(posX:uint, posY:int):Array {
			var caseId:Array = getCaseId(posX, posY);
			var positions:Array = [0, 0, 0];

			if (caseId[0] != 0 && caseId[1] != 0) {
				if (tabObjects[caseId[1]][caseId[0]] == true) {
					return positions;
				}

				positions[0] = caseId[1] * CASE_WIDTH - (CASE_WIDTH / 2);
				positions[1] = caseId[0] * CASE_HEIGHT - (CASE_HEIGHT / 2) + OFFSET_Y;
				positions[2] = caseId[0];
				tabObjects[caseId[1]][caseId[0]] = true;
			}

			return positions;
		}
		
		public static function getBaddyPosition(posX:uint, posY:int):Array {
			
			var caseId:Array = getCaseId(posX, posY);
			var positions:Array = [0, 0, 0];

			positions[0] = caseId[1] * CASE_WIDTH - (CASE_WIDTH / 2);
			positions[1] = caseId[0] * CASE_HEIGHT - (CASE_HEIGHT / 2) + OFFSET_Y;
			positions[2] = caseId[0];
			
			return positions;
		}
		
		public static function getRandomHeight():uint {
			return Math.random() * CASE_HEIGHT * 5 + OFFSET_Y;
		}

	}
}
