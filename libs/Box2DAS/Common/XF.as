package Box2DAS.Common {
	
	
	public class XF {
		
		public var p:V2 = new V2();
		public var r:M22 = new M22();
		
		public function XF(_p:V2 = null, _r:M22 = null) {
			if(_p && _r) posRot(_p, _r);
		}
		
		public function posRot(_p:V2, _r:M22):void {
			p.xy(_p.x, _p.y);
			r.columns(_r.c1, _r.c2);
		}
		
		public function get angle():Number {
			return r.angle;
		}
		
		public function set angle(v:Number):void {
			r.angle = v;
		}
		
		public function multiply(v:V2):V2 {
			var v2:V2 = r.multiplyV(v);
			v2.add(p);
			return v2;
		}
		
		public function multiplyT(v:V2):V2 {
			return r.multiplyVT(V2.subtract(v, p));
		}
	}
}