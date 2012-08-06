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
	
	/// A line joint. This joint provides one degree of freedom: translation
	/// along an axis fixed in m_bodyA. You can use a joint limit to restrict
	/// the range of motion and a joint motor to drive the motion or to
	/// model joint friction.
	public class b2LineJoint extends b2Joint {
	
		public function b2LineJoint(w:b2World, d:b2LineJointDef = null, ed:IEventDispatcher = null) {
			d ||= b2Def.lineJoint;
			super(w, d, ed);
			m_localAnchorA = new b2Vec2(_ptr + 96);
			m_localAnchorB = new b2Vec2(_ptr + 104);
			m_localXAxisA = new b2Vec2(_ptr + 112);
			m_localYAxisA = new b2Vec2(_ptr + 120);			
			m_ax = new b2Vec2(_ptr + 128);
			m_ay = new b2Vec2(_ptr + 136);			
		}
		
		public override function GetAnchorA():V2 {
			return m_bodyA.GetWorldPoint(m_localAnchorA.v2);
		}
	
		public override function GetAnchorB():V2 {
			return m_bodyB.GetWorldPoint(m_localAnchorB.v2);
		}
		
		public override function GetReactionForce(inv_dt:Number):V2 {
			return m_ay.v2.multiplyN(m_impulse).add(m_ax.v2.multiplyN(m_springImpulse)).multiplyN(inv_dt);
		}
		
		public override function GetReactionTorque(inv_dt:Number):Number {
			return inv_dt * m_motorImpulse;
		}
		
		/// Get the current joint translation, usually in meters.
		/// float32 GetJointTranslation() const;
		public function GetJointTranslation():Number {
			var p1:V2 = m_bodyA.GetWorldPoint(m_localAnchorA.v2);
			var p2:V2 = m_bodyB.GetWorldPoint(m_localAnchorB.v2);
			return V2.subtract(p2, p1).dot(m_bodyA.GetWorldVector(m_localXAxisA.v2));
		}
	
		/// Get the current joint translation speed, usually in meters per second.
		/// float32 GetJointSpeed() const;
		public function GetJointSpeed():Number {
			var r1:V2 = m_bodyA.m_xf.xf.r.multiplyV(m_localAnchorA.v2.subtract(m_bodyA.GetLocalCenter()));
			var r2:V2 = m_bodyB.m_xf.xf.r.multiplyV(m_localAnchorB.v2.subtract(m_bodyB.GetLocalCenter()));
			var d:V2 = m_bodyA.m_sweep.c.v2.add(r1).subtract(m_bodyB.m_sweep.c.v2.add(r2));
			var axis:V2 = m_bodyA.GetWorldVector(m_localXAxisA.v2);
			var v1:V2 = m_bodyA.m_linearVelocity.v2;
			var v2:V2 = m_bodyB.m_linearVelocity.v2;
			var w1:Number = m_bodyA.m_angularVelocity;
			var w2:Number = m_bodyB.m_angularVelocity;
			return d.dot(V2.crossNV(w1, axis)) + axis.dot(v2.add(V2.crossNV(w2, r2).subtract(v1).subtract(V2.crossNV(w1, r1))));			
		}
		
		
		/// Is the joint motor enabled?
		/// bool IsMotorEnabled() const;
		public override function IsMotorEnabled():Boolean {
			return m_enableMotor;
		}
	
		/// Enable/disable the joint motor.
		/// void EnableMotor(bool flag);
		public override function EnableMotor(flag:Boolean):void {
			WakeUp();
			m_enableMotor = flag;
		}
		
		/// Set the motor speed, usually in meters per second.
		/// void SetMotorSpeed(float32 speed);
		public override function SetMotorSpeed(speed:Number):void {
			WakeUp();
			m_motorSpeed = speed;
		}
		
		/// Get the motor speed, usually in meters per second.
		/// float32 GetMotorSpeed() const;
		public override function GetMotorSpeed():Number {
			return m_motorSpeed;
		}
		
		/// Set the maximum motor force, usually in N.
		/// void SetMaxMotorForce(float32 force);
		public override function SetMaxMotorTorque(torque:Number):void {
			WakeUp();
			m_maxMotorTorque = torque;
		}
		
		public override function GetMaxMotorTorque():Number {
			return m_maxMotorTorque;
		}
		
		/// Get the current motor force, usually in N.
		/// float32 GetMotorForce() const;
		public function GetMotorTorque(inv_dt:Number):Number {
			return inv_dt * m_motorImpulse;
		}
	
		public var m_localAnchorA:b2Vec2;
		public var m_localAnchorB:b2Vec2;
		public var m_localXAxisA:b2Vec2; 
		public var m_localYAxisA:b2Vec2;
		public var m_ax:b2Vec2;
		public var m_ay:b2Vec2;

		public function get m_sAx():Number { return mem._mrf(_ptr + 144); }
		public function set m_sAx(v:Number):void { mem._mwf(_ptr + 144, v); }
		public function get m_sBx():Number { return mem._mrf(_ptr + 148); }
		public function set m_sBx(v:Number):void { mem._mwf(_ptr + 148, v); }
		public function get m_sAy():Number { return mem._mrf(_ptr + 152); }
		public function set m_sAy(v:Number):void { mem._mwf(_ptr + 152, v); }
		public function get m_sBy():Number { return mem._mrf(_ptr + 156); }
		public function set m_sBy(v:Number):void { mem._mwf(_ptr + 156, v); }
		public function get m_mass():Number { return mem._mrf(_ptr + 160); }
		public function set m_mass(v:Number):void { mem._mwf(_ptr + 160, v); }
		public function get m_impulse():Number { return mem._mrf(_ptr + 164); }
		public function set m_impulse(v:Number):void { mem._mwf(_ptr + 164, v); }
		public function get m_motorMass():Number { return mem._mrf(_ptr + 168); }
		public function set m_motorMass(v:Number):void { mem._mwf(_ptr + 168, v); }
		public function get m_motorImpulse():Number { return mem._mrf(_ptr + 172); }
		public function set m_motorImpulse(v:Number):void { mem._mwf(_ptr + 172, v); }
		public function get m_springMass():Number { return mem._mrf(_ptr + 176); }
		public function set m_springMass(v:Number):void { mem._mwf(_ptr + 176, v); }
		public function get m_springImpulse():Number { return mem._mrf(_ptr + 180); }
		public function set m_springImpulse(v:Number):void { mem._mwf(_ptr + 180, v); }
		public function get m_maxMotorTorque():Number { return mem._mrf(_ptr + 184); }
		public function set m_maxMotorTorque(v:Number):void { mem._mwf(_ptr + 184, v); }
		public function get m_motorSpeed():Number { return mem._mrf(_ptr + 188); }
		public function set m_motorSpeed(v:Number):void { mem._mwf(_ptr + 188, v); }
		public function get m_frequencyHz():Number { return mem._mrf(_ptr + 192); }
		public function set m_frequencyHz(v:Number):void { mem._mwf(_ptr + 192, v); }
		public function get m_dampingRatio():Number { return mem._mrf(_ptr + 196); }
		public function set m_dampingRatio(v:Number):void { mem._mwf(_ptr + 196, v); }
		public function get m_bias():Number { return mem._mrf(_ptr + 200); }
		public function set m_bias(v:Number):void { mem._mwf(_ptr + 200, v); }
		public function get m_gamma():Number { return mem._mrf(_ptr + 204); }
		public function set m_gamma(v:Number):void { mem._mwf(_ptr + 204, v); }
		public function get m_enableMotor():Boolean { return mem._mru8(_ptr + 208) == 1; }
		public function set m_enableMotor(v:Boolean):void { mem._mw8(_ptr + 208, v ? 1 : 0); }		
	
	}
}