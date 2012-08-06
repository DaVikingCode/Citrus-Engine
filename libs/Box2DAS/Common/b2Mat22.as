package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2Mat22 extends b2Base {
	
		public function b2Mat22(p:int) {
			_ptr = p;
			col1 = new b2Vec2(_ptr + 0);
			col2 = new b2Vec2(_ptr + 8);
		}
		
		public function get m22():M22 {
			return new M22(col1.v2, col2.v2);
		}
		
		public function set m22(v:M22):void {
			col1.v2 = v.c1;
			col2.v2 = v.c2;
		}
		
		public var col1:b2Vec2; // col1 = new b2Vec2(_ptr + 0);
		public var col2:b2Vec2; // col2 = new b2Vec2(_ptr + 8);
	
	}
}