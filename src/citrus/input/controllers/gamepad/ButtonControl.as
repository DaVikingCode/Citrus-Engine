package citrus.input.controllers.gamepad 
{
	public class ButtonControl 
	{
		protected var _name:String;
		protected var _controlID:String;
		protected var _action:String;
		
		public function ButtonControl(name:String,controlID:String,action:String) 
		{
			_name = name;
			_controlID = controlID;
			_action = action;
		}
		
		public function get name():String
		{
			return _name;
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