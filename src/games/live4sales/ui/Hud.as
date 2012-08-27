package games.live4sales.ui {

	import org.osflash.signals.Signal;
	import games.live4sales.assets.Assets;
	import games.live4sales.utils.Grid;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * @author Aymeric
	 */
	public class Hud extends Sprite {
		
		public var onIconePositioned:Signal;
		
		private var _grid:Grid;
		
		private var _backgroundMenu:Image;
		private var _iconSaleswoman:Icon;
		
		public function Hud() {
			
			onIconePositioned = new Signal(String, uint, uint);
			
			_grid = new Grid();
			
			_backgroundMenu = new Image(Assets.getAtlasTexture("background-menu", "Menu"));
			_iconSaleswoman = new Icon(Assets.getAtlasTexture("icon-saleswoman", "Menu"));
			
			addEventListener(Event.ADDED_TO_STAGE, _addedToStage);
		}
		
		public function destroy():void {
			onIconePositioned.removeAll();
		}

		private function _addedToStage(evt:Event):void {
			
			removeEventListener(Event.ADDED_TO_STAGE, _addedToStage);
			
			addChild(_grid);
			_grid.visible = false;
			
			addChild(_backgroundMenu);
			_backgroundMenu.x = (stage.stageWidth - _backgroundMenu.width) / 2;
			
			addChild(_iconSaleswoman);
			_iconSaleswoman.name = "SalesWoman";
			_iconSaleswoman.x = (stage.stageWidth - _iconSaleswoman.width) / 2;
			_iconSaleswoman.onStartDrag.add(_showGrid);
			_iconSaleswoman.onStopDrag.add(_hideGridAndCreateObject);
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
