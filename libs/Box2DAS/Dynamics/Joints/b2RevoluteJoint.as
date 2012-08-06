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
	
	public class b2RevoluteJoint extends b2Joint {
		
		public function b2RevoluteJoint(w:b2World, d:b2RevoluteJointDef = null, ed:IEventDispatcher = null) {
			d ||= b2Def.revoluteJoint;
			super(w, d, ed);
			m_localAnchor1 = new b2Vec2(_ptr + 96);
			m_localAnchor2 = new b2Vec2(_ptr + 104);
			m_impulse = new b2Vec3(_ptr + 112);
		}
		
		public override function GetAnchorA():V2 {
			return m_bodyA.GetWorldPoint(m_localAnchor1.v2);
		}
		
		public override function GetAnchorB():V2 {
			return m_bodyB.GetWorldPoint(m_localAnchor2.v2);
		}
		
		public override function GetReactionForce(inv_dt:Number):V2 {
			return new V2(m_impulse.x, m_impulse.y).multiplyN(inv_dt);
		}
		
		public override function GetReactionTorque(inv_dt:Number):Number {
			return inv_dt * m_impulse.z;
		}
		
		/// Get the current joint angle in radians.
		/// float32 GetJointAngle() const;
		public function GetJointAngle():Number {
			return m_bodyB.m_sweep.a - m_bodyA.m_sweep.a - m_referenceAngle;
		}
		
		/// Get the current joint angle speed in radians per second.
		/// float32 GetJointSpeed() const;
		public function GetJointSpeed():Number {
			return m_bodyB.m_angularVelocity - m_bodyA.m_angularVelocity;
		}
		
		/// Is the joint limit enabled?
		/// bool IsLimitEnabled() const;
		public override function IsLimitEnabled():Boolean {
			return m_enableLimit;
		}
	
		/// Enable/disable the joint limit.
		/// void EnableLimit(bool flag);
		public override function EnableLimit(flag:Boolean):void {
			WakeUp();
			m_enableLimit = flag;
		}
	
		/// Get the lower joint limit, usually in meters.
		/// float32 GetLowerLimit() const;
		public override function GetLowerLimit():Number {
			return m_lowerAngle;
		}
	
		/// Get the upper joint limit, usually in meters.
		/// float32 GetUpperLimit() const;
		public override function GetUpperLimit():Number {
			return m_upperAngle;
		}
	
		/// Set the joint limits, usually in meters.
		/// void SetLimits(float32 lower, float32 upper);
		public override function SetLimits(lower:Number, upper:Number):void {
			WakeUp();
			m_lowerAngle = lower;
			m_upperAngle = upper;
		}
		
		public override function SetLowerLimit(l:Number):void {
			WakeUp();
			m_lowerAngle = l;
		}
		
		public override function SetUpperLimit(l:Number):void {
			WakeUp();
			m_upperAngle = l;
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
		public function GetMotorTorque():Number {
			return m_motorImpulse;
		}
		
		
		public var m_localAnchor1:b2Vec2;
		public var m_localAnchor2:b2Vec2;
		public var m_impulse:b2Vec3;
		public function get m_motorImpulse():Number { return mem._mrf(_ptr + 124); }
		public function set m_motorImpulse(v:Number):void { mem._mwf(_ptr + 124, v); }
		public function get m_motorMass():Number { return mem._mrf(_ptr + 164); }
		public function set m_motorMass(v:Number):void { mem._mwf(_ptr + 164, v); }
		public function get m_enableMotor():Boolean { return mem._mru8(_ptr + 168) == 1; }
		public function set m_enableMotor(v:Boolean):void { mem._mw8(_ptr + 168, v ? 1 : 0); }
		public function get m_maxMotorTorque():Number { return mem._mrf(_ptr + 172); }
		public function set m_maxMotorTorque(v:Number):void { mem._mwf(_ptr + 172, v); }
		public function get m_motorSpeed():Number { return mem._mrf(_ptr + 176); }
		public function set m_motorSpeed(v:Number):void { mem._mwf(_ptr + 176, v); }
		public function get m_enableLimit():Boolean { return mem._mru8(_ptr + 180) == 1; }
		public function set m_enableLimit(v:Boolean):void { mem._mw8(_ptr + 180, v ? 1 : 0); }
		public function get m_referenceAngle():Number { return mem._mrf(_ptr + 184); }
		public function set m_referenceAngle(v:Number):void { mem._mwf(_ptr + 184, v); }
		public function get m_lowerAngle():Number { return mem._mrf(_ptr + 188); }
		public function set m_lowerAngle(v:Number):void { mem._mwf(_ptr + 188, v); }
		public function get m_upperAngle():Number { return mem._mrf(_ptr + 192); }
		public function set m_upperAngle(v:Number):void { mem._mwf(_ptr + 192, v); }
		public function get m_limitState():int { return mem._mrs16(_ptr + 196); }
		public function set m_limitState(v:int):void { mem._mw16(_ptr + 196, v); }
	
	}
}