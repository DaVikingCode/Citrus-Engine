package citrus.math
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
		
		public function copyFrom(vector:MathVector):void
		{
			this.x = vector.x;
			this.y = vector.y;
		}
		
		public function setTo(x:Number = 0, y:Number = 0):void
		{
			this.x = x;
			this.y = y;
		}
		
		public function rotate(angle:Number):void
		{
			var a:Number = angle;
			var ca:Number = Math.cos(a);
			var sa:Number = Math.sin(a);
			var tx:Number = x;
			var ty:Number = y;
			
			x = tx * ca - ty * sa;
			y = tx * sa + ty * ca;
		}
		
		public function scaleEquals(value:Number):void
		{
			x *= value; y *= value;
		}
		
		public function scale(value:Number, result:MathVector = null):MathVector
		{
			if (result) {
				result.x = x * value;
				result.y = y * value;
				
				return result;
			}
			
			return new MathVector(x * value, y * value);
		}
		
		public function normalize():void 
		{			
			var l:Number = length;
			x /= l;
			y /= l;
		}
		
		public function plusEquals(vector:MathVector):void
		{
			x += vector.x;
			y += vector.y;
		}
		
		public function plus(vector:MathVector, result:MathVector = null):MathVector
		{
			if (result) {
				result.x = x + vector.x;
				result.y = y + vector.y;
				
				return result;
			}
			
			return new MathVector(x + vector.x, y + vector.y);
		}
		
		public function minusEquals(vector:MathVector):void
		{
			x -= vector.x;
			y -= vector.y;
		}
		
		public function minus(vector:MathVector, result:MathVector = null):MathVector
		{
			if (result) {
				result.x = x - vector.x;
				result.y = y - vector.y;
				
				return result;
			}
			
			return new MathVector(x - vector.x, y - vector.y);
		}
		
		public function dot(vector:MathVector):Number
		{
			return (x * vector.x) + (y * vector.y);
		}
		
		public function get angle():Number
		{
			return Math.atan2(y, x);
		}
		
		public function set angle(value:Number):void
		{
			var l:Number = length;
			var tx:Number = l * Math.cos(value);
			var ty:Number = l * Math.sin(value);
			x = tx;
			y = ty;
		}
		
		public function get length():Number
		{
			return Math.sqrt((x*x) + (y*y));
		}
		
		public function set length(value:Number):void
		{
			this.scaleEquals(value / length);
		}
		
		public function get normal():MathVector
		{
			return new MathVector(-y, x);
		}
		
		public function toString():String
		{
			return "[" + x + ", " + y + "]";
		}
	}
}
