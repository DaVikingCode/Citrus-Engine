package games.live4sales {

	import starling.display.Sprite;
	import starling.extensions.utils.Line;

	/**
	 * @author Aymeric
	 */
	public class Grid extends Sprite {

		private const CASE_WIDTH:uint = 96;
		private const CASE_HEIGHT:uint = 38;
		
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
		
		public function casePosition(posX:uint, posY:int):Array {
			//trace(posX, posY);
			
			var position:uint = 0;
			var  caseId:Array = [0,0];
			var idLine :uint = 0;
			var idColumn:uint = 0;
			posY -= 130;
			if (posY < 0)
				return caseId;
			idLine=Math.floor(posY / CASE_HEIGHT)+1;
			idColumn=Math.floor(posX / CASE_WIDTH)+1;
		return (caseId = [idLine, idColumn]);

		}
		public function getCaseCenter(posX:uint, posY:int):Array
		{
			var caseId : Array = casePosition(posX, posY);
			var positions : Array = [0, 0];
			
			if (caseId[0] != 0 && caseId[1] != 0)
			{
				positions[0] = caseId[1] * CASE_WIDTH - (CASE_WIDTH / 2);
				positions[1] = caseId[0] * CASE_HEIGHT - (CASE_HEIGHT / 2);
				
			}

			return positions;
			
		}

	}
}
