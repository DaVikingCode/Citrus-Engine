package Box2DAS.Dynamics.Joints {

	import Box2DAS.Common.b2Base;
	import Box2DAS.Common.b2Vec2;
	
	public class b2Jacobian extends b2Base {

		public function b2Jacobian(p:int) {
			_ptr = p;
			linear1 = new b2Vec2(_ptr + 0);
			linear2 = new b2Vec2(_ptr + 12);
		}

		public var linear1:b2Vec2;
		public function get angular1():Number { return mem._mrf(_ptr + 8); }
		public function set angular1(v:Number):void { mem._mwf(_ptr + 8, v); }
		public var linear2:b2Vec2;
		public function get angular2():Number { return mem._mrf(_ptr + 20); }
		public function set angular2(v:Number):void { mem._mwf(_ptr + 20, v); }
	}
		
}