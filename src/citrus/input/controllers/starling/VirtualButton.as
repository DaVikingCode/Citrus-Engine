package citrus.input.controllers.starling {

	import citrus.input.controllers.AVirtualButton;

	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class VirtualButton extends AVirtualButton {

		public var graphic:starling.display.Sprite;
		// main Sprite container.

		protected var button:Image;

		public var buttonUpTexture:Texture;
		public var buttonDownTexture:Texture;

		public function VirtualButton(name:String, params:Object = null) {
			graphic = new starling.display.Sprite();
			super(name, params);
		}

		override protected function initGraphics():void {

			if (!buttonUpTexture) {
				var tempSprite:Sprite = new Sprite();
				var tempBitmapData:BitmapData = new BitmapData(_buttonradius * 2, _buttonradius * 2, true, 0x00FFFFFF);

				tempSprite.graphics.clear();
				tempSprite.graphics.beginFill(0x000000, 0.1);
				tempSprite.graphics.drawCircle(_buttonradius, _buttonradius, _buttonradius);
				tempSprite.graphics.endFill();
				tempBitmapData.draw(tempSprite);
				buttonUpTexture = Texture.fromBitmapData(tempBitmapData);
				tempSprite = null;
				tempBitmapData = null;
			}

			if (!buttonDownTexture) {
				var tempSprite2:Sprite = new Sprite();
				var tempBitmapData2:BitmapData = new BitmapData(_buttonradius * 2, _buttonradius * 2, true, 0x00FFFFFF);

				tempSprite2.graphics.clear();
				tempSprite2.graphics.beginFill(0xEE0000, 0.85);
				tempSprite2.graphics.drawCircle(_buttonradius, _buttonradius, _buttonradius);
				tempSprite2.graphics.endFill();
				tempBitmapData2.draw(tempSprite2);
				buttonDownTexture = Texture.fromBitmapData(tempBitmapData2);
				tempSprite2 = null;
				tempBitmapData2 = null;
			}

			button = new Image(buttonUpTexture);
			button.pivotX = button.pivotY = _buttonradius;

			tempSprite = null;
			tempBitmapData = null;

			graphic.x = _x;
			graphic.y = _y;

			graphic.addChild(button);

			Starling.current.stage.addChild(graphic);

			graphic.addEventListener(TouchEvent.TOUCH, handleTouch);
		}

		private function handleTouch(e:TouchEvent):void {
			
			var buttonTouch:Touch = e.getTouch(button);

			if (buttonTouch) {
				
				switch (buttonTouch.phase) {
					
					case TouchPhase.BEGAN:
						(buttonTouch.target as Image).texture = buttonDownTexture;
						triggerON(buttonAction, 1, buttonChannel);
						break;
						
					case TouchPhase.ENDED:
						(buttonTouch.target as Image).texture = buttonUpTexture;
						triggerOFF(buttonAction, 0, buttonChannel);
						break;
				}
			}
		}

		override public function get visible():Boolean
		{
			return _visible = graphic.visible;
		}
		
		override public function set visible(value:Boolean):void
		{
			_visible = graphic.visible = value;
		}

		override public function destroy():void {
			
			graphic.removeEventListener(TouchEvent.TOUCH, handleTouch);
			
			graphic.removeChildren();
			
			Starling.current.stage.removeChild(graphic);
			
			buttonUpTexture.dispose();
			buttonDownTexture.dispose();
			button.dispose();
			
			super.destroy();
		}
	}

}