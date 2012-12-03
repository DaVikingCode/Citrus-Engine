package com.citrusengine.input.controllers {

	import com.citrusengine.input.InputController;

	public class AVirtualJoystick extends InputController
	{
		//Common graphic properties
		protected var _x:int;
		protected var _y:int;
		
		protected var _knobX:int = 0;
		protected var _knobY:int = 0;
		
		protected var _visible:Boolean = true;
		
		//joystick features
		protected var _innerradius:int;
		protected var _knobradius:int = 50;
		protected var _radius:int = 130;
		
		//Axes values [-1;1]
		protected var _xAxis:Number = 0;
		protected var _yAxis:Number = 0;
		
		//Axes Actions
		protected var _xAxisActions:Vector.<Object>;
		protected var _yAxisActions:Vector.<Object>;
		
		protected var _grabbed:Boolean = false;
		protected var _centered:Boolean = true;
		
		public function AVirtualJoystick(name:String, params:Object = null)
		{
			super(name, params);
			
			_innerradius = _radius - _knobradius;
			
			initActionRanges();
			initGraphics();
		}
		
		/*
		 * Override this for specific drawing
		 */
		protected function initGraphics():void
		{
			trace("Warning: " + this + " does not render any graphics!");
		}
		
		/*
		 * Set action ranges.
		 */
		protected function initActionRanges():void
		{
			_xAxisActions = new Vector.<Object>();
			_yAxisActions = new Vector.<Object>();
			
			//register default actions to value intervals
			
			_xAxisActions.push({name: "left", start: -1, end: 0});
			_xAxisActions.push({name: "right", start: 0, end: 1});
			_yAxisActions.push({name: "up", start: -1, end: 0});
			_yAxisActions.push({name: "down", start: 0, end: 1});
			
			//other action
			
			_yAxisActions.push({name: "crouch", start: 0.8, end: 1});
		
		}
		
		public function addAxisAction(axis:String, name:String, start:Number, end:Number):void
		{
			var actionlist:Vector.<Object>;
			if (axis.toLowerCase() == "x")
				actionlist = _xAxisActions;
			else if (axis.toLowerCase() == "y")
				actionlist = _yAxisActions;
			else
			{
				throw(new Error("VirtualJoystick::addAxisAction() invalid axis parameter (only x and y are accepted)"));
				return;
			}
			
			if (!((start < -1 || start > 1) || (end < -1 || end > 1)))
				actionlist.push({name: name, start: start, end: end});
			else
				throw(new Error("VirtualJoystick::addAxisAction() start and end values must be between -1 and 1"));
		}
		
		/*
		 * Give handleGrab the relative position of touch or mouse to knob.
		 * It will handle knob movement restriction, action triggering and set _knobX and _knobY for knob positioning.
		 */
		protected function handleGrab(relativeX:int, relativeY:int):void
		{
			
			if (relativeX < _innerradius && relativeX > -_innerradius)
				_knobX = relativeX;
			else if (relativeX > _innerradius)
				_knobX = _innerradius;
			else if (relativeX < -_innerradius)
				_knobX = -_innerradius;
			
			if (relativeY < _innerradius && relativeY > -_innerradius)
				_knobY = relativeY;
			else if (relativeY > _innerradius)
				_knobY = _innerradius;
			else if (relativeY < -_innerradius)
				_knobY = -_innerradius;
			
			//normalize x and y axes value.
			
			_xAxis = _knobX / _innerradius;
			_yAxis = _knobY / _innerradius;
			
			// Check registered actions on both axes
			
			if ((_xAxis >= -0.01 && _xAxis <= 0.01) || (_yAxis >= -0.01 && _yAxis <= 0.01))
				//threshold of Axis values where no actions will be fired // actions will turned off.
				triggerAllOFF();
			else
			{
				var a:Object; //action 
				
				if (_xAxisActions.length > 0)
					for each (a in _xAxisActions)
					{
						
						if ((_xAxis >= a.start) && (_xAxis <= a.end))
							triggerVALUECHANGE({name: a.name, value: Math.abs(_xAxis)});
						else
							triggerOFF({name: a.name});
					}
				
				if (_yAxisActions.length > 0)
					for each (a in _yAxisActions)
					{
						if ((_yAxis >= a.start) && (_yAxis <= a.end))
							triggerVALUECHANGE({name: a.name, value: Math.abs(_yAxis)});
						else
							triggerOFF({name: a.name});
					}
				
			}
		}
		
		protected function triggerAllOFF():void
		{
			var a:Object;
			if (_xAxisActions.length > 0)
				for each (a in _xAxisActions)
					triggerOFF({name: a.name});
			if (_yAxisActions.length > 0)
				for each (a in _yAxisActions)
					triggerOFF({name: a.name});
		}
		
		protected function reset():void
		{
			_knobX = 0;
			_knobY = 0;
			_xAxis = 0;
			_yAxis = 0;
			triggerAllOFF();
		}
		
		public function set radius(value:int):void
		{
			if (!_initialized)
			{
				_radius = value;
				_innerradius = _radius - _knobradius;
			}
			else
				trace("Warning: You cannot set " + this + " radius after it has been created. Please set it in the constructor.");
		}
		
		public function set knobradius(value:int):void
		{
			if (!_initialized)
			{
				_knobradius = value;
				_innerradius = _radius - _knobradius;
			}
			else
				trace("Warning: You cannot set " + this + " knobradius after it has been created. Please set it in the constructor.");
		}
		
		public function set x(value:int):void
		{
			if (!_initialized)
				_x = value;
			else
				trace("Warning: you can only set " + this + " x through graphic.x after instanciation.")
		}
		
		public function set y(value:int):void
		{
			if (!_initialized)
				_y = value;
			else
				trace("Warning: you can only set " + this + " y through graphic.y after instanciation.")
		}
		
		public function get radius():int
		{
			return _radius;
		}
		
		public function get knobradius():int
		{
			return _knobradius;
		}
	
	}

}