package citrus.input.controllers.gamepad 
{
	import citrus.input.controllers.gamepad.maps.FreeboxGamepadMap;
	import citrus.input.controllers.gamepad.maps.OUYAGamepadMap;
	import citrus.input.controllers.gamepad.maps.PS3GamepadMap;
	import citrus.input.controllers.gamepad.maps.Xbox360GamepadMap;
	import citrus.input.InputController;
	import flash.events.GameInputEvent;
	import flash.ui.GameInput;
	import flash.ui.GameInputDevice;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	
	public class GamePadManager extends InputController
	{
		protected static var _gameInput:GameInput = new GameInput();
		
		/**
		 * key = substring in devices id/name to recognize
		 * value = map class
		 */
		public var devicesMapDictionary:Dictionary;
		
		protected var _maxDevices:uint;
		
		protected var _gamePads:Dictionary;
		//default map should extend GamePadMap, will be applied to each new device plugged in.
		protected var _defaultMap:Class;
		//maximum number of game input devices we can add (as gamepads)
		protected var _maxPlayers:uint = 0;
		//last channel used (by the last device plugged in)
		protected var _lastChannel:uint = 0;
		
		protected static var _instance:GamePadManager;
		
		/**
		 * dispatches a newly created Gamepad object when a new GameInputDevice is added.
		 */
		public var onControllerAdded:Signal;
		/**
		 * dispatches the Gamepad object corresponding to the GameInputDevice that got removed.
		 */
		public var onControllerRemoved:Signal;
		
		public function GamePadManager(maxPlayers:uint = 1, defaultMap:Class = null) 
		{
			super("GamePadManager", null);
			
			_maxDevices = maxPlayers;
			
			if (!GameInput.isSupported)
			{
				trace(this, "GameInput is not supported.");
				return;
			}
			
			
			initdevicesMapDictionaryMaps();
			_defaultMap = defaultMap;
			
			_gamePads = new Dictionary();
			
			onControllerAdded = new Signal(Gamepad);
			onControllerRemoved = new Signal(Gamepad);
			
			_gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, handleDeviceAdded);
			_gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, handleDeviceRemoved);
			
			
			var numDevices:uint;
			if ((numDevices = GameInput.numDevices) > 0)
			{
				var i:uint = 0;
				var device:GameInputDevice;
				for (; i < numDevices; i++)
				{
					device = GameInput.getDeviceAt(i);
					if(device)
						_gameInput.dispatchEvent(new GameInputEvent(GameInputEvent.DEVICE_ADDED, false, false, device));
					else
						trace(this, "tried to get a device at", i, "and it returned null. please reference or initialize the GamePadManager sooner in your app!");
				}
			}
			
			_instance = this;
		}
		
		public static function getInstance():GamePadManager
		{
			return _instance;
		}
		
		/**
		 * creates the dictionary for default game pad maps to apply.
		 * key = substring in GameInputDevice.name to look for,
		 * value = GamePadMap class to use for mapping the game pad correctly.
		 */
		protected function initdevicesMapDictionaryMaps():void
		{
			devicesMapDictionary = new Dictionary();
			devicesMapDictionary["Microsoft X-Box 360"] = Xbox360GamepadMap;
			devicesMapDictionary["Xbox 360 Controller"] = Xbox360GamepadMap;
			devicesMapDictionary["PLAYSTATION"] = PS3GamepadMap;
			devicesMapDictionary["OUYA"] = OUYAGamepadMap;
			devicesMapDictionary["Generic   USB  Joystick"] = FreeboxGamepadMap;
		}
		
		/**
		 * apply map according to devicesMapDictionary dictionnary.
		 * @param	gp
		 */
		protected function applyMap(device:GameInputDevice,gp:Gamepad):void
		{
			var substr:String;
			for (substr in devicesMapDictionary)
				if (device.name.indexOf(substr) > -1 || device.id.indexOf(substr) > -1)
				{
					gp.useMap(devicesMapDictionary[substr]);
					return;
				}
			if (Gamepad.debug)
				trace("[GamePadManager] No default map found in GamePadManager.devicesMapDictionary for", gp, ", trying to use defaultMap specified in the constructor.");
			gp.useMap(_defaultMap);
		}
		
		/**
		 * checks if device has a defined map in the devicesMapDictionary.
		 */
		public function isDeviceKnownGamePad(device:GameInputDevice):Boolean
		{
			var substr:String;
			for (substr in devicesMapDictionary)
				if (device.name.indexOf(substr) > -1 || device.id.indexOf(substr) > -1)
				{
					return true;
				}
			return false;
		}
		
		/**
		 * return the first gamePad using the defined channel.
		 * @param	channel
		 * @return
		 */
		public function getGamePadByChannel(channel:uint = 0):Gamepad
		{
			var pad:Gamepad;
			for each(pad in _gamePads)
				if (pad.defaultChannel == channel)
					return pad;
			return pad;
		}
		
		public function getGamePadAt(index:int = 0):Gamepad
		{
			var c:int = 0;
			for (var k:* in _gamePads)
			{
				if (c == index)
					return _gamePads[k] as Gamepad;
				c++;
			}
			return null;
		}
		
		protected var numDevicesAdded:int = 0;
		
		protected function handleDeviceAdded(e:GameInputEvent):void
		{
			if (_gamePads.length >= _maxDevices)
				return;
				
			var device:GameInputDevice = e.device;
			var deviceID:String = device.id;
			var pad:Gamepad;
			
			if (deviceID in _gamePads)
			{
				trace(deviceID, "already added");
				return;
			}
			
			pad = new Gamepad("gamepad" + numDevicesAdded, device, null);
			
			//check if we know a map for this device and apply it.
			applyMap(device,pad);
			
			numDevicesAdded++;
				
			if (numGamePads < _lastChannel)
			{
				pad.defaultChannel = _lastChannel -  numGamePads;
			}
			else
			{
				pad.defaultChannel = _lastChannel++;
			}
			
			_gamePads[pad.deviceID] = pad;
			onControllerAdded.dispatch(pad);
		}
		
		protected function handleDeviceRemoved(e:GameInputEvent):void
		{
			numDevicesAdded--;
			var id:String;
			var pad:Gamepad;
			for (id in _gamePads)
			{
				pad = _gamePads[id];
				if (pad.device == e.device)
					break;
			}
			
			if (!pad)
				return;
			
			delete _gamePads[id];
			pad.destroy();
			onControllerRemoved.dispatch(pad);
		}
		
		override public function destroy():void
		{
			_gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, handleDeviceAdded);
			_gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, handleDeviceRemoved);
			
			var gp:Gamepad;
			for (var name:String in _gamePads)
			{
				gp = _gamePads[name];
				delete _gamePads[name];
				gp.destroy();
			}
			devicesMapDictionary = null;
			_defaultMap = null;
			onControllerAdded.removeAll();
			onControllerRemoved.removeAll();
			super.destroy();
		}
		
		public function get defaultMap():Class
		{
			return _defaultMap;
		}
		
		public function get numGamePads():int
		{
			var count:int = 0;
			for (var k:* in _gamePads)
				count++;
			return count;
		}
		
		public static const GAMEPAD_ADDED_ACTION:String = "GAMEPAD_ADDED_ACTION";
		public static const GAMEPAD_REMOVED_ACTION:String = "GAMEPAD_REMOVED_ACTION";
	}

}