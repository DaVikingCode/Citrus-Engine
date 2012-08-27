package games.live4sales.ui {

	import games.live4sales.assets.Assets;
	import games.live4sales.utils.Grid;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;

	import org.osflash.signals.Signal;

	/**
	 * @author Aymeric
	 */
	public class Hud extends Sprite {

		public var onIconePositioned:Signal;

		private var _grid:Grid;
		private var _vectorIcon:Vector.<Icon>;

		private var _backgroundMenu:Image;
		private var _iconSaleswoman:Icon;
		private var _iconBlock:Icon;

		public function Hud() {

			onIconePositioned = new Signal(String, uint, uint);

			_grid = new Grid();

			_vectorIcon = new Vector.<Icon>(2, true);

			_backgroundMenu = new Image(Assets.getAtlasTexture("background-menu", "Menu"));
			_iconSaleswoman = new Icon(Assets.getAtlasTexture("icon-saleswoman", "Menu"));
			_iconBlock = new Icon(Assets.getAtlasTexture("icon-block", "Menu"));

			_vectorIcon[0] = _iconSaleswoman;
			_vectorIcon[1] = _iconBlock;

			addEventListener(Event.ADDED_TO_STAGE, _addedToStage);
		}

		public function destroy():void {
			
			onIconePositioned.removeAll();
			
			_vectorIcon = null;
		}

		private function _addedToStage(evt:Event):void {

			removeEventListener(Event.ADDED_TO_STAGE, _addedToStage);

			addChild(_grid);
			_grid.visible = false;

			addChild(_backgroundMenu);
			_backgroundMenu.x = (stage.stageWidth - _backgroundMenu.width) / 2;

			addChild(_iconSaleswoman);
			_iconSaleswoman.name = "SalesWoman";
			_iconSaleswoman.x = (stage.stageWidth - _iconSaleswoman.width) / 2 - 50;
			
			addChild(_iconBlock);
			_iconBlock.name = "Block";
			_iconBlock.x = (stage.stageWidth - _iconBlock.width) / 2;

			for each (var icon:Icon in _vectorIcon) {
				icon.onStartDrag.add(_showGrid);
				icon.onStopDrag.add(_hideGridAndCreateObject);
			}
			
		}

		private function _showGrid():void {
			_grid.visible = true;
		}

		private function _hideGridAndCreateObject(name:String, posX:uint, posY:uint):void {
			_grid.visible = false;
			onIconePositioned.dispatch(name, posX, posY);
		}
	}
}
