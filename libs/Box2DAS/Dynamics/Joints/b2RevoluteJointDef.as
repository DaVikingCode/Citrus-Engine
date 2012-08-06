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
	
	/// Revolute joint definition. This requires defining an
	/// anchor point where the bodies are joined. The definition
	/// uses local anchor points so that the initial configuration
	/// can violate the constraint slightly. You also need to
	/// specify the initial relative angle for joint limits. This
	/// helps when saving and loading a game.
	/// The local anchor points are measured from the body's origin
	/// rather than the center of mass because:
	/// 1. you might not know where the center of mass will be.
	/// 2. if you add/remove shapes from a body and recompute the mass,
	///    the joints will be broken.
	public class b2RevoluteJointDef extends b2JointDef {
		
		public override function create(w:b2World, ed:IEventDispatcher = null):b2Joint {
			return new b2RevoluteJoint(w, this, ed);
		}
		
		public function b2RevoluteJointDef() {
			_ptr = lib.b2RevoluteJointDef_new();
			localAnchorA = new b2Vec2(_ptr + 20);
			localAnchorB = new b2Vec2(_ptr + 28);
		}
		
		public override function destroy():void {
			lib.b2RevoluteJointDef_delete(_ptr);
			super.destroy();
		}
		
		/// Initialize the bodies, anchors, and reference angle using the world
		/// anchor.
		/// void b2RevoluteJointDef::Initialize(b2Body* b1, b2Body* b2, const b2Vec2& anchor)
		public function Initialize(b1:b2Body, b2:b2Body, anchor:V2):void {
			bodyA = b1;
			bodyB = b2;
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

		/// A flag to enable joint limits.
		public function get enableLimit():Boolean { return mem._mru8(_ptr + 40) == 1; }
		public function set enableLimit(v:Boolean):void { mem._mw8(_ptr + 40, v ? 1 : 0); }

		/// The lower angle for the joint limit (radians).
		public function get lowerAngle():Number { return mem._mrf(_ptr + 44); }
		public function set lowerAngle(v:Number):void { mem._mwf(_ptr + 44, v); }

		/// The upper angle for the joint limit (radians).
		public function get upperAngle():Number { return mem._mrf(_ptr + 48); }
		public function set upperAngle(v:Number):void { mem._mwf(_ptr + 48, v); }

		/// A flag to enable the joint motor.
		public function get enableMotor():Boolean { return mem._mru8(_ptr + 52) == 1; }
		public function set enableMotor(v:Boolean):void { mem._mw8(_ptr + 52, v ? 1 : 0); }

		/// The desired motor speed. Usually in radians per second.
		public function get motorSpeed():Number { return mem._mrf(_ptr + 56); }
		public function set motorSpeed(v:Number):void { mem._mwf(_ptr + 56, v); }

		/// The maximum motor torque used to achieve the desired motor speed.
		/// Usually in N-m.
		public function get maxMotorTorque():Number { return mem._mrf(_ptr + 60); }
		public function set maxMotorTorque(v:Number):void { mem._mwf(_ptr + 60, v); }
	
	}
}