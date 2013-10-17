package citrus.input.controllers.gamepad 
{
	import citrus.math.MathVector;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	
	/*
	 * Definition for a game input control with 2 axis (4 directions)
	 */
	public class AxisControl2
	{
		protected var _name:String;
		protected var _controls:Array;
		protected var _vec:MathVector;
		
		protected var _upAction:String;
		protected var _downAction:String;
		protected var _leftAction:String;
		protected var _rightAction:String;
		
		protected var _normalized:Boolean;
		
		/**
		 * @param	controls array of control ids, clockwise starting from top.
		 */
		public function AxisControl2(name:String,controls:Array,up:String,right:String,down:String,left:String, normalized:Boolean) 
		{
			_name = name;
			_upAction = up;
			_downAction = down;
			_leftAction = left;
			_rightAction = right;
			_normalized = normalized;
			_controls = controls;
			_vec = new MathVector();
		}
		
		public function updateAxis(axis:String, value:Number):void
		{
			var dir:int = _controls.indexOf(axis);
			var prevX:Number = _vec.x;
			var prevY:Number = _vec.y;
			switch(dir)
			{
				case 0: //up down
					_vec.y = value;
					break;
				case 1: //right left
					_vec.x = value;
					break;
			}
		}
		
		public function get y():Number
		{
			return _vec.y;
		}
		
		public function get x():Number
		{
			return _vec.x;
		}
		
		public function get up():Number
		{
			if(_normalized)
			return (_vec.y <= 0 ) ? -_vec.y : 0;
			else
			return _vec.y;
		}
		
		public function get down():Number
		{
			if(_normalized)
			return (_vec.y >= 0 ) ? _vec.y : 0;
			else
			return _vec.y;
		}
		
		public function get left():Number
		{
			if(_normalized)
			return (_vec.y <= 0 ) ? -_vec.x : 0;
			else
			return _vec.x;
		}
		
		public function get right():Number
		{
			if(_normalized)
			return (_vec.y >= 0 ) ? _vec.x : 0;
			else
			return _vec.x;
		}
		
		public function get length():Number
		{
			return _vec.length;
		}
		
		public function get angle():Number
		{
			return _vec.angle;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get upAction():String { return _upAction; };		
		public function set upAction(value:String):void { _upAction = value; };		
		public function get rightAction():String { return _rightAction; };	
		public function set rightAction(value:String):void { _rightAction = value; };
		public function get downAction():String { return _downAction; };	
		public function set downAction(value:String):void { _downAction = value; };
		public function get leftAction():String { return _leftAction; };		
		public function set leftAction(value:String):void { _leftAction = value; };	
		
		public function destroy():void
		{
			_controls = null;
			_vec = null;
		}
		
	}

}