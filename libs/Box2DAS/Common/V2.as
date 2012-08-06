package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.geom.*;
	
	public class V2 {
		
		public var x:Number;
		public var y:Number;
		
		public function toString():String {
			return '<'+ x +', '+ y +'>';
		}
		
		public function V2(_x:Number = 0, _y:Number = 0) {
			x = _x; y = _y;
		}
		
		public static function fromP(p:Point):V2 {
			return new V2(p.x, p.y);
		}
		
		public function toP():Point {
			return new Point(x, y);
		}
		
		public function clone():V2 {
			return new V2(x, y);
		}
		
		public function copy(v:V2):V2 {
			x = v.x; y = v.y;
			return this;
		}
		
		public function equals(b:V2):Boolean {
			return x == b.x && y == b.y;
		}
		
		public function zero():V2 {
			x = 0; y = 0;
			return this;
		}
		
		public function isZero():Boolean {
			return x == 0 && y == 0;
		}
		
		public function xy(_x:Number, _y:Number):V2 {
			x = _x; y = _y;
			return this;
		}
		
		public function add(b:V2):V2 {
			x += b.x; y += b.y;
			return this;
		}
		
		public static function add(a:V2, b:V2):V2 {
			return new V2(a.x + b.x, a.y + b.y);
		}
		
		public function subtract(b:V2):V2 {
			x -= b.x; y -= b.y;
			return this;
		}
		
		public static function subtract(a:V2, b:V2):V2 {
			return new V2(a.x - b.x, a.y - b.y);	
		}
		
		public function addN(v:Number):V2 {
			x += v; y += v;
			return this;
		}
		
		public static function addN(a:V2, v:Number):V2 {
			return new V2(a.x + v, a.y + v);
		}
		
		public function subtractN(v:Number):V2 {
			x -= v; y -= v;
			return this;
		}
		
		public static function subtractN(a:V2, v:Number):V2 {
			return new V2(a.x - v, a.y - v);
		}
		
		public function multiply(b:V2):V2 {
			x *= b.x; y *= b.y;
			return this;
		}
		
		public static function multiply(a:V2, b:V2):V2 {
			return new V2(a.x * b.x, a.y * b.y);
		}
		
		public function multiplyN(n:Number):V2 {
			x *= n; y *= n;
			return this;
		}
		
		public static function multiplyN(a:V2, n:Number):V2 {
			return new V2(a.x * n, a.y * n);
		}
		
		public function divide(b:V2):V2 {
			x /= b.x; y /= b.y;
			return this;
		}
		
		public static function divide(a:V2, b:V2):V2 {
			return new V2(a.x / b.x, a.y / b.y);
		}
		
		public function divideN(n:Number):V2 {
			x /= n; y /= n;
			return this;
		}
		
		public static function divideN(a:V2, n:Number):V2 {
			return new V2(a.x / n, a.y / n);
		}
		
		public function length():Number {
			return Math.sqrt(x * x + y * y);
		}
		
		public function lengthSquared():Number {
			return x * x + y * y;
		}
		
		public function distance(b:V2):Number {
			return V2.subtract(this, b).length();
		}
		
		public function distanceSquared(b:V2):Number {
			return V2.subtract(this, b).lengthSquared();
		}
		
		public function normalize(l:Number = 1):V2 {
			var len:Number = length();
			x *= l / len; y *= l / len;
			return this;
		}
		
		public static function normalize(a:V2, l:Number = 1):V2 {
			var b:V2 = a.clone();
			b.normalize(l);
			return b;
		}
		
		public function dot(b:V2):Number {
			return x * b.x + y * b.y;
		}
		
		public function perpDot(b:V2):Number {
			return -y * b.x + x * b.y;
		}
		
		public function winding(b:V2, c:V2):Number {
			return V2.subtract(b, this).perpDot(V2.subtract(c, b)); // < 0 = right > 0 = left
		}
		
		public function cross(b:V2):Number {
			return x * b.y - y * b.x;
		}
		
		public static function crossVN(a:V2, n:Number):V2 {
			return new V2(n * a.y, -n * a.x);
		}
		
		public static function crossNV(n:Number, a:V2):V2 {
			return new V2(-n * a.y, n * a.x);
		}
		
		public function rotate(r:Number):V2 {
			var cos:Number = Math.cos(r);
			var sin:Number = Math.sin(r);
			xy(x * cos - y * sin, x * sin + y * cos);
			return this;
		}
		
		public static function rotate(v:V2, r:Number):V2 {
			return v.clone().rotate(r);
		}
		
		public function abs():V2 {
			x = Math.abs(x); y = Math.abs(y);
			return this;
		}
		
		public static function abs(v:V2):V2 {
			return v.clone().abs();
		}
		
		public function angle():Number {
			return Math.atan2(y, x);
		}
		
		public function sign():V2 {
			x = x > 0 ? 1 : x < 0 ? -1 : 0;
			y = y > 0 ? 1 : y < 0 ? -1 : 0;
			return this;
		}
		
		public static function sign(v:V2):V2 {
			return v.clone().sign();
		}
		
		public function flip():V2 {
			return xy(y, x);
		}
		
		public static function flip(v:V2):V2 {
			return new V2(v.y, v.x);
		}
		
		public function cw90():V2 {
			return xy(y, -x);
		}
		
		public function ccw90():V2 {
			return xy(-y, x);
		}
		
		public static function cw90(v:V2):V2 {
			return new V2(v.y, -v.x);
		}
		
		public static function ccw90(v:V2):V2 {
			return new V2(-v.y, v.x);
		}
		
		public function min(b:V2):V2 {
			x = Math.min(x, b.x);
			y = Math.min(y, b.y);
			return this;
		}
		
		public function max(b:V2):V2{
			x = Math.max(x, b.x);
			y = Math.max(y, b.y);
			return this;
		}
		
		public static function min(a:V2, b:V2):V2 {
			return a.clone().min(b);
		}
		
		public static function max(a:V2, b:V2):V2 {
			return a.clone().max(b);
		}
		
		public function invert():V2 {
			return multiplyN(-1);
		}
		
		public static function invert(v:V2):V2 {
			return new V2(-v.x, -v.y);
		}
	}
}