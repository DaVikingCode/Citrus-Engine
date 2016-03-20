package citrus.input.controllers {

	import citrus.input.InputController;
	import citrus.math.MathVector;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class AVirtualJoystick extends InputController
	{
		//Common graphic properties
		protected var _x:int;
		protected var _y:int;
		
		protected var _realTouchPosition:Point = new Point();
		protected var _targetPosition:MathVector = new MathVector();
		
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
		
		/**
		 * wether to restrict the knob's movement in a circle or in a square
		 * hint: square allows for extreme values on both axis when dragged in a corner.
		 */
		public var circularBounds:Boolean = true;
		
		/**
		 * alpha to use when the joystick is not active
		 */
		public var inactiveAlpha:Number = 0.3;
		
		/**
		 * alpha to use when the joystick is active (being dragged)
		 */
		public var activeAlpha:Number = 1;
		
		/**
		 * distance from the center at which no action will be fired.
		 */
		public var threshold:Number = 0.1;
		
		public function AVirtualJoystick(name:String, params:Object = null)
		{
			super(name, params);
		}
		
		/**
		 * Override this for specific drawing
		 */
		protected function initGraphics():void
		{
			trace("Warning: " + this + " does not render any graphics!");
		}
		
		/**
		 * Set action ranges.
		 */
		protected function initActionRanges():void
		{
			_xAxisActions = new Vector.<Object>();
			_yAxisActions = new Vector.<Object>();
			
			//register default actions to value intervals
			
			addAxisAction("x", "left", -1, -0.3);
			addAxisAction("x", "right", 0.3, 1);
			addAxisAction("y", "up", -1, -0.3);
			addAxisAction("y", "down", 0.3, 1);
			
			addAxisAction("y", "duck", 0.8, 1);
			addAxisAction("y", "jump", -1, -0.8);
		
		}
		
		public function removeAxisAction(axis:String, name:String):void
		{
			var actionlist:Vector.<Object>;
			if (axis.toLowerCase() == "x")
				actionlist = _xAxisActions;
			else if (axis.toLowerCase() == "y")
				actionlist = _yAxisActions;
			else
				throw(new Error("VirtualJoystick::removeAxisAction() invalid axis parameter (only x and y are accepted)"));
			
			var i:String;
			for (i in actionlist)
				if (actionlist[i].name == name)
					actionlist.splice(uint(i),1);
		}
		
		public function addAxisAction(axis:String, name:String, start:Number, end:Number):void
		{
			var actionlist:Vector.<Object>;
			if (axis.toLowerCase() == "x")
				actionlist = _xAxisActions;
			else if (axis.toLowerCase() == "y")
				actionlist = _yAxisActions;
			else
				throw(new Error("VirtualJoystick::addAxisAction() invalid axis parameter (only x and y are accepted)"));
			
			if ( (start < 0 && end > 0) || (start > 0 && end < 0) || start == end )
				throw(new Error("VirtualJoystick::addAxisAction() start and end values must have the same sign and not be equal"));
			
			if (!((start < -1 || start > 1) || (end < -1 || end > 1)))
				actionlist.push({name: name, start: start, end: end});
			else
				throw(new Error("VirtualJoystick::addAxisAction() start and end values must be between -1 and 1"));
		}
		
		/**
		 * Give handleGrab the relative position of touch or mouse to knob.
		 * It will handle knob movement restriction, action triggering and set _knobX and _knobY for knob positioning.
		 */
		protected function handleGrab(relativeX:int, relativeY:int):void
		{
			if (circularBounds)
			{
				var dist:Number = relativeX*relativeX + relativeY*relativeY ;
				if (dist <= _innerradius*_innerradius)
				{
					_targetPosition.setTo(relativeX, relativeY);
				}
				else
				{
					_targetPosition.setTo(relativeX, relativeY);
					_targetPosition.length = _innerradius;
				}
			}
			else
			{
				if (relativeX < _innerradius && relativeX > -_innerradius)
					_targetPosition.x = relativeX;
				else if (relativeX > _innerradius)
					_targetPosition.x = _innerradius;
				else if (relativeX < -_innerradius)
					_targetPosition.x = -_innerradius;
				
				if (relativeY < _innerradius && relativeY > -_innerradius)
					_targetPosition.y = relativeY;
				else if (relativeY > _innerradius)
					_targetPosition.y = _innerradius;
				else if (relativeY < -_innerradius)
					_targetPosition.y = -_innerradius;
			}
			
			//normalize x and y axes value.
			
			_xAxis = _targetPosition.x / _innerradius;
			_yAxis = _targetPosition.y / _innerradius;
			
			// Check registered actions on both axes
			if (Math.sqrt((_xAxis * _xAxis) + (_yAxis * _yAxis)) <= threshold)
				_input.stopActionsOf(this);
			else
			{
				var a:Object; //action 
				var ratio:Number;
				var val:Number;
				
				if (_xAxisActions.length > 0)
					for each (a in _xAxisActions)
					{
						ratio = 1 / (a.end - a.start);
						val = _xAxis <0 ? 1 - Math.abs((_xAxis - a.start)*ratio) : Math.abs((_xAxis - a.start) * ratio);
						if ((_xAxis >= a.start) && (_xAxis <= a.end))
							triggerCHANGE(a.name, val);
						else
							triggerOFF(a.name, 0);
					}
				
				if (_yAxisActions.length > 0)
					for each (a in _yAxisActions)
					{
						ratio = 1 / (a.start - a.end);
						val = _yAxis <0 ? Math.abs((_yAxis - a.end)*ratio) : 1 - Math.abs((_yAxis - a.end) * ratio);
						if ((_yAxis >= a.start) && (_yAxis <= a.end))
							triggerCHANGE(a.name, val);
						else
							triggerOFF(a.name, 0);
					}
				
			}
		}
		
		protected function reset():void
		{
			_targetPosition.setTo();
			_xAxis = 0;
			_yAxis = 0;
			_input.stopActionsOf(this);
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
			if (value == _x)
				return;
			
			_x = value;
			reset();
		}
		
		public function set y(value:int):void
		{
			if (value == _y)
				return;
			
			_y = value;
			reset();
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