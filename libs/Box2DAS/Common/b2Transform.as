package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2Transform extends b2Base {
		
		public function b2Transform(p:int) {
			_ptr = p;
			position = new b2Vec2(_ptr + 0);
			R = new b2Mat22(_ptr + 8);
		}
		
		public function get xf():XF {
			return new XF(position.v2, R.m22);
		}
		
		public function set xf(v:XF):void {
			position.v2 = v.p;
			R.m22 = v.r;
		}
		
		public var position:b2Vec2; // position = new b2Vec2(_ptr + 0);
		public var R:b2Mat22; // R = new b2Mat22(_ptr + 8);
	
	}
}