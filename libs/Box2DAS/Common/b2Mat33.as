package Box2DAS.Common {
	
	
	public class b2Mat33 extends b2Base {
	
		public function b2Mat33(p:int) {
			_ptr = p;
			col1 = new b2Vec3(_ptr + 0);
			col2 = new b2Vec3(_ptr + 12);
			col3 = new b2Vec3(_ptr + 24)
		}
		
		public function get m33():M33 {
			return new M33(col1.v3, col2.v3, col3.v3);
		}
		
		public function set m33(v:M33):void {
			col1.v3 = v.c1;
			col2.v3 = v.c2;
			col3.v3 = v.c3;
		}
	
		public var col1:b2Vec3; // col1 = new b2Vec3(_ptr + 0);
		public var col2:b2Vec3; // col2 = new b2Vec3(_ptr + 12);
		public var col3:b2Vec3; // col3 = new b2Vec3(_ptr + 24);
	
	}
}