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
	
	/// Weld joint definition. You need to specify local anchor points
	/// where they are attached and the relative body angle. The position
	/// of the anchor points is important for computing the reaction torque.
	public class b2WeldJointDef extends b2JointDef {
		
		public override function create(w:b2World, ed:IEventDispatcher = null):b2Joint {
			return new b2WeldJoint(w, this, ed);
		}
		
		public function b2WeldJointDef() {
			_ptr = lib.b2WeldJointDef_new();
			localAnchorA = new b2Vec2(_ptr + 20);
			localAnchorB = new b2Vec2(_ptr + 28);
		}
		
		public override function destroy():void {
			lib.b2WeldJointDef_delete(_ptr);
			super.destroy();
		}
		
		/// Initialize the bodies, anchors, and reference angle using a world
		/// anchor point.
		/// void Initialize(b2Body* bodyA, b2Body* bodyB, const b2Vec2& anchor);
		public function Initialize(bA:b2Body, bB:b2Body, anchor:V2):void {
			bodyA = bA;
			bodyB = bB;
			localAnchorA.v2 = bodyA.GetLocalPoint(anchor);
			localAnchorB.v2 = bodyB.GetLocalPoint(anchor);
			referenceAngle = bodyB.GetAngle() - bodyA.GetAngle();
		}
		
		/// The local anchor point relative to bodyA's origin.
		public var localAnchorA:b2Vec2;
		
		/// The local anchor point relative to bodyB's origin.
		public var localAnchorB:b2Vec2;
		
		/// The bodyB angle minus bodyA angle in the reference state (radians).
		public function get referenceAngle():Number { return mem._mrf(_ptr + 36); }
		public function set referenceAngle(v:Number):void { mem._mwf(_ptr + 36, v); }
	
	}
}