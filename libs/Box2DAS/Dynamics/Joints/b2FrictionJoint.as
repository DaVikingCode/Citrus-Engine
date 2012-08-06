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
	
	public class b2FrictionJoint extends b2Joint {
		
		public function b2FrictionJoint(w:b2World, d:b2FrictionJointDef = null, ed:IEventDispatcher = null) {
			d ||= b2Def.frictionJoint;
			super(w, d, ed);
			m_localAnchorA = new b2Vec2(_ptr + 96);
			m_localAnchorB = new b2Vec2(_ptr + 104);
			m_linearMass = new b2Mat22(_ptr + 112);
			m_linearImpulse = new b2Vec2(_ptr + 132);
		}
		
		public override function GetAnchorA():V2 {
			return m_bodyA.GetWorldPoint(m_localAnchorA.v2);
		}
		
		public override function GetAnchorB():V2 {
			return m_bodyB.GetWorldPoint(m_localAnchorB.v2);
		}
		
		public override function GetReactionForce(inv_dt:Number):V2 {
			return m_linearImpulse.v2.multiplyN(inv_dt);
		}
		
		public override function GetReactionTorque(inv_dt:Number):Number {
			return inv_dt * m_angularImpulse;
		}
		
		/// Set the maximum friction force in N.
		/// void SetMaxForce(float32 force);
		public function SetMaxForce(force:Number):void {
			m_maxForce = force;
		}
	
		/// Get the maximum friction force in N.
		/// float32 GetMaxForce() const;
		public function GetMaxForce():Number {
			return m_maxForce;
		}
	
		/// Set the maximum friction torque in N*m.
		/// void SetMaxTorque(float32 torque);
		public function SetMaxTorque(torque:Number):void {
			m_maxTorque = torque;
		}
	
		/// Get the maximum friction torque in N*m.
		/// float32 GetMaxTorque() const;
		public function GetMaxTorque():Number {
			return m_maxTorque;
		}
		
		public override function SetMaxMotorForce(v:Number):void { 
			m_maxForce = v;
		}
		
		public override function GetMaxMotorForce():Number {
			return m_maxForce;
		}
		
		public override function SetMaxMotorTorque(v:Number):void { 
			m_maxTorque = v;
		}
		
		public override function GetMaxMotorTorque():Number {
			return m_maxTorque;
		}		
		
		public var m_localAnchorA:b2Vec2;
		public var m_localAnchorB:b2Vec2;
		public var m_linearMass:b2Mat22;
		public function get m_angularMass():Number { return mem._mrf(_ptr + 128); }
		public function set m_angularMass(v:Number):void { mem._mwf(_ptr + 128, v); }
		public var m_linearImpulse:b2Vec2;
		public function get m_angularImpulse():Number { return mem._mrf(_ptr + 140); }
		public function set m_angularImpulse(v:Number):void { mem._mwf(_ptr + 140, v); }
		public function get m_maxForce():Number { return mem._mrf(_ptr + 144); }
		public function set m_maxForce(v:Number):void { mem._mwf(_ptr + 144, v); }
		public function get m_maxTorque():Number { return mem._mrf(_ptr + 148); }
		public function set m_maxTorque(v:Number):void { mem._mwf(_ptr + 148, v); }
	
	}
}