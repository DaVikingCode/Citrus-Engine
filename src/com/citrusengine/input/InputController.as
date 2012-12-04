package com.citrusengine.input {

	import com.citrusengine.core.CitrusEngine;
	
	public class InputController
	{
		public static var hideParamWarnings:Boolean = false;
		
		public var enabled:Boolean = true;
		public var name:String;
		
		protected var defaultChannel:uint = 0;
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
		
		public function update():void
		{
		
		}
		
		protected function triggerON(name:String, value:Number = 0, channel:int = -1):void
		{
			if (enabled)
				_input.actionTriggeredON.dispatch(new InputAction(name, this, (channel < 0)? defaultChannel : channel , value));
		}
		
		protected function triggerOFF(name:String, value:Number = 0, channel:int = -1):void
		{
			if (enabled)
				_input.actionTriggeredOFF.dispatch(new InputAction(name, this, (channel < 0)? defaultChannel : channel , value));
		}
		
		protected function triggerVALUECHANGE(name:String, value:Number = 0, channel:int = -1):void
		{
			if (enabled)
				_input.actionTriggeredVALUECHANGE.dispatch(new InputAction(name, this, (channel < 0)? defaultChannel : channel , value));
		}
		
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