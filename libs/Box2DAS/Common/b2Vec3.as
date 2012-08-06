package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2Vec3 extends b2Base {
	
		public function b2Vec3(p:int) {
			_ptr = p;
		}
		
		public function get v3():V3 {
			return new V3(x, y, z);
		}
		
		public function set v3(v:V3):void {
			x = v.x;
			y = v.y;
			z = v.z;
		}
		
		public function get x():Number { return mem._mrf(_ptr + 0); }
		public function set x(v:Number):void { mem._mwf(_ptr + 0, v); }
		public function get y():Number { return mem._mrf(_ptr + 4); }
		public function set y(v:Number):void { mem._mwf(_ptr + 4, v); }
		public function get z():Number { return mem._mrf(_ptr + 8); }
		public function set z(v:Number):void { mem._mwf(_ptr + 8, v); }
	
	}
}