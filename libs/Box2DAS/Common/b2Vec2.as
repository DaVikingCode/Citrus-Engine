package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2Vec2 extends b2Base {
		
		public function b2Vec2(p:int) {
			_ptr = p;
		}
		
		public function get v2():V2 {
			return new V2(x, y);
		}
		
		public function set v2(v:V2):void {
			x = v.x;
			y = v.y;
		}
	
		public function get x():Number { return mem._mrf(_ptr + 0); }
		public function set x(v:Number):void { mem._mwf(_ptr + 0, v); }
		public function get y():Number { return mem._mrf(_ptr + 4); }
		public function set y(v:Number):void { mem._mwf(_ptr + 4, v); }
	
	}
}