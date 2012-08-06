package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class M33 {

		public var c1:V3 = new V3();
		public var c2:V3 = new V3();
		public var c3:V3 = new V3();
		
		public function M33(_c1:V3 = null, _c2:V3 = null, _c3:V3 = null) {
			if(c1 && c2 && c3) columns(c1, c2, c3);
		}
		
		public function columns(_c1:V3, _c2:V3, _c3:V3):void {
			c1.xyz(_c1.x, _c1.y, _c1.z); 
			c2.xyz(_c2.x, _c2.y, _c2.z);
			c3.xyz(_c3.x, _c3.y, _c3.z);
		}
		
		public function values(x1:Number, y1:Number, z1:Number, x2:Number, y2:Number, z2:Number, x3:Number, y3:Number, z3:Number):void {
			c1.xyz(x1, y1, z1);
			c2.xyz(x2, y2, z2);
			c3.xyz(x3, y3, z3);
		}
		
		public static function values(x1:Number, y1:Number, z1:Number, x2:Number, y2:Number, z2:Number, x3:Number, y3:Number, z3:Number):M33 {
			var m:M33 = new M33();
			m.values(x1, y1, z1, x2, y2, z2, x3, y3, z3);
			return m;
		}
		
		public function clone():M33 {
			return new M33(c1, c2, c3);
		}
		
		public function zero():void {
			c1.zero();
			c2.zero();
			c3.zero();
		}
		
		public function multiplyV(v:V3):V3 {
			return c1.multiplyN(v.x) + c2.multiplyN(v.y) + c3.multiplyN(v.z);
		}
	}
}