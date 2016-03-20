package citrus.input.controllers.gamepad.controls 
{
	import citrus.input.controllers.gamepad.Gamepad;
	import citrus.input.InputController;
	
	
	public class ButtonController extends InputController implements Icontrol
	{
		protected var _gamePad:Gamepad;
		protected var _controlID:String;
		protected var _prevValue:Number = 0;
		protected var _value:Number = 0;
		protected var _action:String;
		
		protected var _active:Boolean = false;
		
		public var threshold:Number = 0.1;
		public var inverted:Boolean = false;
		public var precision:Number = 100;
		public var digital:Boolean = false;
		
		/**
		 * ButtonController is an abstraction of the button controls of a gamepad. This InputController will see its value updated
		 * via its corresponding gamepad object and send his own actions to the Input system.
		 * 
		 * It should not be instantiated manually.
		 */
		public function ButtonController(name:String,parentGamePad:Gamepad,controlID:String,action:String = null) 
		{
			super(name);
			_gamePad = parentGamePad;
			_controlID = controlID;
			_action = action;
		}
		
		public function updateControl(control:String, value:Number):void
		{
			if (_action || _gamePad.triggerActivity)
			{
				value = value * (inverted ? -1 : 1);
				_prevValue = _value;
				value = ((value * precision) >> 0) / precision;
				_value = ( value <= threshold && value >= -threshold ) ? 0 : value ;
				_value = digital ? _value >> 0 : _value;
			}
			
			if (_action)
			{
				if (_prevValue != _value)
				{
					if (_value > 0)
						triggerCHANGE(_action, _value,null,_gamePad.defaultChannel);
					else
						triggerOFF(_action, 0, null, _gamePad.defaultChannel);
				}
			}
			
			if(_gamePad.triggerActivity)
				active = _value > 0;
		}
		
		protected function set active(val:Boolean):void
		{
			if (val == _active)
				return;
			
			if (val)
				triggerCHANGE(name, _value, null, Gamepad.activityChannel);
			else
				triggerOFF(name, 0, null, Gamepad.activityChannel);
			
			_active = val;
		}
		
		public function hasControl(id:String):Boolean
		{
			return _controlID == id;
		}
		
		override public function destroy():void
		{
			_gamePad = null;
			super.destroy();
		}
		
		public function get value():Number
		{
			return _value;
		}
		
		public function get gamePad():Gamepad
		{
			return _gamePad;
		}
		
		public function get controlID():String
		{
			return _controlID;
		}
		
		public function get action():String
		{
			return _action;
		}
		
		public function set action(value:String):void
		{
			_action = value;
		}
		
	}

}