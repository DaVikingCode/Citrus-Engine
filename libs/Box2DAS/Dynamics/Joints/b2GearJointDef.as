package Box2DAS.Dynamics.Joints {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.events.*;
	
	/// Gear joint definition. This definition requires two existing
	/// revolute or prismatic joints (any combination will work).
	/// The provided joints must attach a dynamic body to a static body.
	public class b2GearJointDef extends b2JointDef {
	
		public override function create(w:b2World, ed:IEventDispatcher = null):b2Joint {
			return new b2GearJoint(w, this, ed);
		}
	
		public function b2GearJointDef() {
			_ptr = lib.b2GearJointDef_new();
		}
		
		public override function destroy():void {
			lib.b2GearJointDef_delete(_ptr);
			super.destroy();
		}
		
		public function Initialize(j1:b2Joint, j2:b2Joint, r:Number):void {
			bodyA = j1.GetBodyB();
			bodyB = j2.GetBodyB();
			joint1 = j1;
			joint2 = j2;
			ratio = r;
		}
		
		/// The first revolute/prismatic joint attached to the gear joint.
		public var _joint1:b2Joint;
		public function get joint1():b2Joint { return _joint1; }
		public function set joint1(v:b2Joint):void { mem._mw32(_ptr + 20, v._ptr); _joint1 = v; }
		
		/// The second revolute/prismatic joint attached to the gear joint.
		public var _joint2:b2Joint;
		public function get joint2():b2Joint { return _joint2; }
		public function set joint2(v:b2Joint):void { mem._mw32(_ptr + 24, v._ptr); _joint2 = v; }

		/// The gear ratio.
		/// @see b2GearJoint for explanation.
		public function get ratio():Number { return mem._mrf(_ptr + 28); }
		public function set ratio(v:Number):void { mem._mwf(_ptr + 28, v); }
	
	}
}