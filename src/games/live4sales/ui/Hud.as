package games.live4sales.ui {

	import games.live4sales.assets.Assets;
	import games.live4sales.events.MoneyEvent;
	import games.live4sales.utils.Grid;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;

	import com.citrusengine.core.CitrusEngine;

	import org.osflash.signals.Signal;

	import flash.display.Bitmap;
	
	/**
	 * @author Aymeric
	 */
	public class Hud extends Sprite {
		
		[Embed(source="/../embed/ArialFont.fnt", mimeType="application/octet-stream")] private var _fontConfig:Class;
		[Embed(source="/../embed/ArialFont.png")] private var _fontPng:Class;
		
		static public var money:uint = 400;

		public var onIconePositioned:Signal;
		
		private var _ce:CitrusEngine;

		private var _grid:Grid;
		private var _vectorIcon:Vector.<Icon>;

		private var _backgroundMenu:Image;
		private var _iconSaleswoman:Icon;
		private var _iconCash:Icon;
		private var _iconBlock:Icon;
		
		private var _score:TextField;

		public function Hud() {
			
			_ce = CitrusEngine.getInstance();

			onIconePositioned = new Signal(String, uint, uint);

			_grid = new Grid();

			_vectorIcon = new Vector.<Icon>(3, true);

			_backgroundMenu = new Image(Assets.getAtlasTexture("background-menu", "Menu"));
			_iconSaleswoman = new Icon(Assets.getAtlasTexture("icon-saleswoman", "Menu"));
			_iconCash = new Icon(Assets.getAtlasTexture("icon-cash", "Menu"));
			_iconBlock = new Icon(Assets.getAtlasTexture("icon-block", "Menu"));

			_vectorIcon[0] = _iconSaleswoman;
			_vectorIcon[1] = _iconCash;
			_vectorIcon[2] = _iconBlock;
			
			var bitmap:Bitmap = new _fontPng();
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new _fontConfig());
			TextField.registerBitmapFont(new BitmapFont(texture, xml));
			_score = new TextField(50, 20, "0", "ArialMT");

			addEventListener(Event.ADDED_TO_STAGE, _addedToStage);
		}

		public function destroy():void {
			
			onIconePositioned.removeAll();
			
			removeChild(_grid, true);
			
			for each (var icon:Icon in _vectorIcon) {
				icon.destroy();
				removeChild(icon, true);
			}
			
			_vectorIcon = null;
			
			TextField.unregisterBitmapFont("ArialMT");
			removeChild(_score, true);
			
			_ce.removeEventListener(MoneyEvent.BUY_ITEM, _changeMoney);
		}

		private function _addedToStage(evt:Event):void {

			removeEventListener(Event.ADDED_TO_STAGE, _addedToStage);

			addChild(_grid);
			_grid.visible = false;

			addChild(_backgroundMenu);
			_backgroundMenu.x = (480 - _backgroundMenu.width) / 2;

			addChild(_iconSaleswoman);
			_iconSaleswoman.name = "SalesWoman";
			_iconSaleswoman.x = (480 - _iconSaleswoman.width) / 2 - 30;
			
			addChild(_iconCash);
			_iconCash.name = "Cash";
			_iconCash.x = (480 - _iconCash.width) / 2 + 20;
			
			addChild(_iconBlock);
			_iconBlock.name = "Block";
			_iconBlock.x = (480 - _iconBlock.width) / 2 + 70;

			for each (var icon:Icon in _vectorIcon) {
				icon.onStartDrag.add(_showGrid);
				icon.onStopDrag.add(_hideGridAndCreateObject);
			}
			
			_score.x = 150;
			_score.y = 3;
			addChild(_score);
			_score.text = String(money);
			
			_ce.addEventListener(MoneyEvent.BUY_ITEM, _changeMoney);
			_ce.addEventListener(MoneyEvent.PICKUP_MONEY, _changeMoney);
		}

		private function _changeMoney(mEvt:MoneyEvent):void {
			
			if (mEvt.type == "BUY_ITEM")
				money -= 50;
			else if (mEvt.type == "PICKUP_MONEY")
				money += 50;
			
			_score.text = String(money);
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
