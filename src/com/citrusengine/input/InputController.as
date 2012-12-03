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
		
		protected function triggerON(message:Object):void
		{
			if (enabled)
			{
				if (!message.value)
					message.value = 0;
				if (!message.channel)
					message.channel = defaultChannel;
				
				message.controller = this;
				
				_input.actionTriggeredON.dispatch(message);
			}
		}
		
		protected function triggerOFF(message:Object):void
		{
			if (enabled)
			{
				if (!message.value)
					message.value = 0;
				if (!message.channel)
					message.channel = defaultChannel;
				
				message.controller = this;
				
				_input.actionTriggeredOFF.dispatch(message);
			}
		}
		
		protected function triggerVALUECHANGE(message:Object):void
		{
			if (enabled)
			{
				if (!message.value)
					message.value = 0;
				if (!message.channel)
					message.channel = defaultChannel;
				
				message.controller = this;
				
				_input.actionTriggeredVALUECHANGE.dispatch(message);
			}
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