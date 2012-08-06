package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2Sweep extends b2Base {
		
		public function b2Sweep(p:int) {
			_ptr = p;
			localCenter = new b2Vec2(_ptr + 0);
			c0 = new b2Vec2(_ptr + 8);
			c = new b2Vec2(_ptr + 16);
		}
		
		public var localCenter:b2Vec2; // localCenter = new b2Vec2(_ptr + 0);
		public var c0:b2Vec2; // c0 = new b2Vec2(_ptr + 8);
		public var c:b2Vec2; // c = new b2Vec2(_ptr + 16);
		public function get a0():Number { return mem._mrf(_ptr + 24); }
		public function set a0(v:Number):void { mem._mwf(_ptr + 24, v); }
		public function get a():Number { return mem._mrf(_ptr + 28); }
		public function set a(v:Number):void { mem._mwf(_ptr + 28, v); }
		//public function get t0():Number { return mem._mrf(_ptr + 32); }
		//public function set t0(v:Number):void { mem._mwf(_ptr + 32, v); }
		public function get alpha0():Number { return mem._mrf(_ptr + 32); }
		public function set alpha0(v:Number):void { mem._mwf(_ptr + 32, v); }
	
	}
}