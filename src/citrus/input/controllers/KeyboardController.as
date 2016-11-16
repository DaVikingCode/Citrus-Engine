package citrus.input.controllers {
	import ash.signals.Signal3;

	import citrus.input.InputController;

	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	/**
	 *  The default Keyboard controller.
	 * 	A single key can trigger multiple actions, each of these can be sent to different channels.
	 *
	 *  Keyboard holds static keycodes constants (see bottom).
	 */
	public class KeyboardController extends InputController
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
		public var onKeyUp:Signal3;
		
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
		public var onKeyDown:Signal3;
		
		public var keyNames:Dictionary;
		
		public function KeyboardController(name:String, params:Object = null)
		{
			super(name, params);
			
			_keyActions = new Dictionary();
			
			//default arrow keys + space bar jump
			
			addKeyAction("left", Keyboard.LEFT);
			addKeyAction("up", Keyboard.UP);
			addKeyAction("right", Keyboard.RIGHT);
			addKeyAction("down", Keyboard.DOWN);
			addKeyAction("jump", Keyboard.SPACE);
			
			_ce.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			_ce.stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			
			onKeyUp = new Signal3(uint,int,Object);
			onKeyDown = new Signal3(uint,int,Object);
			
			keyNames = new Dictionary();
			var xmlDesc:XMLList = describeType(flash.ui.Keyboard).child("constant");
			var constName:String;
			var constVal:uint;
			for each(var key:XML in xmlDesc)
			{
				constName = key.attribute("name");
				constVal = flash.ui.Keyboard[constName];
				
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
	
	}

}