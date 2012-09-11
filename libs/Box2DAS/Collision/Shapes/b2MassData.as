package Box2DAS.Collision.Shapes {

	import Box2DAS.Common.b2Base;
	import Box2DAS.Common.b2Vec2;
	
	public class b2MassData extends b2Base {
		
		public function b2MassData(p:int = 0) {
			_ptr = p ? p : lib.b2MassData_new();
			center = new b2Vec2(_ptr + 4);
		}
		
		public function get mass():Number { return mem._mrf(_ptr + 0); }
		public function set mass(v:Number):void { mem._mwf(_ptr + 0, v); }
		public var center:b2Vec2; // center = new b2Vec2(_ptr + 4);
		public function get I():Number { return mem._mrf(_ptr + 12); }
		public function set I(v:Number):void { mem._mwf(_ptr + 12, v); }
	
	}
}