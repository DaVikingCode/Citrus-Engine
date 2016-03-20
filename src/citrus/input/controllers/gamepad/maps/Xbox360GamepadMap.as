package citrus.input.controllers.gamepad.maps 
{
	import citrus.input.controllers.gamepad.controls.ButtonController;
	import citrus.input.controllers.gamepad.controls.StickController;
	import citrus.input.controllers.gamepad.Gamepad;

	public class Xbox360GamepadMap extends GamePadMap
	{
		public function Xbox360GamepadMap():void
		{
			
		}
		
		override public function setupMAC():void
		{
			setupWIN();
		}
		
		override public function setupLNX():void
		{
			setupWIN();
		}
		
		override public function setupWIN():void
		{
			var stick:StickController;
			
			stick = _gamepad.registerStick(GamePadMap.STICK_LEFT,"AXIS_0", "AXIS_1");
			stick.invertY = true; // AXIS_1 is inverted
			stick.threshold = 0.2;
			
			stick = _gamepad.registerStick(GamePadMap.STICK_RIGHT,"AXIS_2", "AXIS_3");
			stick.invertY = true; // AXIS_3 is inverted
			stick.threshold = 0.2;
			
			_gamepad.registerButton(GamePadMap.L1,"BUTTON_8");
			_gamepad.registerButton(GamePadMap.R1, "BUTTON_9");
			
			_gamepad.registerButton(GamePadMap.L2, "BUTTON_10");
			_gamepad.registerButton(GamePadMap.R2, "BUTTON_11");
			
			_gamepad.registerButton(GamePadMap.L3, "BUTTON_14");
			_gamepad.registerButton(GamePadMap.R3, "BUTTON_15");
			
			_gamepad.registerButton(GamePadMap.SELECT, "BUTTON_12");
			_gamepad.registerButton(GamePadMap.START, "BUTTON_13");
			
			_gamepad.registerButton(GamePadMap.DPAD_UP,"BUTTON_16","up");
			_gamepad.registerButton(GamePadMap.DPAD_DOWN,"BUTTON_17","down");
			_gamepad.registerButton(GamePadMap.DPAD_RIGHT,"BUTTON_19","right");
			_gamepad.registerButton(GamePadMap.DPAD_LEFT,"BUTTON_18","left");
			
			_gamepad.registerButton(GamePadMap.BUTTON_TOP, "BUTTON_7");
			_gamepad.registerButton(GamePadMap.BUTTON_RIGHT, "BUTTON_5");
			_gamepad.registerButton(GamePadMap.BUTTON_BOTTOM, "BUTTON_4");
			_gamepad.registerButton(GamePadMap.BUTTON_LEFT, "BUTTON_6");
		}
		
		override public function setupAND():void
		{
			var stick:StickController;
			var button:ButtonController;
			
			stick = _gamepad.registerStick(GamePadMap.STICK_LEFT,"AXIS_0", "AXIS_1");
			stick.threshold = 0.2;
			
			stick = _gamepad.registerStick(GamePadMap.STICK_RIGHT,"AXIS_11", "AXIS_14");
			stick.threshold = 0.2;
			
			_gamepad.registerButton(GamePadMap.L1,"BUTTON_102");
			_gamepad.registerButton(GamePadMap.R1, "BUTTON_103");
			
			_gamepad.registerButton(GamePadMap.L2, "AXIS_17");
			_gamepad.registerButton(GamePadMap.R2, "AXIS_18");
			
			_gamepad.registerButton(GamePadMap.L3, "BUTTON_106");
			_gamepad.registerButton(GamePadMap.R3, "BUTTON_107");

			_gamepad.registerButton(GamePadMap.START, "BUTTON_108");
			
			button = _gamepad.registerButton(GamePadMap.DPAD_UP, "AXIS_16", "up");
			button.inverted = true;
			
			_gamepad.registerButton(GamePadMap.DPAD_DOWN,"AXIS_16","down");
			_gamepad.registerButton(GamePadMap.DPAD_RIGHT, "AXIS_15", "right");
			
			button = _gamepad.registerButton(GamePadMap.DPAD_LEFT, "AXIS_15", "left");
			button.inverted = true;
			
			_gamepad.registerButton(GamePadMap.BUTTON_TOP, "BUTTON_100");
			_gamepad.registerButton(GamePadMap.BUTTON_RIGHT, "BUTTON_97");
			_gamepad.registerButton(GamePadMap.BUTTON_BOTTOM, "BUTTON_96");
			_gamepad.registerButton(GamePadMap.BUTTON_LEFT, "BUTTON_99");
		}
		
	}

}