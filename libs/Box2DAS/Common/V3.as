package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class V3 {
		
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function V3(_x:Number = 0, _y:Number = 0, _z:Number = 0) {
			x = _x; y = _y; z = _z;
		}
		
		public function clone():V3 {
			return new V3(x, y, z);
		}
		
		public function equals(b:V3):Boolean {
			return x == b.x && y == b.y && z == b.z;
		}
		
		public function zero():void {
			x = 0; y = 0; z = 0;
		}
		
		public function xyz(_x:Number, _y:Number, _z:Number):void {
			x = _x; y = _y; z = _z;
		}
		
		public function add(b:V3):void {
			x += b.x; y += b.y; z += b.z;
		}
		
		public static function add(a:V3, b:V3):V3 {
			return new V3(a.x + b.x, a.y + b.y, a.z + b.z);
		}
		
		public function subtract(b:V3):void {
			x -= b.x; y -= b.y; z -= b.z;
		}
		
		public static function subtract(a:V3, b:V3):V3 {
			return new V3(a.x - b.x, a.y - b.y, a.z - b.z);
		}
		
		public function multiply(b:V3):void {
			x *= b.x; y *= b.y; z *= b.z;
		}
		
		public static function multiply(a:V3, b:V3):V3 {
			return new V3(a.x * b.x, a.y * b.y, a.z * b.z);
		}
		
		public function multiplyN(n:Number):void {
			x *= n; y *= n; z *= n;
		}
		
		public static function multiplyN(a:V3, n:Number):V3 {
			return new V3(a.x * n, a.y * n, a.z * n);
		}
		
		public function divide(b:V3):void {
			x /= b.x; y /= b.y; z /= b.z;
		}
		
		public static function divide(a:V3, b:V3):V3 {
			return new V3(a.x / b.x, a.y / b.y, a.z / b.z);
		}
		
		public function divideN(n:Number):void {
			x /= n; y /= n; z /= n;
		}
		
		public static function divideN(a:V3, n:Number):V3 {
			return new V3(a.x / n, a.y / n, a.z / n);
		}
		
		public function length():Number {
			return Math.sqrt(x * x + y * y + z * z);
		}
		
		public function lengthSquared():Number {
			return x * x + y * y + z * z;
		}
		
		public function distance(b:V3):Number {
			return V3.subtract(this, b).length();
		}
		
		public function distanceSquared(b:V3):Number {
			return V3.subtract(this, b).lengthSquared();
		}
		
		public function normalize():void {
			var len:Number = length();
			x /= len; y /= len; z /= len;
		}
		
		public static function normalize(a:V3):V3 {
			var b:V3 = a.clone();
			b.normalize();
			return b;
		}
		
		public function dot(b:V3):Number {
			return x * b.x + y * b.y + z * b.z;
		}
	}
}