package citrus.input {

	import citrus.core.CitrusEngine;
	
	/**
	 * InputController is the parent of all the controllers classes. It provides the same helper that CitrusObject class : 
	 * it can be initialized with a params object, which can be created via an object parser/factory. 
	 */
	public class InputController
	{
		public static var hideParamWarnings:Boolean = false;
		
		public var enabled:Boolean = true;
		public var name:String;
		public var defaultChannel:uint = 0;
		
		protected var _ce:CitrusEngine;
		protected var _input:Input;
		protected var _initialized:Boolean;
		
		public function InputController(name:String, params:Object = null)
		{
			this.name = name;

			setParams(params);
			
			_ce = CitrusEngine.getInstance();
			_input = _ce.input;
			
			_ce.input.addController(this);
		}
		
		/**
		 * Override this function if you need your controller to update when CitrusEngine updates the Input instance.
		 */
		public function update():void
		{
		
		}
		
		/**
		 * Will register the action to Input as an action with an InputAction.BEGIN phase.
		 * @param	name string that defines the action such as "jump" or "fly"
		 * @param	value optional value for your action.
		 * @param	channel optional channel for your action. (will be set to the defaultChannel if not set.
		 */
		protected function triggerON(name:String, value:Number = 0, channel:int = -1):void
		{
			if (enabled)
				_input.actionTriggeredON.dispatch(new InputAction(name, this, (channel < 0)? defaultChannel : channel , value));
		}
		
		/**
		 * Will register the action to Input as an action with an InputAction.END phase.
		 * @param	name string that defines the action such as "jump" or "fly"
		 * @param	value optional value for your action.
		 * @param	channel optional channel for your action. (will be set to the defaultChannel if not set.
		 */
		protected function triggerOFF(name:String, value:Number = 0, channel:int = -1):void
		{
			if (enabled)
				_input.actionTriggeredOFF.dispatch(new InputAction(name, this, (channel < 0)? defaultChannel : channel , value));
		}
		
		/**
		 * Will register the action to Input as an action with an InputAction.ON phase.
		 * @param	name string that defines the action such as "jump" or "fly"
		 * @param	value optional value for your action.
		 * @param	channel optional channel for your action. (will be set to the defaultChannel if not set.
		 */
		protected function triggerVALUECHANGE(name:String, value:Number = 0, channel:int = -1):void
		{
			if (enabled)
				_input.actionTriggeredVALUECHANGE.dispatch(new InputAction(name, this, (channel < 0)? defaultChannel : channel , value));
		}
		
		/**
		 * Removes the controller from Input.
		 */
		public function destroy():void
		{
			_input.removeController(this);
		}
		
		protected function setParams(object:Object):void
		{
			for (var param:String in object)
			{
				try
				{
					if (object[param] == "true")
						this[param] = true;
					else if (object[param] == "false")
						this[param] = false;
					else
						this[param] = object[param];
				}
				catch (e:Error)
				{
					if (!hideParamWarnings)
						trace("Warning: The parameter " + param + " does not exist on " + this);
				}
			}
			
			_initialized = true;
			
		}
	
	}

}