package citrus.input.controllers {
	import citrus.input.InputController;

	import org.osflash.signals.Signal;

	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	/**
	 *  The default Keyboard controller.
	 * 	A single key can trigger multiple actions, each of these can be sent to different channels.
	 *
	 *  Keyboard holds static keycodes constants (see bottom).
	 */
	public class Keyboard extends InputController
	{
		protected var _keyActions:Dictionary;
		
		/**
		 * on native keyboard key up, dispatches keyCode and keyLocation as well as a 'vars' object which you can use to prevent default or stop immediate propagation of the native event.
		 * see the code below :
		 * 
		 * <code>
		 * public function onSoftKeys(keyCode:int,keyLocation:int,vars:Object):void
		 *	{
		 *		switch (keyCode)
		 *		{ 
		 *			case Keyboard.BACK: 
		 *				vars.prevent = true;
		 *	 			trace("back button, default prevented.");
		 *				break; 
		 *			case Keyboard.MENU: 
		 *				trace("menu");
		 *				break; 
		 *			case Keyboard.SEARCH: 
		 *				trace("search");
		 *				break; 
		 * 			case Keyboard.ENTER:
		 * 				vars.stop = true;
		 *				trace("enter, will not go through the input system because propagation was stopped.");
		 *				break; 
		 *		}
		 *	}
		 * </code>
		 */
		public var onKeyUp:Signal;
		
		/**
		 * on native keyboard key down, dispatches keyCode and keyLocation as well as a 'vars' object which you can use to prevent default or stop immediate propagation of the native event.
		 * see the code below :
		 * 
		 * <code>
		 * public function onSoftKeys(keyCode:int,keyLocation:int,vars:Object):void
		 *	{
		 *		switch (keyCode)
		 *		{ 
		 *			case Keyboard.BACK: 
		 *				vars.prevent = true;
		 *	 			trace("back button, default prevented.");
		 *				break; 
		 *			case Keyboard.MENU: 
		 *				trace("menu");
		 *				break; 
		 *			case Keyboard.SEARCH: 
		 *				trace("search");
		 *				break; 
		 * 			case Keyboard.ENTER:
		 * 				vars.stop = true;
		 *				trace("enter, will not go through the input system because propagation was stopped.");
		 *				break; 
		 *		}
		 *	}
		 * </code>
		 */
		public var onKeyDown:Signal;
		
		public var keyNames:Dictionary;
		
		public function Keyboard(name:String, params:Object = null)
		{
			super(name, params);
			
			_keyActions = new Dictionary();
			
			//default arrow keys + space bar jump
			
			addKeyAction("left", LEFT);
			addKeyAction("up", UP);
			addKeyAction("right", RIGHT);
			addKeyAction("down", DOWN);
			addKeyAction("jump", SPACE);
			
			_ce.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			_ce.stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			
			onKeyUp = new Signal(uint,int,Object);
			onKeyDown = new Signal(uint,int,Object);
			
			keyNames = new Dictionary();
			var xmlDesc:XMLList = describeType(Keyboard).child("constant");
			var constName:String;
			var constVal:uint;
			for each(var key:XML in xmlDesc)
			{
				constName = key.attribute("name");
				constVal = Keyboard[constName];
				
				//don't register the azerty helper constants
				if(constName.substr(0,7) == "AZERTY_")
					continue;
				
				if(constVal is uint)
					keyNames[constVal] = constName;
			}
		}
		
		private function handleKeyDown(e:KeyboardEvent):void
		{
			if (onKeyDown.numListeners > 0)
			{
				var vars:Object = { prevent:false, stop:false };
				onKeyDown.dispatch(e.keyCode, e.keyLocation, vars );
				if (vars.prevent)
					e.preventDefault();
				if (vars.stop)
				{
					e.stopImmediatePropagation();
					return;
				}
			}
				
			if (_keyActions[e.keyCode])
			{
				var a:Object;
				for each (a in _keyActions[e.keyCode])
				{
					triggerON(a.name, 1, null, (a.channel < 0 ) ? defaultChannel : a.channel);
				}
			}
		}
		
		private function handleKeyUp(e:KeyboardEvent):void
		{
			if (onKeyUp.numListeners > 0)
			{
				var vars:Object = { prevent:false, stop:false };
				onKeyUp.dispatch(e.keyCode, e.keyLocation, vars );
				if (vars.prevent)
					e.preventDefault();
				if (vars.stop)
				{
					e.stopImmediatePropagation();
					return;
				}
			}
				
			if (_keyActions[e.keyCode])
			{
				var a:Object;
				for each (a in _keyActions[e.keyCode])
				{
					triggerOFF(a.name, 0, null, (a.channel < 0 ) ? defaultChannel : a.channel);
				}
			}
		}
		
		/**
		 * Add an action to a Key if action doesn't exist on that Key.
		 */
		public function addKeyAction(actionName:String, keyCode:uint, channel:int = -1):void
		{
			if (!_keyActions[keyCode])
				_keyActions[keyCode] = new Vector.<Object>();
			else
			{
				var a:Object;
				for each (a in _keyActions[keyCode])
					if (a.name == actionName && a.channel == channel)
						return;
			}
			
			/*if (channel < 0)
				channel = defaultChannel;*/
			
			_keyActions[keyCode].push({name: actionName, channel: channel});
		}
		
		/**
		 * Removes action from a key code, by name.
		 */
		public function removeActionFromKey(actionName:String, keyCode:uint):void
		{
			if (_keyActions[keyCode])
			{
				var actions:Vector.<Object> = _keyActions[keyCode];
				var i:String;
				for (i in actions)
					if (actions[i].name == actionName)
					{
						triggerOFF(actionName);
						actions.splice(uint(i), 1);
						return;
					}
			}
		}
		
		/**
		 * Removes every actions by name, on every keys.
		 */
		public function removeAction(actionName:String):void
		{
			var actions:Vector.<Object>;
			var i:String;
			for each (actions in _keyActions)
				for (i in actions)
					if (actions[uint(i)].name == actionName)
					{
						triggerOFF(actionName);
						actions.splice(uint(i), 1);
					}
		}
		
		/**
		 * Deletes the entire registry of key actions.
		 */
		public function resetAllKeyActions():void
		{
			_keyActions = new Dictionary();
			_ce.input.stopActionsOf(this);
		}
		
		/**
		 * Helps swap actions from a key to another key.
		 */
		public function changeKeyAction(previousKey:uint, newKey:uint):void
		{
			
			var actions:Vector.<Object> = getActionsByKey(previousKey);
			setKeyActions(newKey, actions);
			removeKeyActions(previousKey);
		}
		
		/**
		 * Sets all actions on a key
		 */
		private function setKeyActions(keyCode:uint, actions:Vector.<Object>):void
		{
			
			if (!_keyActions[keyCode])
				_keyActions[keyCode] = actions;
			_ce.input.stopActionsOf(this);
		}
		
		/**
		 * Removes all actions on a key.
		 */
		public function removeKeyActions(keyCode:uint):void
		{
			delete _keyActions[keyCode];
			_ce.input.stopActionsOf(this);
		}
		
		/**
		 * Returns all actions on a key in Vector format or returns null if none.
		 */
		public function getActionsByKey(keyCode:uint):Vector.<Object>
		{
			if (_keyActions[keyCode])
				return _keyActions[keyCode];
			else
				return null;
		}
		
		/**
		 * returns an array of all the names of the keys that will trigger the action.
		 * @param channel filter by channel number, if -1, all key/action/channel combinations are considered
		 */
		public function getKeysFromAction(actionName:String, channel:int = -1):Array
		{
			var arr:Array = [];
			for(var k:String in _keyActions)
				for each(var o:Object in _keyActions[uint(k)])
					if(o.name == actionName && ( channel > -1 ? o.channel > -1 ? o.channel == channel : true : true ) )
						arr.push(keyNames[uint(k)]);
						
			return arr;
		}
		
		/**
		 * returns the name of the first found key that should trigger the action.
		 * @param channel filter by channel number, if -1, all key/action/channel combinations are considered
		 */
		public function getKeyFromAction(actionName:String, channel:int = -1):String
		{
			var result:Array = getKeysFromAction(actionName,channel);
			if(result && result.length > 0)
				return result[0];
			else
				return null;
		}
		
		override public function destroy():void
		{
			onKeyUp.removeAll();
			onKeyDown.removeAll();
			
			_ce.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			_ce.stage.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			
			_keyActions = null;
			
			super.destroy();
		}
		
		/*
		 *  KEYCODES
		 *  they refer to the character written on a key (the first bottom left one if there are many).
		 *  based on commonly used QWERTY keyboard.
		 *
		 *  some regular AZERTY special chars based on a French AZERTY Layout are added for
		 *  your convenience (so you can refer to them if you have a similar layout) :
		 *  ²)=^$ù*!
		 */
		
		public static const NUMBER_0:uint = 48;
		public static const NUMBER_1:uint = 49;
		public static const NUMBER_2:uint = 50;
		public static const NUMBER_3:uint = 51;
		public static const NUMBER_4:uint = 52;
		public static const NUMBER_5:uint = 53;
		public static const NUMBER_6:uint = 54;
		public static const NUMBER_7:uint = 55;
		public static const NUMBER_8:uint = 56;
		public static const NUMBER_9:uint = 57;
		
		public static const A:uint = 65;
		public static const B:uint = 66;
		public static const C:uint = 67;
		public static const D:uint = 68;
		public static const E:uint = 69;
		public static const F:uint = 70;
		public static const G:uint = 71;
		public static const H:uint = 72;
		public static const I:uint = 73;
		public static const J:uint = 74;
		public static const K:uint = 75;
		public static const L:uint = 76;
		public static const M:uint = 77;
		public static const N:uint = 78;
		public static const O:uint = 79;
		public static const P:uint = 80;
		public static const Q:uint = 81;
		public static const R:uint = 82;
		public static const S:uint = 83;
		public static const T:uint = 84;
		public static const U:uint = 85;
		public static const V:uint = 86;
		public static const W:uint = 87;
		public static const X:uint = 88;
		public static const Y:uint = 89;
		public static const Z:uint = 90;
		
		public static const BACKSPACE:uint = 8;
		public static const TAB:uint = 9;
		public static const ENTER:uint = 13;
		public static const SHIFT:uint = 16;
		public static const CTRL:uint = 17;
		public static const CAPS_LOCK:uint = 20;
		public static const ESCAPE:uint = 27;
		public static const SPACE:uint = 32;
		
		public static const PAGE_UP:uint = 33;
		public static const PAGE_DOWN:uint = 34;
		public static const END:uint = 35;
		public static const HOME:uint = 36;
		
		public static const LEFT:uint = 37;
		public static const UP:uint = 38;
		public static const RIGHT:uint = 39;
		public static const DOWN:uint = 40;
		
		public static const INSERT:uint = 45;
		public static const DELETE:uint = 46;
		public static const BREAK:uint = 19;
		public static const NUM_LOCK:uint = 144;
		public static const SCROLL_LOCK:uint = 145;
		
		public static const NUMPAD_0:uint = 96;
		public static const NUMPAD_1:uint = 97;
		public static const NUMPAD_2:uint = 98;
		public static const NUMPAD_3:uint = 99;
		public static const NUMPAD_4:uint = 100;
		public static const NUMPAD_5:uint = 101;
		public static const NUMPAD_6:uint = 102;
		public static const NUMPAD_7:uint = 103;
		public static const NUMPAD_8:uint = 104;
		public static const NUMPAD_9:uint = 105;
		
		public static const NUMPAD_MULTIPLY:uint = 105;
		public static const NUMPAD_ADD:uint = 107;
		public static const NUMPAD_ENTER:uint = 13;
		public static const NUMPAD_SUBTRACT:uint = 109;
		public static const NUMPAD_DECIMAL:uint = 110;
		public static const NUMPAD_DIVIDE:uint = 111;
		
		public static const F1:uint = 112;
		public static const F2:uint = 113;
		public static const F3:uint = 114;
		public static const F4:uint = 115;
		public static const F5:uint = 116;
		public static const F6:uint = 117;
		public static const F7:uint = 118;
		public static const F8:uint = 119;
		public static const F9:uint = 120;
		public static const F10:uint = 121;
		public static const F11:uint = 122;
		public static const F12:uint = 123;
		public static const F13:uint = 124;
		public static const F14:uint = 125;
		public static const F15:uint = 126;
		
		public static const COMMAND:uint = 15;
		public static const ALTERNATE:uint = 18;
		
		public static const BACKQUOTE:uint = 192;
		public static const QUOTE:uint = 222;
		public static const COMMA:uint = 188;
		public static const PERIOD:uint = 190;
		public static const SEMICOLON:uint = 186;
		public static const BACKSLASH:uint = 220;
		public static const SLASH:uint = 191;
		
		public static const EQUAL:uint = 187;
		public static const MINUS:uint = 189;
		
		public static const LEFT_BRACKET:uint = 219;
		public static const RIGHT_BRACKET:uint = 221;
		
		public static const AUDIO:uint = 0x01000017;
		public static const BACK:uint = 0x01000016;
		public static const MENU:uint =  0x01000012;
		public static const SEARCH:uint =  0x0100001F;
		
		//HELPER FOR AZERTY ----------------------------------
		public static const AZERTY_SQUARE:uint = 222; // ²
		public static const AZERTY_RIGHT_PARENTHESIS:uint = 219;
		public static const AZERTY_CIRCUMFLEX:uint = 221; // ^
		public static const AZERTY_DOLLAR_SIGN:uint = 186; // $
		public static const AZERTY_U_GRAVE:uint = 192; // ù
		public static const AZERTY_MULTIPLY:uint = 220; // *
		public static const AZERTY_EXCLAMATION_MARK:uint = 223; // !
	
	}

}