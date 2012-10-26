package com.citrusengine.math
{
	public class MathVector
	{
		public var x:Number;
		public var y:Number;
		
		public function MathVector(x:Number=0, y:Number=0)
		{
			this.x = x;
			this.y = y;
		}
		
		public function copy():MathVector
		{
			return new MathVector(x, y);
		}
		
		public function get angle():Number
		{
			return Math.atan2(y, x);
		}
		
		public function set angle(value:Number):void
		{
			x = length * Math.cos(value);
			y = length * Math.sin(value);
		}
		
		public function rotate(angle:Number):void
		{
			var ca:Number = Math.cos(angle);
			var sa:Number = Math.sin(angle);
			
			x = x * ca - y * sa;
			y = x * sa + y * ca;
		}
		
		public function scaleEquals(value:Number):void
		{
			x *= value; y *= value;
		}
		
		public function scale(value:Number):MathVector
		{
			return new MathVector(x * value, y * value);
		}
		
		public function get normal():MathVector
		{
			return new MathVector(-y, x);
		}
		
		public function set length(value:Number):void
		{
			this.scaleEquals(value / length);
		}
		
		public function plusEquals(vector:MathVector):void
		{
			x += vector.x;
			y += vector.y;
		}
		
		public function plus(vector:MathVector):MathVector
		{
			return new MathVector(x + vector.x, y + vector.y);
		}
		
		public function minusEquals(vector:MathVector):void
		{
			x -= vector.x;
			y -= vector.y;
		}
		
		public function minus(vector:MathVector):MathVector
		{
			return new MathVector(x - vector.x, y - vector.y);
		}
		
		public function get length():Number
		{
			return Math.sqrt((x*x) + (y*y));
		}
		
		public function toString():String
		{
			return "[" + x + ", " + y + "]";
		}
	}
}