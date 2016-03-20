package citrus.input.controllers.gamepad.maps 
{
	import citrus.input.controllers.gamepad.controls.StickController;
	import citrus.input.controllers.gamepad.Gamepad;
	public class PS3GamepadMap extends GamePadMap
	{
		
		public function PS3GamepadMap() 
		{
			
		}
		
		override public function setupMAC():void
		{
			var joy:StickController;
			
			joy = _gamepad.registerStick(GamePadMap.STICK_LEFT, "AXIS_0", "AXIS_1");
			joy.invertY = true;
			joy.threshold = 0.2;
			
			joy = _gamepad.registerStick(GamePadMap.STICK_RIGHT, "AXIS_2", "AXIS_3");
			joy.invertY = true;
			joy.threshold = 0.2;
			
			_gamepad.registerButton(GamePadMap.L1,"BUTTON_14");
			_gamepad.registerButton(GamePadMap.R1, "BUTTON_15");
			
			_gamepad.registerButton(GamePadMap.L2, "BUTTON_12");
			_gamepad.registerButton(GamePadMap.R2, "BUTTON_13");
			
			
			_gamepad.registerButton(GamePadMap.SELECT, "BUTTON_4");
			_gamepad.registerButton(GamePadMap.START, "BUTTON_7");
			
			_gamepad.registerButton(GamePadMap.L3, "BUTTON_5");
			_gamepad.registerButton(GamePadMap.R3, "BUTTON_6");
			
			_gamepad.registerButton(GamePadMap.DPAD_UP,"BUTTON_8","up");
			_gamepad.registerButton(GamePadMap.DPAD_DOWN,"BUTTON_10","down");
			_gamepad.registerButton(GamePadMap.DPAD_RIGHT,"BUTTON_9","right");
			_gamepad.registerButton(GamePadMap.DPAD_LEFT,"BUTTON_11","left");
			
			_gamepad.registerButton(GamePadMap.BUTTON_BOTTOM, "BUTTON_18"); // X
			_gamepad.registerButton(GamePadMap.BUTTON_LEFT, "BUTTON_19"); //   square
			_gamepad.registerButton(GamePadMap.BUTTON_TOP, "BUTTON_16"); //   triangle
			_gamepad.registerButton(GamePadMap.BUTTON_RIGHT, "BUTTON_17"); //  circle
		}
		
		override public function setupAND():void
		{
			var joy:StickController;
			
			joy = _gamepad.registerStick(GamePadMap.STICK_LEFT, "AXIS_0", "AXIS_1");
			joy.threshold = 0.2;
			
			joy = _gamepad.registerStick(GamePadMap.STICK_RIGHT, "AXIS_11", "AXIS_14");
			joy.threshold = 0.2;
			
			_gamepad.registerButton(GamePadMap.L1,"BUTTON_102");
			_gamepad.registerButton(GamePadMap.R1, "BUTTON_103");
			
			_gamepad.registerButton(GamePadMap.L2, "BUTTON_104");
			_gamepad.registerButton(GamePadMap.R2, "BUTTON_105");
			
			_gamepad.registerButton(GamePadMap.START, "BUTTON_108");
			
			_gamepad.registerButton(GamePadMap.L3, "BUTTON_106");
			_gamepad.registerButton(GamePadMap.R3, "BUTTON_107");
			
			_gamepad.registerButton(GamePadMap.DPAD_UP,"AXIS_36","up");
			_gamepad.registerButton(GamePadMap.DPAD_DOWN,"AXIS_38","down");
			_gamepad.registerButton(GamePadMap.DPAD_RIGHT,"AXIS_37","right");
			_gamepad.registerButton(GamePadMap.DPAD_LEFT,"AXIS_39","left");
			
			_gamepad.registerButton(GamePadMap.BUTTON_BOTTOM, "BUTTON_96"); // X
			_gamepad.registerButton(GamePadMap.BUTTON_LEFT, "BUTTON_99"); //   square
			_gamepad.registerButton(GamePadMap.BUTTON_TOP, "BUTTON_100"); //   triangle
			_gamepad.registerButton(GamePadMap.BUTTON_RIGHT, "BUTTON_97"); //  circle
		}
		
		override public function setupWIN():void
		{
			setupAND();
		}
		
		override public function setupLNX():void
		{
			setupAND();
		}
		
	}

}