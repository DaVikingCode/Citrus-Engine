package citrus.input.controllers.gamepad.maps 
{
	import citrus.input.controllers.gamepad.Gamepad;
	import flash.system.Capabilities;
	
	public class GamePadMap
	{
		protected static var _platform:String;
		protected var _gamepad:Gamepad;
		
		public function GamePadMap():void
		{
			if(!_platform)
			_platform = Capabilities.version.slice(0, 3);
		}
		
		public function setup(gamepad:Gamepad):void
		{
			_gamepad = gamepad;
			_gamepad.stopAllActions();
			
			switch(_platform)
			{
				case "WIN" :
					setupWIN();
					break;
				case "MAC" :
					setupMAC();
					break;
				case "LNX" :
					setupLNX();
					break;
				case "AND" :
					setupAND();
					break;
			}
		}
		
		/**
		 * force GamePadMap to use a certain platform when running : WIN,MAC,LNX,AND
		 */
		public static function set devPlatform(value:String):void { _platform = value; }
		
		/**
		 * override those functions to set up a gamepad for different OS's by default,
		 * or override setup() to define your own way.
		 */
		public function setupWIN():void {}
		public function setupMAC():void {}
		public function setupLNX():void {}
		public function setupAND():void {}
		
		public static const L1:String = "L1";
		public static const R1:String = "R1";
		
		public static const L2:String = "L2";
		public static const R2:String = "R2";
		
		public static const STICK_LEFT:String = "STICK_LEFT";
		public static const STICK_RIGHT:String = "STICK_RIGHT";
		/**
		 * Joystick buttons.
		 */
		public static const L3:String = "L3";
		public static const R3:String = "R3";
		
		public static const SELECT:String = "SELECT";
		public static const START:String = "START";
		
		public static const HOME:String = "HOME";
		
		/**
		 * directional button on the left of the game pad.
		 */
		public static const DPAD_UP:String = "DPAD_UP";
		public static const DPAD_RIGHT:String = "DPAD_RIGHT";
		public static const DPAD_DOWN:String = "DPAD_DOWN";
		public static const DPAD_LEFT:String = "DPAD_LEFT";
		
		/**
		 * buttons on the right, conventionally 4 arranged as a rhombus ,
		 * example, playstation controllers , with in the same order as below : triangle, square, cross, circle
		 */
		public static const BUTTON_TOP:String = "BUTTON_TOP";
		public static const BUTTON_RIGHT:String = "BUTTON_RIGHT";
		public static const BUTTON_BOTTOM:String = "BUTTON_BOTTOM";
		public static const BUTTON_LEFT:String = "BUTTON_LEFT";
	}

}