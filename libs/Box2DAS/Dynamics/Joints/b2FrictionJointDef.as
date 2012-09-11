package Box2DAS.Dynamics.Joints {

	import Box2DAS.Common.V2;
	import Box2DAS.Common.b2Vec2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2World;

	import flash.events.IEventDispatcher;
	
	/// Friction joint definition.
	public class b2FrictionJointDef extends b2JointDef {

		public override function create(w:b2World, ed:IEventDispatcher = null):b2Joint {
			return new b2FrictionJoint(w, this, ed);
		}
		
		public function b2FrictionJointDef() {
			_ptr = lib.b2FrictionJointDef_new();
			localAnchorA = new b2Vec2(_ptr + 20);
			localAnchorB = new b2Vec2(_ptr + 28);
		}
		
		public override function destroy():void {
			lib.b2FrictionJointDef_delete(_ptr);
			super.destroy();
		}
		
		/// Initialize the bodies, anchors, axis, and reference angle using the world
		/// anchor and world axis.
		/// void Initialize(b2Body* bodyA, b2Body* bodyB, const b2Vec2& anchor);
		public function Initialize(bA:b2Body, bB:b2Body, anchor:V2):void {
			bodyA = bA;
			bodyB = bB;
			localAnchorA.v2 = bodyA.GetLocalPoint(anchor);
			localAnchorB.v2 = bodyB.GetLocalPoint(anchor);
		}
		
		/// The local anchor point relative to bodyA's origin.
		public var localAnchorA:b2Vec2;
		
		/// The local anchor point relative to bodyB's origin.
		public var localAnchorB:b2Vec2;
		
		/// The maximum friction force in N.
		public function get maxForce():Number { return mem._mrf(_ptr + 36); }
		public function set maxForce(v:Number):void { mem._mwf(_ptr + 36, v); }
		
		/// The maximum friction torque in N-m.
		public function get maxTorque():Number { return mem._mrf(_ptr + 40); }
		public function set maxTorque(v:Number):void { mem._mwf(_ptr + 40, v); }
	
	}
}