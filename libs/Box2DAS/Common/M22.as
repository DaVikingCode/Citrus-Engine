package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class M22 {
		
		public var c1:V2 = new V2();
		public var c2:V2 = new V2();
		
		public function toString():String {
			return '<<'+ c1.x +', '+ c1.y +'>, <'+ c2.x +', '+ c2.y +'>>';
		}
		
		public function M22(_c1:V2 = null, _c2:V2 = null) {
			if(_c1 && _c2) columns(_c1, _c2);
		}
		
		public function columns(_c1:V2, _c2:V2):void {
			c1.xy(_c1.x, _c1.y); 
			c2.xy(_c2.x, _c2.y);
		}
		
		public function values(x1:Number, y1:Number, x2:Number, y2:Number):void {
			c1.xy(x1, y1);
			c2.xy(x2, y2);
		}
		
		public static function values(x1:Number, y1:Number, x2:Number, y2:Number):M22 {
			var m:M22 = new M22();
			m.values(x1, y1, x2, y2);
			return m;
		}
		
		public function clone():M22 {
			return new M22(c1, c2);
		}
	
		public function set angle(n:Number):void {
			c1.x = Math.cos(n);
			c1.y = Math.sin(n);
			c2.x = -c1.y;
			c2.y = c1.x;
		}
		
		public function get angle():Number {
			return Math.atan2(c1.y, c1.x);
		}
		
		public static function angle(n:Number):M22 {
			var m:M22 = new M22();
			m.angle = n;
			return m;
		}
		
		public function zero():void {
			c1.zero();
			c2.zero();
		}
		
		public function multiplyV(v:V2):V2 {
			return new V2(
				c1.x * v.x + c2.x * v.y, 
				c1.y * v.x + c2.y * v.y
			);
		}
		
		public function multiplyVT(v:V2):V2 {
			return new V2(v.dot(c1), v.dot(c2));
		}
		
		public function identity():M22 {
			c1.x = 1;
			c2.y = 1;
			return this;
		}
		
		public static function identity():M22 {
 			return (new M22()).identity();
		}
	}
}