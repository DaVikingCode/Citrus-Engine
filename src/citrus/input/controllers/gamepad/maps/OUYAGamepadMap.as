package citrus.input.controllers.gamepad.maps 
{
	import citrus.input.controllers.gamepad.controls.StickController;
	import citrus.input.controllers.gamepad.Gamepad;
	public class OUYAGamepadMap extends GamePadMap
	{
		
		public function OUYAGamepadMap() 
		{
			
		}
		
		override public function setupAND():void
		{
			 var joy:StickController;
			
			joy = _gamepad.registerStick(GamePadMap.STICK_LEFT,"AXIS_0", "AXIS_1");
			joy.threshold = 0.2;
			
			joy = _gamepad.registerStick(GamePadMap.STICK_RIGHT,"AXIS_11", "AXIS_14");
			joy.threshold = 0.2;
			
			_gamepad.registerButton(GamePadMap.L1,"BUTTON_102");
			_gamepad.registerButton(GamePadMap.R1, "BUTTON_103");
			
			_gamepad.registerButton(GamePadMap.L2, "AXIS_17");
			_gamepad.registerButton(GamePadMap.R2, "AXIS_18");
			
			_gamepad.registerButton(GamePadMap.L3, "BUTTON_106");
			_gamepad.registerButton(GamePadMap.R3, "BUTTON_107");
			
			_gamepad.registerButton(GamePadMap.DPAD_UP,"BUTTON_19","up");
			_gamepad.registerButton(GamePadMap.DPAD_DOWN,"BUTTON_20","down");
			_gamepad.registerButton(GamePadMap.DPAD_RIGHT,"BUTTON_22","right");
			_gamepad.registerButton(GamePadMap.DPAD_LEFT,"BUTTON_21","left");
			
			_gamepad.registerButton(GamePadMap.BUTTON_BOTTOM, "BUTTON_96"); // O
			_gamepad.registerButton(GamePadMap.BUTTON_LEFT, "BUTTON_99"); //   U
			_gamepad.registerButton(GamePadMap.BUTTON_TOP, "BUTTON_100"); //   Y
			_gamepad.registerButton(GamePadMap.BUTTON_RIGHT, "BUTTON_97"); //  A
		}
		
		override public function setupLNX():void
		{
			setupAND();
		}
		
		override public function setupWIN():void
		{
			setupAND();
		}
		
		override public function setupMAC():void
		{
			setupAND();
		}
		
	}

}