package com.citrusengine.core
{
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	/**
	 * A class managing Keyboard's input.
	 */
	public class InputDeprecated
	{
		public static const JUST_PRESSED:uint = 0;
		public static const DOWN:uint = 1;
		public static const JUST_RELEASED:uint = 2;
		public static const UP:uint = 3;
		
		protected var _ce:CitrusEngine;
		
		protected var _keys:Dictionary;
		protected var _keysReleased:Vector.<uint>;
		protected var _initialized:Boolean;
		protected var _enabled:Boolean = true;
		
		public function InputDeprecated() 
		{
			_keys = new Dictionary();
			_keysReleased = new Vector.<uint>;
			
			_ce = CitrusEngine.getInstance();
		}
		
		public function destroy():void {
			
			_keys = null;
			_keysReleased = null;
			
			_ce.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_ce.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		/**
		 * Sets and determines whether or not keypresses will be
		 * registered through the Input class. 
		 */		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if (_enabled == value)
				return;
			
			_enabled = value;
			
			if (_enabled)
			{
				_ce.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_ce.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
			else
			{
				_ce.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_ce.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
		}
		
		/**
		 * This method should be called AFTER everything has gathered input data from it for this tick.
		 * Implementors, you don't need to call this function. Citrus Engine does it for you.
		 */		
		public function update():void
		{
			if (!_enabled)
				return;
			
			for (var key:Object in _keys)
			{
				if (_keys[key] == JUST_PRESSED)
					_keys[key] = DOWN;
			}
			
			_keysReleased.length = 0;
		}
		
		/**
		 * Citrus engine calls this function for you. 
		 */		
		public function initialize():void
		{
			if (_initialized)
				return;
			
			_initialized = true;
			
			_ce.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_ce.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		/**
		 * Says YES! if the key you requested is being pressed. Says nah if naht. 
		 * @param keyCode a "code" representing a key on the keyboard. Use Flash's Keyboard class constants if you please. 
		 */		
		public function isDown(keyCode:int):Boolean
		{
			return _keys[keyCode] == DOWN;
		}
		
		/**
		 * Says YES! if the key you requested was pressed between last tick and this tick. Says nah if naht. 
		 * @param keyCode a "code" representing a key on the keyboard. Use Flash's Keyboard class constants if you please. 
		 */	
		public function justPressed(keyCode:int):Boolean
		{
			return _keys[keyCode] == JUST_PRESSED;
		}
		
		/**
		 * Says YES! if the key you requested was released between last keick and this tick. Says nah if naht. 
		 * @param keyCode a "code" representing a key on the keyboard. Use Flash's Keyboard class constants if you please. 
		 */	
		public function justReleased(keyCode:int):Boolean
		{
			return _keysReleased.indexOf(keyCode) != -1;
		}
		
		/**
		 * Returns an unsigned integer representing the key's current state.
		 * @param keyCode a "code" representing a key on the keyboard. Use Flash's Keyboard class constants if you please. 
		 */		
		public function getState(keyCode:int):uint
		{
			if (_keys[keyCode])
				return _keys[keyCode];
			else if (_keysReleased.indexOf(keyCode) != -1)
				return JUST_RELEASED;
			else
				return UP;
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (!_keys[e.keyCode])
				_keys[e.keyCode] = JUST_PRESSED;
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			delete _keys[e.keyCode];
			_keysReleased.push(e.keyCode);
		}
	}

}