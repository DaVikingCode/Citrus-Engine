package com.citrusengine.input.controllers.graphical.simple {

	import com.citrusengine.input.controllers.graphical.BaseVirtualButtons;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class VirtualButtons extends BaseVirtualButtons
	{
		public var graphic:Sprite; //main Sprite container.
		
		protected var button1:Sprite;
		protected var button2:Sprite;
		
		protected var button1UpGraphic:Sprite;
		protected var button1DownGraphic:Sprite;
		
		protected var button2UpGraphic:Sprite;
		protected var button2DownGraphic:Sprite;
		
		public function VirtualButtons(name:String, params:Object = null)
		{
			super(name, params);
		}
		
		override protected function initGraphics():void
		{
			button1 = new Sprite();
			button2 = new Sprite();
			graphic = new Sprite();
			
			if (!button1UpGraphic)
			{
				button1UpGraphic = new Sprite();
				button1UpGraphic.graphics.beginFill(0x000000, 0.1);
				button1UpGraphic.graphics.drawCircle(0, 0, _buttonradius);
				button1UpGraphic.graphics.endFill();
			}
			
			if (!button1DownGraphic)
			{
				button1DownGraphic = new Sprite();
				button1DownGraphic.graphics.beginFill(0xEE0000, 0.85);
				button1DownGraphic.graphics.drawCircle(0, 0, _buttonradius);
				button1DownGraphic.graphics.endFill();
			}
			
			if (!button2UpGraphic)
			{
				button2UpGraphic = new Sprite();
				button2UpGraphic.graphics.beginFill(0x000000, 0.1);
				button2UpGraphic.graphics.drawCircle(0, 0, _buttonradius);
				button2UpGraphic.graphics.endFill();
			}
			
			if (!button2DownGraphic)
			{
				button2DownGraphic = new Sprite();
				button2DownGraphic.graphics.beginFill(0xEE0000, 0.85);
				button2DownGraphic.graphics.drawCircle(0, 0, _buttonradius);
				button2DownGraphic.graphics.endFill();
			}
			
			button1.addChild(button1UpGraphic);
			button2.addChild(button2UpGraphic);
			
			button2.x += _margin;
			
			graphic.addChild(button1);
			graphic.addChild(button2);
			
			graphic.x = _x;
			graphic.y = _y;
			
			//Add graphic
			_ce.stage.addChild(graphic);
			
			//MOUSE EVENTS 
			
			graphic.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvent);
			graphic.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
		}
		
		private function handleMouseEvent(e:MouseEvent):void
		{
			
			if (e.type == MouseEvent.MOUSE_DOWN)
			{
				switch (e.target.parent)
				{
					case button1:
						triggerON({name: button1Action, value: 1});
						button1.removeChildAt(0);
						button1.addChild(button1DownGraphic);
						break;
					case button2:
						triggerON({name: button2Action, value: 1});
						button2.removeChildAt(0);
						button2.addChild(button2DownGraphic);
						break;
				}
				_ce.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
			}
			
			if (e.type == MouseEvent.MOUSE_UP)
			{
				switch (e.target.parent)
				{
					case button1:
						triggerOFF({name: button1Action, value: 0});
						button1.removeChildAt(0);
						button1.addChild(button1UpGraphic);
						break;
					case button2:
						triggerOFF({name: button2Action, value: 0});
						button2.removeChildAt(0);
						button2.addChild(button2UpGraphic);
						break;
					default :
						triggerOFF( { name: button2Action, value: 0 } );
						triggerOFF( { name: button1Action, value: 0 } );
						button2.removeChildAt(0);
						button2.addChild(button2UpGraphic);
						button1.removeChildAt(0);
						button1.addChild(button1UpGraphic);
						break;
				}
				_ce.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
			}
		}
		
		override public function set visible(value:Boolean):void
		{
			graphic.visible = value;
			_visible = value;
		}
		
		override public function destroy():void
		{
			//remove mouse events.
			graphic.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvent);
			graphic.removeEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
			
			//remove graphic
			_ce.stage.removeChild(graphic);
		}
	}

}