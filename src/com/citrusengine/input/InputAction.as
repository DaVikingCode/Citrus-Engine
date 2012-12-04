package com.citrusengine.input
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
		
		//variable properties
		public var value:Number;
		public var phase:uint;
		
		/**
		 * Action started in this frame.
		 * will be advanced to BEGAN on next frame.
		 */
		public static const BEGIN:uint = 0;
		
		/**
		 * Action started in previous frame and hasn't changed value.
		 * will be advanced to ON on next frame.
		 */
		public static const BEGAN:uint = 1;
		
		/**
		 * The "stable" phase, action began, its value may have been changed by the VALUECHANGE trigger.
		 * an action with this phase can only be advanced by an OFF trigger, to phase END.
		 */
		public static const ON:uint = 2;
		
		/**
		 * Action has been triggered OFF in the current frame.
		 * will be advanced to ENDED on next frame.
		 */
		public static const END:uint = 3;
		
		/**
		 * Action has been triggered OFF in the previous frame, and will be disposed of in this frame.
		 */
		public static const ENDED:uint = 4;
		
		public function InputAction(name:String,controller:InputController,channel:uint,value:Number = 0,phase:uint = 0)
		{
			_name = name;
			_controller = controller;
			_channel = channel;
			
			this.value = value;
			this.phase = phase;
		}
		
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
			if (_name ==  action.name && _channel == action.channel)
				return true;
			else
				return false;
		}
		
		/**
		 * eq is almost a strict action comparator. It will not only compare names and channels
		 * but also which controller the actions came from.
		 */
		public function eq(action:InputAction):Boolean
		{
			if (_name ==  action.name && _controller == action.controller && _channel == action.channel)
				return true;
			else
				return false;
		}
		
		public function get name():String { return _name; }
		public function get controller():InputController { return _controller; }
		public function get channel():uint { return _channel; }
	
	}

}