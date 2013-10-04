package citrus.input
{
	/**
	 * InputAction reinforces the Action object structure (and typing.)
	 * it contains static action phase constants as well as helpful comparators.
	 */
	public class InputAction
	{
		//read only action keys
		private var _name:String;
		private var _controller:InputController;
		private var _channel:uint;
		private var _time:uint = 0;
		
		//variable properties
		public var value:Number;
		public var phase:uint;
		
		public function InputAction(name:String, controller:InputController, channel:uint = 0, value:Number = 0, phase:uint = 0, time:uint = 0)
		{
			_name = name;
			_controller = controller;
			_channel = channel;
			
			this.value = value;
			this.phase = phase;
			this._time = time;
		}
		
		/**
		 * Clones the action and returns a new InputAction instance with the same properties.
		 */
		public function clone():InputAction
		{
			return new InputAction(_name, _controller,_channel, value, phase);
		}
		
		/**
		 * comp is used to compare an action with another action without caring about which controller
		 * the actions came from. it is the most common form of action comparison.
		 */
		public function comp(action:InputAction):Boolean
		{
			return _name == action.name && _channel == action.channel;
		}
		
		/**
		 * eq is almost a strict action comparator. It will not only compare names and channels
		 * but also which controller the actions came from.
		 */
		public function eq(action:InputAction):Boolean
		{
			return _name == action.name && _controller == action.controller && _channel == action.channel;
		}
		
		public function toString():String
		{
			return "[ Action # name: " + _name + " channel: " + _channel + " value: " + value + " phase: " + phase + " controller: " + _controller + " time: " + _time + " ]";
		}
		
		public function get name():String { return _name; }
		/**
		 * InputController that triggered this action
		 */
		public function get controller():InputController { return _controller; }
		/**
		 * action channel id.
		 */
		public function get channel():uint { return _channel; }
		/**
		 * time (in frames) the action has been 'running' in the Input system.
		 */
		public function get time():uint { return _time; }
		
		/**
		 * internal utiliy to keep public time read only 
		 */
		internal function get itime():uint { return _time; }
		internal function set itime(val:uint):void { _time = val; }
	
	}

}