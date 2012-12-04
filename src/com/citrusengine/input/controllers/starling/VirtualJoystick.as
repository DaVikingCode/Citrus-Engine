package com.citrusengine.input.controllers.starling {

	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	import com.citrusengine.input.controllers.AVirtualJoystick;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * Starling Virtual Joystick
	 * (drawing itself using flash graphics -> bitmapData -> Starling Texture)
	 */
	public class VirtualJoystick extends AVirtualJoystick
	{
		public var graphic:starling.display.Sprite; //main Sprite container.
		
		//seperate joystick elements
		protected var back:Image;
		protected var knob:Image;
		
		public function VirtualJoystick(name:String, params:Object = null)
		{
			super(name, params);
		}
		
		override protected function initGraphics():void
		{
			graphic = new starling.display.Sprite();
			
			if (!back)
			{
				//draw back
				var tempSprite:Sprite = new Sprite();
				var tempBitmapData:BitmapData = new BitmapData(_radius * 2, _radius * 2, true, 0x00FFFFFF);
				
				tempSprite.graphics.beginFill(0x000000, 0.1);
				tempSprite.graphics.drawCircle(_radius, _radius, _radius);
				tempBitmapData.draw(tempSprite);
				
				//draw arrows
				
				var m:int = 15; // margin
				var w:int = 30; // width
				var h:int = 40; // height
				
				tempSprite.graphics.clear();
				tempSprite.graphics.beginFill(0x000000, 0.2);
				tempSprite.graphics.moveTo(_radius, m);
				tempSprite.graphics.lineTo(_radius - w, h);
				tempSprite.graphics.lineTo(_radius + w, h);
				tempSprite.graphics.endFill();
				tempBitmapData.draw(tempSprite);
				
				tempSprite.graphics.clear();
				tempSprite.graphics.lineStyle();
				tempSprite.graphics.beginFill(0x000000, 0.2);
				tempSprite.graphics.moveTo(_radius, _radius * 2 - m);
				tempSprite.graphics.lineTo(_radius - w, _radius * 2 - h);
				tempSprite.graphics.lineTo(_radius + w, _radius * 2 - h);
				tempSprite.graphics.endFill();
				tempBitmapData.draw(tempSprite);
				
				tempSprite.graphics.clear();
				tempSprite.graphics.beginFill(0x000000, 0.2);
				tempSprite.graphics.moveTo(m, _radius);
				tempSprite.graphics.lineTo(h, _radius - w);
				tempSprite.graphics.lineTo(h, _radius + w);
				tempSprite.graphics.endFill();
				tempBitmapData.draw(tempSprite);
				
				tempSprite.graphics.clear();
				tempSprite.graphics.beginFill(0x000000, 0.2);
				tempSprite.graphics.moveTo(_radius * 2 - m, _radius);
				tempSprite.graphics.lineTo(_radius * 2 - h, _radius - w);
				tempSprite.graphics.lineTo(_radius * 2 - h, _radius + w);
				tempSprite.graphics.endFill();
				tempBitmapData.draw(tempSprite);
				
				back = new Image(Texture.fromBitmapData(tempBitmapData));
				
				tempSprite = null;
				tempBitmapData = null;
			}
			
			if (!knob)
			{
				//draw knob
				var tempSprite2:Sprite = new Sprite();
				var tempBitmapData2:BitmapData = new BitmapData(_radius * 2, _radius * 2, true, 0x00FFFFFF);
				
				tempSprite2.graphics.clear();
				tempSprite2.graphics.beginFill(0xEE0000, 0.85);
				tempSprite2.graphics.drawCircle(_knobradius, _knobradius, _knobradius);
				tempBitmapData2 = new BitmapData(_knobradius * 2, _knobradius * 2, true, 0x00FFFFFF);
				tempBitmapData2.draw(tempSprite2);
				
				knob = new Image(Texture.fromBitmapData(tempBitmapData2));
				
				tempSprite2 = null;
				tempBitmapData2 = null;
			}
			
			back.pivotX = back.pivotY = back.width / 2;
			graphic.addChild(back);
			
			knob.pivotX = knob.pivotY = knob.width / 2;
			graphic.addChild(knob);
			
			//move joystick
			graphic.x = _x;
			graphic.y = _y;
			
			//Add graphic
			Starling.current.stage.addChild(graphic);
			
			//Touch Events
			graphic.addEventListener(TouchEvent.TOUCH, handleTouch);
		}
		
		private function handleTouch(e:TouchEvent):void
		{
			var t:Touch = e.getTouch(graphic);
			if (!t)
				return;
			
			if (t.phase == TouchPhase.ENDED)
			{
				reset();
				_grabbed = false;
				return;
			}
			
			if (t.phase == TouchPhase.BEGAN)
			{
				_grabbed = true;
				_centered = false;
			}
			
			if (!_grabbed)
				return;
			
			var relativeX:int = t.globalX - graphic.x;
			var relativeY:int = t.globalY - graphic.y;
			
			handleGrab(relativeX, relativeY);
		
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
					knob.x = _knobX;
					knob.y = _knobY;
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
				
			}
		}
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			graphic.visible = value;
		}
		
		override public function destroy():void
		{
			back.dispose();
			knob.dispose();
			graphic.dispose();
			
			_xAxisActions = null;
			_yAxisActions = null;
			
			super.destroy();
		}
	
	}

}