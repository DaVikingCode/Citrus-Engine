package citrus.input.controllers {

	import citrus.input.InputController;

	import flash.events.Event;
	import flash.events.GameInputEvent;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * Controller class for OUYA android game console. Based on Keyboard class for CE support and supports multiple controllers...sort of :)
	 * 
	 * using new GameInput api's for as3, http://www.adobe.com/devnet/air/articles/game-controllers-on-air.html
	 * 
	 */
	public class OUYAGamepad extends InputController
	{
		protected var _keyActions:Dictionary;
		
		// GameInput
		private var gameInput:GameInput;
		private var _device:GameInputDevice;
		private var _deviceEnabled:Boolean = false;
		
		public function OUYAGamepad(name:String, params:Object=null)
		{
			super(name, params);
			
			_keyActions = new Dictionary();
			
			// key actions 
			//addKeyAction("left", LEFT_JOYSTICK);
			
			gameInput = new GameInput();
			gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, handleDeviceAttached);
			gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, handleDeviceRemoved);
		}
		
		protected function handleDeviceRemoved(event:GameInputEvent):void
		{
			trace("OUYAGamepad Device is removed\n");
		}
		
		protected function handleDeviceAttached(e:GameInputEvent):void
		{
			trace("OUYAGamepad Device is added\n");
			GameInputControlName.initialize(e.device);
			
			for(var k:Number = 0; k < GameInput.numDevices; k ++) {
				_device = GameInput.getDeviceAt(k);
				var _controls:Vector.<String> = new Vector.<String>;
				_device.enabled = true;
				
				for (var i:Number = 0; i < _device.numControls; i++) {
					var control:GameInputControl = _device.getControlAt(i);
					control.addEventListener(Event.CHANGE,onChange);
					_controls[i] = control.id;
				}
				
				_device.startCachingSamples(30, _controls);
			}
			
			//for(var j:int=0; j<_controls.length; j++) trace(_controls[j]);
			_deviceEnabled = true;
		}
		
		
		private var control:GameInputControl;
		
		protected function onChange(e:Event):void {
			
			control = e.target as GameInputControl;
			var v:Number = Math.round(control.value*100) / 100;
			if (Math.abs(v) < 0.2) v = 0;
			if (_keyActions[control.name]) {
				var a:Object;
				for each (a in _keyActions[control.name]) {
					
					if (control.value == 0) {
						triggerOFF(a.name, 0, (a.channel < 0 ) ? defaultChannel : a.channel);
					} else if (control.value == 1) {
						triggerON(a.name, 1, (a.channel < 0) ? defaultChannel : a.channel);
					} else {
						triggerVALUECHANGE(a.name, v, (a.channel < 0) ? defaultChannel : a.channel);
					}
				}
			}
		}
		
		
		
		/**
		 * Add an action to a Key if action doesn't exist on that Key.
		 */
		public function addKeyAction(actionName:String, keyCode:String, channel:int = -1):void
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
		public function removeActionFromKey(actionName:String, keyCode:String):void
		{
			if (_keyActions[keyCode])
			{
				var actions:Vector.<Object> = _keyActions[keyCode];
				var i:String;
				for (i in actions)
					if (actions[i].name == actionName)
					{
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
					actions.splice(uint(i), 1);
		}
		
		/**
		 * Deletes the entire registry of key actions.
		 */
		public function resetAllKeyActions():void
		{
			_keyActions = new Dictionary();
		}
		
		/**
		 * Helps swap actions from a key to another key.
		 */
		public function changeKeyAction(previousKey:String, newKey:String):void
		{
			
			var actions:Vector.<Object> = getActionsByKey(previousKey);
			setKeyActions(newKey, actions);
			removeKeyActions(previousKey);
		}
		
		/**
		 * Sets all actions on a key
		 */
		private function setKeyActions(keyCode:String, actions:Vector.<Object>):void
		{
			
			if (!_keyActions[keyCode])
				_keyActions[keyCode] = actions;
		}
		
		/**
		 * Removes all actions on a key.
		 */
		public function removeKeyActions(keyCode:String):void
		{
			delete _keyActions[keyCode];
		}
		
		/**
		 * Returns all actions on a key in Vector format or returns null if none.
		 */
		public function getActionsByKey(keyCode:String):Vector.<Object>
		{
			if (_keyActions[keyCode])
				return _keyActions[keyCode];
			else
				return null;
		}
		

		
		
		
		
		
		/**
		 * update
		 */
		override public function update():void {
			
			return;
			if (!_deviceEnabled) return;
			
			// getCachedSamples
			var data:ByteArray = new ByteArray();
			var _device:GameInputDevice;
			_device = GameInput.getDeviceAt(0);
			
			try {
				var completed:int = _device.getCachedSamples(data, true);
			} catch(e:Error) {
				trace("getCachedSamples FAIL \n");
			}
			if(completed > 0 && data.length > 0) {
				trace("Number of samples are "+completed+" and byte length is "+data.length+" \n");
			}
		}
		
		
		
		
		/**
		 * destroy
		 */
		override public function destroy():void {
			
			super.destroy();
			
			trace("OUYAGamepad destroy");
			gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, handleDeviceAttached);
			gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, handleDeviceRemoved);
			
			_keyActions = null;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		/**
		 * button codes
		 */
		public static const O:String = "buttonO";
		public static const U:String = "buttonU";
		public static const Y:String = "buttonY";
		public static const A:String = "buttonA";
		
		public static const LEFT_BUMPER:String = "triggerTopLeft"; // boolean
		public static const RIGHT_BUMPER:String = "triggerTopRight"; // boolean
		
		public static const LEFT_TRIGGER:String = "joystickLeftTrigger"; // decimal value 0 - 1
		public static const RIGHT_TRIGGER:String = "joystickRightTrigger"; // decimal value 0 - 1
		
		public static const LEFT_TRIGGER_FULL_PRESS:String = "triggerBottomLeft"; // boolean
		public static const RIGHT_TRIGGER_FULL_PRESS:String = "triggerBottomRight"; // boolean
		
		public static const LEFT_JOYSTICK_X:String = "joystickLeftX"; // decimal value -1 - 1
		public static const LEFT_JOYSTICK_Y:String = "joystickLeftY"; // decimal value -1 - 1
		
		public static const RIGHT_JOYSTICK_X:String = "joystickRightX"; // decimal value -1 - 1
		public static const RIGHT_JOYSTICK_Y:String = "joystickRightY"; // decimal value -1 - 1
		
		public static const DPAD_UP:String = "dpadUp"; // boolean
		public static const DPAD_DOWN:String = "dpadDown"; // boolean
		public static const DPAD_LEFT:String = "dpadLeft"; // boolean
		public static const DPAD_RIGHT:String = "dpadRight"; // boolean
		
		public static const LEFT_JOYSTICK_PRESS:String = "joystickLeft"; // boolean
		public static const RIGHT_JOYSTICK_PRESS:String = "joystickRight"; // boolean
		
	}
}