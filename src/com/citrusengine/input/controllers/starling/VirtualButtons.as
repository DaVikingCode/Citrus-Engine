package com.citrusengine.input.controllers.starling {

	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	import com.citrusengine.input.controllers.AVirtualButtons;

	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class VirtualButtons extends AVirtualButtons {

		public var graphic:starling.display.Sprite;
		// main Sprite container.

		protected var button1:Image;
		protected var button2:Image;

		protected var buttonUpTexture:Texture;
		protected var buttonDownTexture:Texture;

		public function VirtualButtons(name:String, params:Object = null) {
			super(name, params);
		}

		override protected function initGraphics():void {
			
			graphic = new starling.display.Sprite();

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

			button1 = new Image(buttonUpTexture);
			button1.pivotX = button1.pivotY = _buttonradius;

			button2 = new Image(buttonUpTexture);
			button2.pivotX = button2.pivotY = _buttonradius;

			tempSprite = null;
			tempBitmapData = null;

			button2.x += _margin;

			graphic.x = _x;
			graphic.y = _y;

			graphic.addChild(button1);
			graphic.addChild(button2);

			Starling.current.stage.addChild(graphic);

			graphic.addEventListener(TouchEvent.TOUCH, handleTouch);
		}

		private function handleTouch(e:TouchEvent):void {
			
			var b1:Touch = e.getTouch(button1);
			var b2:Touch = e.getTouch(button2);

			if (b1) {
				
				switch (b1.phase) {
					
					case TouchPhase.BEGAN:
						(b1.target as Image).texture = buttonDownTexture;
						triggerON({name:button1Action, value:1});
						break;
						
					case TouchPhase.ENDED:
						(b1.target as Image).texture = buttonUpTexture;
						triggerOFF({name:button1Action, value:0});
						break;
				}
			}

			if (b2) {
				
				switch (b2.phase) {
					
					case TouchPhase.BEGAN:
						(b2.target as Image).texture = buttonDownTexture;
						triggerON({name:button2Action, value:1});
						break;
						
					case TouchPhase.ENDED:
						(b2.target as Image).texture = buttonUpTexture;
						triggerOFF({name:button2Action, value:0});
						break;
				}
			}
		}

		override public function set visible(value:Boolean):void {
			
			graphic.visible = value;
			_visible = value;
		}

		override public function destroy():void {
			
			graphic.removeEventListener(TouchEvent.TOUCH, handleTouch);
			
			buttonUpTexture.dispose();
			buttonDownTexture.dispose();
			button1.dispose();
			button2.dispose();
		}
	}

}