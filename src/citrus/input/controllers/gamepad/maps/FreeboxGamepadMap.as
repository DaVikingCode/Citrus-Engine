package citrus.input.controllers.gamepad.maps 
{
	import citrus.input.controllers.gamepad.Gamepad;
	/**
	 * This is the Freebox _gamepad controller preset
	 * It will work only in analog mode though (axes are weird when its not)
	 * http://www.lowcostmobile.com/img/operateurs/free/_gamepad_free.jpg
	 */
	public class FreeboxGamepadMap extends GamePadMap
	{
		public function FreeboxGamepadMap():void
		{
			
		}
		
		override public function setupWIN():void
		{
			_gamepad.registerStick(GamePadMap.STICK_LEFT,"AXIS_1", "AXIS_0");
			_gamepad.registerStick(GamePadMap.STICK_RIGHT,"AXIS_4", "AXIS_2");
			
			_gamepad.registerButton(GamePadMap.L1,"BUTTON_13");
			_gamepad.registerButton(GamePadMap.R1, "BUTTON_14");
			
			_gamepad.registerButton(GamePadMap.L2, "BUTTON_15");
			_gamepad.registerButton(GamePadMap.R2, "BUTTON_16");
			
			_gamepad.registerButton(GamePadMap.L3, "BUTTON_19");
			_gamepad.registerButton(GamePadMap.R3, "BUTTON_20");
			
			_gamepad.registerButton(GamePadMap.SELECT, "BUTTON_17");
			_gamepad.registerButton(GamePadMap.START, "BUTTON_18");
			
			_gamepad.registerButton(GamePadMap.DPAD_UP,"BUTTON_5","up");
			_gamepad.registerButton(GamePadMap.DPAD_DOWN,"BUTTON_6","down");
			_gamepad.registerButton(GamePadMap.DPAD_RIGHT,"BUTTON_8","right");
			_gamepad.registerButton(GamePadMap.DPAD_LEFT,"BUTTON_7","left");
			
			_gamepad.registerButton(GamePadMap.BUTTON_TOP, "BUTTON_9");
			_gamepad.registerButton(GamePadMap.BUTTON_RIGHT, "BUTTON_10");
			_gamepad.registerButton(GamePadMap.BUTTON_BOTTOM, "BUTTON_11");
			_gamepad.registerButton(GamePadMap.BUTTON_LEFT, "BUTTON_12");
		}
		
	}

}