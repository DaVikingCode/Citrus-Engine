package citrus.input.controllers.displaylist {

	import citrus.input.controllers.AVirtualButton;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class VirtualButton extends AVirtualButton
	{
		public var graphic:Sprite; //main Sprite container.
		
		protected var button:Sprite;
		
		public var buttonUpGraphic:Sprite;
		public var buttonDownGraphic:Sprite;
		
		public function VirtualButton(name:String, params:Object = null)
		{
			super(name, params);
		}
		
		override protected function initGraphics():void
		{
			button = new Sprite();
			graphic = new Sprite();
			
			if (!buttonUpGraphic)
			{
				buttonUpGraphic = new Sprite();
				buttonUpGraphic.graphics.beginFill(0x000000, 0.1);
				buttonUpGraphic.graphics.drawCircle(0, 0, _buttonradius);
				buttonUpGraphic.graphics.endFill();
			}
			
			if (!buttonDownGraphic)
			{
				buttonDownGraphic = new Sprite();
				buttonDownGraphic.graphics.beginFill(0xEE0000, 0.85);
				buttonDownGraphic.graphics.drawCircle(0, 0, _buttonradius);
				buttonDownGraphic.graphics.endFill();
			}
			
			button.addChild(buttonUpGraphic);
			
			graphic.addChild(button);
			
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
			
			if (e.type == MouseEvent.MOUSE_DOWN && button == e.target.parent)
			{
				triggerON(buttonAction, 1, buttonChannel);
				button.removeChildAt(0);
				button.addChild(buttonDownGraphic);					
				
				_ce.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
			}
			
			if (e.type == MouseEvent.MOUSE_UP && button == e.target.parent)
			{
				triggerOFF(buttonAction, 0, buttonChannel);
				button.removeChildAt(0);
				button.addChild(buttonUpGraphic);
				
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