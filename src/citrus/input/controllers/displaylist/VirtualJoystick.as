package citrus.input.controllers.displaylist {

	import citrus.input.controllers.AVirtualJoystick;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * Simple Flash Virtual Joystick
	 */
	public class VirtualJoystick extends AVirtualJoystick
	{
		public var graphic:Sprite; //main Sprite container.
		
		//separate joystick elements
		public var back:Sprite;
		public var knob:Sprite;
		
		public function VirtualJoystick(name:String, params:Object = null)
		{
			graphic = new Sprite();
			super(name, params);
			
			_innerradius = _radius - _knobradius;
			
			_x = _x ? _x : 2*_innerradius;
			_y = _y ? _y : _ce.stage.stageHeight - 2*_innerradius;
			
			initActionRanges();
			initGraphics();
			
			_updateEnabled = true;
		}
		
		override protected function initGraphics():void
		{
			
			if (!back)
			{
				//draw back
				back = new Sprite();
				back.graphics.beginFill(0x000000, 0.1);
				back.graphics.drawCircle(0, 0, _radius);
				
				//draw arrows
				
				var m:int = 15; // margin
				var w:int = 30; // width
				var h:int = 40; // height
				
				back.graphics.beginFill(0x000000, 0.2);
				back.graphics.moveTo(0, -_radius + m);
				back.graphics.lineTo(-w, -_radius + h);
				back.graphics.lineTo(w, -_radius + h);
				back.graphics.endFill();
				
				back.graphics.beginFill(0x000000, 0.2);
				back.graphics.moveTo(0, _radius - m);
				back.graphics.lineTo(-w, _radius - h);
				back.graphics.lineTo(+w, _radius - h);
				back.graphics.endFill();
				
				back.graphics.beginFill(0x000000, 0.2);
				back.graphics.moveTo(-_radius + m, 0);
				back.graphics.lineTo(-_radius + h, -w);
				back.graphics.lineTo(-_radius + h, w);
				back.graphics.endFill();
				
				back.graphics.beginFill(0x000000, 0.2);
				back.graphics.moveTo(_radius - m, 0);
				back.graphics.lineTo(_radius - h, -w);
				back.graphics.lineTo(_radius - h, +w);
				back.graphics.endFill();
				
			}
			
			if (!knob)
			{
				knob = new Sprite();
				
				knob.graphics.beginFill(0xEE0000, 0.85);
				knob.graphics.drawCircle(0, 0, _knobradius);
			}
			
			graphic.addChild(back);
			graphic.addChild(knob);
			
			graphic.x = _x;
			graphic.y = _y;
			
			_ce.stage.addChild(graphic);
			
			graphic.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvent);
		}
		
		private function handleMouseEvent(e:MouseEvent):void
		{
			if (e.type == MouseEvent.MOUSE_DOWN && !_grabbed)
			{
				_grabbed = true;
				_centered = false;
				handleGrab(graphic.mouseX, graphic.mouseY);
				
				_ce.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
				_ce.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseEvent);
				
				graphic.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvent);
			}
			
			if (e.type == MouseEvent.MOUSE_MOVE && _grabbed)
				handleGrab(graphic.mouseX, graphic.mouseY);
			
			if (e.type == MouseEvent.MOUSE_UP && _grabbed)
			{
				graphic.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvent);
				
				_ce.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
				_ce.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseEvent);
				
				handleGrab(graphic.mouseX, graphic.mouseY);
				reset();
				_grabbed = false;
			}
		}
		
		//properties for knob tweening.
		private var _vx:Number = 0;
		private var _vy:Number = 0;
		private var _spring:Number = 400;
		private var _friction:Number = 0.0005;
		
		override public function update():void
		{
			if (visible)
			{
				//update knob graphic
				if (_grabbed)
				{
					knob.x = _targetPosition.x;
					knob.y = _targetPosition.y;
				}
				else if (!_centered && !((knob.x > -0.5 && knob.x < 0.5) && (knob.y > -0.5 && knob.y < 0.5)))
				{
					//http://snipplr.com/view/51769/
					_vx += -knob.x * _spring;
					_vy += -knob.y * _spring;
					
					knob.x += (_vx *= _friction);
					knob.y += (_vy *= _friction);
				}
				else
					_centered = true;
					
				if (_grabbed)
					graphic.alpha = activeAlpha;
				else
					graphic.alpha = inactiveAlpha;
				
			}
		}
		
		override protected function reset():void
		{
			super.reset();
			graphic.x = _x;
			graphic.y = _y;
		}
		
		public function get visible():Boolean
		{
			return _visible = graphic.visible;
		}
		
		public function set visible(value:Boolean):void
		{
			graphic.visible = _visible = value;
		}
		
		override public function destroy():void
		{
			graphic.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvent);
			
			_ce.stage.removeChild(graphic);
			
			_xAxisActions = null;
			_yAxisActions = null;
			
			super.destroy();
		}
	
	}

}