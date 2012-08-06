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
	
	/// Line joint definition. This requires defining a line of
	/// motion using an axis and an anchor point. The definition uses local
	/// anchor points and a local axis so that the initial configuration
	/// can violate the constraint slightly. The joint translation is zero
	/// when the local anchor points coincide in world space. Using local
	/// anchors and a local axis helps when saving and loading a game.
	public class b2LineJointDef extends b2JointDef {

		public override function create(w:b2World, ed:IEventDispatcher = null):b2Joint {
			return new b2LineJoint(w, this, ed);
		}
	
		public function b2LineJointDef() {
			_ptr = lib.b2LineJointDef_new();
			localAnchorA = new b2Vec2(_ptr + 20);
			localAnchorB = new b2Vec2(_ptr + 28);
			localAxisA = new b2Vec2(_ptr + 36);
		}
		
		public override function destroy():void {
			lib.b2LineJointDef_delete(_ptr);
			super.destroy();
		}
		
		/// Initialize the bodies, anchors, axis, and reference angle using the world
		/// anchor and world axis.
		/// void Initialize(b2Body* bodyA, b2Body* bodyB, const b2Vec2& anchor, const b2Vec2& axis);
		public function Initialize(b1:b2Body, b2:b2Body, anchor:V2, axis:V2):void {
			bodyA = b1;
			bodyB = b2;
			localAnchorA.v2 = bodyA.GetLocalPoint(anchor);
			localAnchorB.v2 = bodyB.GetLocalPoint(anchor);
			localAxisA.v2 = bodyA.GetLocalVector(axis);
		}

		/// The local anchor point relative to bodyA's origin.
		public var localAnchorA:b2Vec2; 
		
		/// The local anchor point relative to bodyB's origin.
		public var localAnchorB:b2Vec2; 
		
		/// The local translation axis in bodyA.
		public var localAxisA:b2Vec2;
		
		/// Enable/disable the joint motor.
		public function get enableMotor():Boolean { return mem._mru8(_ptr + 44) == 1; }
		public function set enableMotor(v:Boolean):void { mem._mw8(_ptr + 44, v ? 1 : 0); }
		
		/// The maximum motor torque, usually in N-m.
		public function get maxMotorTorque():Number { return mem._mrf(_ptr + 48); }
		public function set maxMotorTorque(v:Number):void { mem._mwf(_ptr + 48, v); }
		
		/// The desired motor speed in radians per second.
		public function get motorSpeed():Number { return mem._mrf(_ptr + 52); }
		public function set motorSpeed(v:Number):void { mem._mwf(_ptr + 52, v); }
		
		/// Suspension frequency, zero indicates no suspension
		public function get frequencyHz():Number { return mem._mrf(_ptr + 56); }
		public function set frequencyHz(v:Number):void { mem._mwf(_ptr + 56, v); }		
		
		/// Suspension damping ratio, one indicates critical damping		
		public function get dampingRatio():Number { return mem._mrf(_ptr + 60); }
		public function set dampingRatio(v:Number):void { mem._mwf(_ptr + 60, v); }
	
	}
}