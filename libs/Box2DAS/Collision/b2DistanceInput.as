package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2DistanceInput extends b2Base {
		
		public function b2DistanceInput() {
			_ptr = lib.b2DistanceInput_new();
			proxyA = new b2DistanceProxy(_ptr + 0);
			proxyB = new b2DistanceProxy(_ptr + 28);
			transformA = new b2Transform(_ptr + 56);
			transformB = new b2Transform(_ptr + 80);
		}
		
		public override function destroy():void {
			lib.b2DistanceInput_delete(_ptr);
			super.destroy();
		}
		
		public function init(f1:b2Fixture, f2:b2Fixture):void {
			proxyA.Set(f1.m_shape);
			proxyB.Set(f2.m_shape);
			transformA.xf = f1.m_body.m_xf.xf;
			transformB.xf = f2.m_body.m_xf.xf;
		}
		
		public var proxyA:b2DistanceProxy;
		public var proxyB:b2DistanceProxy;
		public var transformA:b2Transform;
		public var transformB:b2Transform;
		public function get useRadii():Boolean { return mem._mru8(_ptr + 104) == 1; }
		public function set useRadii(v:Boolean):void { mem._mw8(_ptr + 104, v ? 1 : 0); }
	}
}