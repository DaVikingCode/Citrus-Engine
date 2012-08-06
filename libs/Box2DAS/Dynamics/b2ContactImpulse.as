package Box2DAS.Dynamics {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;

	/// Contact impulses for reporting. Impulses are used instead of forces because
	/// sub-step forces may approach infinity for rigid body collisions. These
	/// match up one-to-one with the contact points in b2Manifold.	
	public class b2ContactImpulse extends b2Base {
	
		public function b2ContactImpulse(p:int) {
			_ptr = p;
		}
	
		public function get normalImpulse1():Number { return mem._mrf(_ptr + 0); }
		public function set normalImpulse1(v:Number):void { mem._mwf(_ptr + 0, v); }
		public function get normalImpulse2():Number { return mem._mrf(_ptr + 4); }
		public function set normalImpulse2(v:Number):void { mem._mwf(_ptr + 4, v); }
		public function get tangentImpulse1():Number { return mem._mrf(_ptr + 8); }
		public function set tangentImpulse1(v:Number):void { mem._mwf(_ptr + 8, v); }
		public function get tangentImpulse2():Number { return mem._mrf(_ptr + 12); }
		public function set tangentImpulse2(v:Number):void { mem._mwf(_ptr + 12, v); }	
	}
}