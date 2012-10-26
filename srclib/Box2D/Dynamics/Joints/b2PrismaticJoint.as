/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

package Box2D.Dynamics.Joints{


	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
use namespace b2internal;


// Linear constraint (point-to-line)
// d = p2 - p1 = x2 + r2 - x1 - r1
// C = dot(perp, d)
// Cdot = dot(d, cross(w1, perp)) + dot(perp, v2 + cross(w2, r2) - v1 - cross(w1, r1))
//      = -dot(perp, v1) - dot(cross(d + r1, perp), w1) + dot(perp, v2) + dot(cross(r2, perp), v2)
// J = [-perp, -cross(d + r1, perp), perp, cross(r2,perp)]
//
// Angular constraint
// C = a2 - a1 + a_initial
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
//
// K = J * invM * JT
//
// J = [-a -s1 a s2]
//     [0  -1  0  1]
// a = perp
// s1 = cross(d + r1, a) = cross(p2 - x1, a)
// s2 = cross(r2, a) = cross(p2 - x2, a)

// Motor/Limit linear constraint
// C = dot(ax1, d)
// Cdot = = -dot(ax1, v1) - dot(cross(d + r1, ax1), w1) + dot(ax1, v2) + dot(cross(r2, ax1), v2)
// J = [-ax1 -cross(d+r1,ax1) ax1 cross(r2,ax1)]

// Block Solver
// We develop a block solver that includes the joint limit. This makes the limit stiff (inelastic) even
// when the mass has poor distribution (leading to large torques about the joint anchor points).
//
// The Jacobian has 3 rows:
// J = [-uT -s1 uT s2] // linear
//     [0   -1   0  1] // angular
//     [-vT -a1 vT a2] // limit
//
// u = perp
// v = axis
// s1 = cross(d + r1, u), s2 = cross(r2, u)
// a1 = cross(d + r1, v), a2 = cross(r2, v)

// M * (v2 - v1) = JT * df
// J * v2 = bias
//
// v2 = v1 + invM * JT * df
// J * (v1 + invM * JT * df) = bias
// K * df = bias - J * v1 = -Cdot
// K = J * invM * JT
// Cdot = J * v1 - bias
//
// Now solve for f2.
// df = f2 - f1
// K * (f2 - f1) = -Cdot
// f2 = invK * (-Cdot) + f1
//
// Clamp accumulated limit impulse.
// lower: f2(3) = max(f2(3), 0)
// upper: f2(3) = min(f2(3), 0)
//
// Solve for correct f2(1:2)
// K(1:2, 1:2) * f2(1:2) = -Cdot(1:2) - K(1:2,3) * f2(3) + K(1:2,1:3) * f1
//                       = -Cdot(1:2) - K(1:2,3) * f2(3) + K(1:2,1:2) * f1(1:2) + K(1:2,3) * f1(3)
// K(1:2, 1:2) * f2(1:2) = -Cdot(1:2) - K(1:2,3) * (f2(3) - f1(3)) + K(1:2,1:2) * f1(1:2)
// f2(1:2) = invK(1:2,1:2) * (-Cdot(1:2) - K(1:2,3) * (f2(3) - f1(3))) + f1(1:2)
//
// Now compute impulse to be applied:
// df = f2 - f1

/**
* A prismatic joint. This joint provides one degree of freedom: translation
* along an axis fixed in body1. Relative rotation is prevented. You can
* use a joint limit to restrict the range of motion and a joint motor to
* drive the motion or to model joint friction.
* @see b2PrismaticJointDef
*/
public class b2PrismaticJoint extends b2Joint
{
	/** @inheritDoc */
	public override function GetAnchorA():b2Vec2{
		return m_bodyA.GetWorldPoint(m_localAnchor1);
	}
	/** @inheritDoc */
	public override function GetAnchorB():b2Vec2{
		return m_bodyB.GetWorldPoint(m_localAnchor2);
	}
	/** @inheritDoc */
	public override function GetReactionForce(inv_dt:Number) : b2Vec2
	{
		//return inv_dt * (m_impulse.x * m_perp + (m_motorImpulse + m_impulse.z) * m_axis);
		return new b2Vec2(	inv_dt * (m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.z) * m_axis.x),
							inv_dt * (m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.z) * m_axis.y));
	}

	/** @inheritDoc */
	public override function GetReactionTorque(inv_dt:Number) : Number
	{
		return inv_dt * m_impulse.y;
	}
	
	/**
	* Get the current joint translation, usually in meters.
	*/
	public function GetJointTranslation():Number{
		var bA:b2Body = m_bodyA;
		var bB:b2Body = m_bodyB;
		
		var tMat:b2Mat22;
		
		var p1:b2Vec2 = bA.GetWorldPoint(m_localAnchor1);
		var p2:b2Vec2 = bB.GetWorldPoint(m_localAnchor2);
		//var d:b2Vec2 = b2Math.SubtractVV(p2, p1);
		var dX:Number = p2.x - p1.x;
		var dY:Number = p2.y - p1.y;
		//b2Vec2 axis = bA->GetWorldVector(m_localXAxis1);
		var axis:b2Vec2 = bA.GetWorldVector(m_localXAxis1);
		
		//float32 translation = b2Dot(d, axis);
		var translation:Number = axis.x*dX + axis.y*dY;
		return translation;
	}
	
	/**
	* Get the current joint translation speed, usually in meters per second.
	*/
	public function GetJointSpeed():Number{
		var bA:b2Body = m_bodyA;
		var bB:b2Body = m_bodyB;
		
		var tMat:b2Mat22;
		
		//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var r1X:Number = m_localAnchor1.x - bA.m_sweep.localCenter.x;
		var r1Y:Number = m_localAnchor1.y - bA.m_sweep.localCenter.y;
		var tX:Number =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var r2X:Number = m_localAnchor2.x - bB.m_sweep.localCenter.x;
		var r2Y:Number = m_localAnchor2.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		//b2Vec2 p1 = bA->m_sweep.c + r1;
		var p1X:Number = bA.m_sweep.c.x + r1X;
		var p1Y:Number = bA.m_sweep.c.y + r1Y;
		//b2Vec2 p2 = bB->m_sweep.c + r2;
		var p2X:Number = bB.m_sweep.c.x + r2X;
		var p2Y:Number = bB.m_sweep.c.y + r2Y;
		//var d:b2Vec2 = b2Math.SubtractVV(p2, p1);
		var dX:Number = p2X - p1X;
		var dY:Number = p2Y - p1Y;
		//b2Vec2 axis = bA->GetWorldVector(m_localXAxis1);
		var axis:b2Vec2 = bA.GetWorldVector(m_localXAxis1);
		
		var v1:b2Vec2 = bA.m_linearVelocity;
		var v2:b2Vec2 = bB.m_linearVelocity;
		var w1:Number = bA.m_angularVelocity;
		var w2:Number = bB.m_angularVelocity;
		
		//var speed:Number = b2Math.b2Dot(d, b2Math.b2CrossFV(w1, ax1)) + b2Math.b2Dot(ax1, b2Math.SubtractVV( b2Math.SubtractVV( b2Math.AddVV( v2 , b2Math.b2CrossFV(w2, r2)) , v1) , b2Math.b2CrossFV(w1, r1)));
		//var b2D:Number = (dX*(-w1 * ax1Y) + dY*(w1 * ax1X));
		//var b2D2:Number = (ax1X * ((( v2.x + (-w2 * r2Y)) - v1.x) - (-w1 * r1Y)) + ax1Y * ((( v2.y + (w2 * r2X)) - v1.y) - (w1 * r1X)));
		var speed:Number = (dX*(-w1 * axis.y) + dY*(w1 * axis.x)) + (axis.x * ((( v2.x + (-w2 * r2Y)) - v1.x) - (-w1 * r1Y)) + axis.y * ((( v2.y + (w2 * r2X)) - v1.y) - (w1 * r1X)));
		
		return speed;
	}
	
	/**
	* Is the joint limit enabled?
	*/
	public function IsLimitEnabled() : Boolean
	{
		return m_enableLimit;
	}
	/**
	* Enable/disable the joint limit.
	*/
	public function EnableLimit(flag:Boolean) : void
	{
		m_bodyA.SetAwake(true);
		m_bodyB.SetAwake(true);
		m_enableLimit = flag;
	}
	/**
	* Get the lower joint limit, usually in meters.
	*/
	public function GetLowerLimit() : Number
	{
		return m_lowerTranslation;
	}
	/**
	* Get the upper joint limit, usually in meters.
	*/
	public function GetUpperLimit() : Number
	{
		return m_upperTranslation;
	}
	/**
	* Set the joint limits, usually in meters.
	*/
	public function SetLimits(lower:Number, upper:Number) : void
	{
		//b2Settings.b2Assert(lower <= upper);
		m_bodyA.SetAwake(true);
		m_bodyB.SetAwake(true);
		m_lowerTranslation = lower;
		m_upperTranslation = upper;
	}
	/**
	* Is the joint motor enabled?
	*/
	public function IsMotorEnabled() : Boolean
	{
		return m_enableMotor;
	}
	/**
	* Enable/disable the joint motor.
	*/
	public function EnableMotor(flag:Boolean) : void
	{
		m_bodyA.SetAwake(true);
		m_bodyB.SetAwake(true);
		m_enableMotor = flag;
	}
	/**
	* Set the motor speed, usually in meters per second.
	*/
	public function SetMotorSpeed(speed:Number) : void
	{
		m_bodyA.SetAwake(true);
		m_bodyB.SetAwake(true);
		m_motorSpeed = speed;
	}
	/**
	* Get the motor speed, usually in meters per second.
	*/
	public function GetMotorSpeed() :Number
	{
		return m_motorSpeed;
	}
	
	/**
	* Set the maximum motor force, usually in N.
	*/
	public function SetMaxMotorForce(force:Number) : void
	{
		m_bodyA.SetAwake(true);
		m_bodyB.SetAwake(true);
		m_maxMotorForce = force;
	}
	/**
	* Get the current motor force, usually in N.
	*/
	public function GetMotorForce() : Number
	{
		return m_motorImpulse;
	}
	

	//--------------- Internals Below -------------------

	/** @private */
	public function b2PrismaticJoint(def:b2PrismaticJointDef){
		super(def);
		
		var tMat:b2Mat22;
		var tX:Number;
		var tY:Number;
		
		m_localAnchor1.SetV(def.localAnchorA);
		m_localAnchor2.SetV(def.localAnchorB);
		m_localXAxis1.SetV(def.localAxisA);
		
		//m_localYAxisA = b2Cross(1.0f, m_localXAxisA);
		m_localYAxis1.x = -m_localXAxis1.y;
		m_localYAxis1.y = m_localXAxis1.x;
		
		m_refAngle = def.referenceAngle;
		
		m_impulse.SetZero();
		m_motorMass = 0.0;
		m_motorImpulse = 0.0;
		
		m_lowerTranslation = def.lowerTranslation;
		m_upperTranslation = def.upperTranslation;
		m_maxMotorForce = def.maxMotorForce;
		m_motorSpeed = def.motorSpeed;
		m_enableLimit = def.enableLimit;
		m_enableMotor = def.enableMotor;
		m_limitState = e_inactiveLimit;
		
		m_axis.SetZero();
		m_perp.SetZero();
	}

	b2internal override function InitVelocityConstraints(step:b2TimeStep) : void{
		var bA:b2Body = m_bodyA;
		var bB:b2Body = m_bodyB;
		
		var tMat:b2Mat22;
		var tX:Number;
		
		m_localCenterA.SetV(bA.GetLocalCenter());
		m_localCenterB.SetV(bB.GetLocalCenter());
		
		var xf1:b2Transform = bA.GetTransform();
		var xf2:b2Transform = bB.GetTransform();
		
		// Compute the effective masses.
		//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var r1X:Number = m_localAnchor1.x - m_localCenterA.x;
		var r1Y:Number = m_localAnchor1.y - m_localCenterA.y;
		tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var r2X:Number = m_localAnchor2.x - m_localCenterB.x;
		var r2Y:Number = m_localAnchor2.y - m_localCenterB.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		//b2Vec2 d = bB->m_sweep.c + r2 - bA->m_sweep.c - r1;
		var dX:Number = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X;
		var dY:Number = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y;
		
		m_invMassA = bA.m_invMass;
		m_invMassB = bB.m_invMass;
		m_invIA = bA.m_invI;
		m_invIB = bB.m_invI;
		
		// Compute motor Jacobian and effective mass.
		{
			m_axis.SetV(b2Math.MulMV(xf1.R, m_localXAxis1));
			//m_a1 = b2Math.b2Cross(d + r1, m_axis);
			m_a1 = (dX + r1X) * m_axis.y - (dY + r1Y) * m_axis.x;
			//m_a2 = b2Math.b2Cross(r2, m_axis);
			m_a2 = r2X * m_axis.y - r2Y * m_axis.x;
			
			m_motorMass = m_invMassA + m_invMassB + m_invIA * m_a1 * m_a1 + m_invIB * m_a2 * m_a2; 
			if(m_motorMass > Number.MIN_VALUE)
				m_motorMass = 1.0 / m_motorMass;
		}
		
		// Prismatic constraint.
		{
			m_perp.SetV(b2Math.MulMV(xf1.R, m_localYAxis1));
			//m_s1 = b2Math.b2Cross(d + r1, m_perp);
			m_s1 = (dX + r1X) * m_perp.y - (dY + r1Y) * m_perp.x;
			//m_s2 = b2Math.b2Cross(r2, m_perp);
			m_s2 = r2X * m_perp.y - r2Y * m_perp.x;
			
			var m1:Number = m_invMassA;
			var m2:Number = m_invMassB;
			var i1:Number = m_invIA;
			var i2:Number = m_invIB;
			
			m_K.col1.x = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2;
 	  	  	m_K.col1.y = i1 * m_s1 + i2 * m_s2;
 	  	  	m_K.col1.z = i1 * m_s1 * m_a1 + i2 * m_s2 * m_a2;
			m_K.col2.x = m_K.col1.y;
 	  	  	m_K.col2.y = i1 + i2;
 	  	  	m_K.col2.z = i1 * m_a1 + i2 * m_a2;
			m_K.col3.x = m_K.col1.z;
			m_K.col3.y = m_K.col2.z;
 	  	  	m_K.col3.z = m1 + m2 + i1 * m_a1 * m_a1 + i2 * m_a2 * m_a2; 
		}
		
		// Compute motor and limit terms
		if (m_enableLimit)
		{
			//float32 jointTranslation = b2Dot(m_axis, d); 
			var jointTransition:Number = m_axis.x * dX + m_axis.y * dY;
			if (b2Math.Abs(m_upperTranslation - m_lowerTranslation) < 2.0 * b2Settings.b2_linearSlop)
			{
				m_limitState = e_equalLimits;
			}
			else if (jointTransition <= m_lowerTranslation)
			{
				if (m_limitState != e_atLowerLimit)
				{
					m_limitState = e_atLowerLimit;
					m_impulse.z = 0.0;
				}
			}
			else if (jointTransition >= m_upperTranslation)
			{
				if (m_limitState != e_atUpperLimit)
				{
					m_limitState = e_atUpperLimit;
					m_impulse.z = 0.0;
				}
			}
			else
			{
				m_limitState = e_inactiveLimit;
				m_impulse.z = 0.0;
			}
		}
		else
		{
			m_limitState = e_inactiveLimit;
		}
		
		if (m_enableMotor == false)
		{
			m_motorImpulse = 0.0
		}
		
		if (step.warmStarting)
		{
			// Account for variable time step.
			m_impulse.x *= step.dtRatio;
			m_impulse.y *= step.dtRatio;
			m_motorImpulse *= step.dtRatio; 
			
			//b2Vec2 P = m_impulse.x * m_perp + (m_motorImpulse + m_impulse.z) * m_axis;
			var PX:Number = m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.z) * m_axis.x;
			var PY:Number = m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.z) * m_axis.y;
			var L1:Number = m_impulse.x * m_s1 + m_impulse.y + (m_motorImpulse + m_impulse.z) * m_a1;
			var L2:Number = m_impulse.x * m_s2 + m_impulse.y + (m_motorImpulse + m_impulse.z) * m_a2; 

			//bA->m_linearVelocity -= m_invMassA * P;
			bA.m_linearVelocity.x -= m_invMassA * PX;
			bA.m_linearVelocity.y -= m_invMassA * PY;
			//bA->m_angularVelocity -= m_invIA * L1;
			bA.m_angularVelocity -= m_invIA * L1;
			
			//bB->m_linearVelocity += m_invMassB * P;
			bB.m_linearVelocity.x += m_invMassB * PX;
			bB.m_linearVelocity.y += m_invMassB * PY;
			//bB->m_angularVelocity += m_invIB * L2;
			bB.m_angularVelocity += m_invIB * L2;
		}
		else
		{
			m_impulse.SetZero();
			m_motorImpulse = 0.0;
		}
	}
	
	b2internal override function SolveVelocityConstraints(step:b2TimeStep) : void{
		var bA:b2Body = m_bodyA;
		var bB:b2Body = m_bodyB;
		
		var v1:b2Vec2 = bA.m_linearVelocity;
		var w1:Number = bA.m_angularVelocity;
		var v2:b2Vec2 = bB.m_linearVelocity;
		var w2:Number = bB.m_angularVelocity;
		
		var PX:Number;
		var PY:Number;
		var L1:Number;
		var L2:Number;
		
		// Solve linear motor constraint
		if (m_enableMotor && m_limitState != e_equalLimits)
		{
			//float32 Cdot = b2Dot(m_axis, v2 - v1) + m_a2 * w2 - m_a1 * w1; 
			var Cdot:Number = m_axis.x * (v2.x -v1.x) + m_axis.y * (v2.y - v1.y) + m_a2 * w2 - m_a1 * w1;
			var impulse:Number = m_motorMass * (m_motorSpeed - Cdot);
			var oldImpulse:Number = m_motorImpulse;
			var maxImpulse:Number = step.dt * m_maxMotorForce;
			m_motorImpulse = b2Math.Clamp(m_motorImpulse + impulse, -maxImpulse, maxImpulse);
			impulse = m_motorImpulse - oldImpulse;
			
			PX = impulse * m_axis.x;
			PY = impulse * m_axis.y;
			L1 = impulse * m_a1;
			L2 = impulse * m_a2;
			
			v1.x -= m_invMassA * PX;
			v1.y -= m_invMassA * PY;
			w1 -= m_invIA * L1;
			
			v2.x += m_invMassB * PX;
			v2.y += m_invMassB * PY;
			w2 += m_invIB * L2;
		}
		
		//Cdot1.x = b2Dot(m_perp, v2 - v1) + m_s2 * w2 - m_s1 * w1; 
		var Cdot1X:Number = m_perp.x * (v2.x - v1.x) + m_perp.y * (v2.y - v1.y) + m_s2 * w2 - m_s1 * w1; 
		var Cdot1Y:Number = w2 - w1;
		
		if (m_enableLimit && m_limitState != e_inactiveLimit)
		{
			// Solve prismatic and limit constraint in block form
			//Cdot2 = b2Dot(m_axis, v2 - v1) + m_a2 * w2 - m_a1 * w1; 
			var Cdot2:Number = m_axis.x * (v2.x - v1.x) + m_axis.y * (v2.y - v1.y) + m_a2 * w2 - m_a1 * w1; 
			
			var f1:b2Vec3 = m_impulse.Copy();
			var df:b2Vec3 = m_K.Solve33(new b2Vec3(), -Cdot1X, -Cdot1Y, -Cdot2);
			
			m_impulse.Add(df);
			
			if (m_limitState == e_atLowerLimit)
			{
				m_impulse.z = b2Math.Max(m_impulse.z, 0.0);
			}
			else if (m_limitState == e_atUpperLimit)
			{
				m_impulse.z = b2Math.Min(m_impulse.z, 0.0);
			}
			
			// f2(1:2) = invK(1:2,1:2) * (-Cdot3\(1:2) - K(1:2,3) * (f2(3) - f1(3))) + f1(1:2) 
			//b2Vec2 b = -Cdot1 - (m_impulse.z - f1.z) * b2Vec2(m_K.col3.x, m_K.col3.y); 
			var bX:Number = -Cdot1X - (m_impulse.z - f1.z) * m_K.col3.x;
			var bY:Number = -Cdot1Y - (m_impulse.z - f1.z) * m_K.col3.y;
			var f2r:b2Vec2 = m_K.Solve22(new b2Vec2(), bX, bY)
			f2r.x += f1.x;
			f2r.y += f1.y;
			m_impulse.x = f2r.x;
			m_impulse.y = f2r.y;
			
			df.x = m_impulse.x - f1.x;
			df.y = m_impulse.y - f1.y;
			df.z = m_impulse.z - f1.z;
			
			PX = df.x * m_perp.x + df.z * m_axis.x;
			PY = df.x * m_perp.y + df.z * m_axis.y;
			L1 = df.x * m_s1 + df.y + df.z * m_a1;
			L2 = df.x * m_s2 + df.y + df.z * m_a2;
			
			v1.x -= m_invMassA * PX;
			v1.y -= m_invMassA * PY;
			w1 -= m_invIA * L1;
			
			v2.x += m_invMassB * PX;
			v2.y += m_invMassB * PY;
			w2 += m_invIB * L2;
		}
		else
		{
			// Limit is inactive, just solve the prismatic constraint in block form. 
			var df2:b2Vec2 = m_K.Solve22(new b2Vec2(), -Cdot1X, -Cdot1Y);
			m_impulse.x += df2.x;
			m_impulse.y += df2.y;
			
			PX = df2.x * m_perp.x;
			PY = df2.x * m_perp.y;
			L1 = df2.x * m_s1 + df2.y;
			L2 = df2.x * m_s2 + df2.y;
			
			v1.x -= m_invMassA * PX;
			v1.y -= m_invMassA * PY;
			w1 -= m_invIA * L1;
			
			v2.x += m_invMassB * PX;
			v2.y += m_invMassB * PY;
			w2 += m_invIB * L2;
		}
		
		bA.m_linearVelocity.SetV(v1);
		bA.m_angularVelocity = w1;
		bB.m_linearVelocity.SetV(v2);
		bB.m_angularVelocity = w2;
	}
	
	b2internal override function SolvePositionConstraints(baumgarte:Number ):Boolean
	{
		//B2_NOT_USED(baumgarte);
		
		
		var limitC:Number;
		var oldLimitImpulse:Number;
		
		var bA:b2Body = m_bodyA;
		var bB:b2Body = m_bodyB;
		
		var c1:b2Vec2 = bA.m_sweep.c;
		var a1:Number = bA.m_sweep.a;
		
		var c2:b2Vec2 = bB.m_sweep.c;
		var a2:Number = bB.m_sweep.a;
		
		var tMat:b2Mat22;
		var tX:Number;
		
		var m1:Number;
		var m2:Number;
		var i1:Number;
		var i2:Number;
		
		// Solve linear limit constraint
		var linearError:Number = 0.0;
		var angularError:Number = 0.0;
		var active:Boolean = false;
		var C2:Number = 0.0;
		
		var R1:b2Mat22 = b2Mat22.FromAngle(a1);
		var R2:b2Mat22 = b2Mat22.FromAngle(a2);
		
		//b2Vec2 r1 = b2Mul(R1, m_localAnchor1 - m_localCenterA);
		tMat = R1;
		var r1X:Number = m_localAnchor1.x - m_localCenterA.x;
		var r1Y:Number = m_localAnchor1.y - m_localCenterA.y;
		tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(R2, m_localAnchor2 - m_localCenterB);
		tMat = R2;
		var r2X:Number = m_localAnchor2.x - m_localCenterB.x;
		var r2Y:Number = m_localAnchor2.y - m_localCenterB.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		var dX:Number = c2.x + r2X - c1.x - r1X;
		var dY:Number = c2.y + r2Y - c1.y - r1Y;
		
		if (m_enableLimit)
		{
			m_axis = b2Math.MulMV(R1, m_localXAxis1);
			
			//m_a1 = b2Math.b2Cross(d + r1, m_axis);
			m_a1 = (dX + r1X) * m_axis.y - (dY + r1Y) * m_axis.x;
			//m_a2 = b2Math.b2Cross(r2, m_axis);
			m_a2 = r2X * m_axis.y - r2Y * m_axis.x;
			
			var translation:Number = m_axis.x * dX + m_axis.y * dY;
			if (b2Math.Abs(m_upperTranslation - m_lowerTranslation) < 2.0 * b2Settings.b2_linearSlop)
			{
				// Prevent large angular corrections.
				C2 = b2Math.Clamp(translation, -b2Settings.b2_maxLinearCorrection, b2Settings.b2_maxLinearCorrection);
				linearError = b2Math.Abs(translation);
				active = true;
			}
			else if (translation <= m_lowerTranslation)
			{
				// Prevent large angular corrections and allow some slop.
				C2 = b2Math.Clamp(translation - m_lowerTranslation + b2Settings.b2_linearSlop, -b2Settings.b2_maxLinearCorrection, 0.0);
				linearError = m_lowerTranslation - translation;
				active = true;
			}
			else if (translation >= m_upperTranslation)
			{
				// Prevent large angular corrections and allow some slop.
				C2 = b2Math.Clamp(translation - m_upperTranslation + b2Settings.b2_linearSlop, 0.0, b2Settings.b2_maxLinearCorrection);
				linearError = translation - m_upperTranslation;
				active = true;
			}
		}
		
		m_perp = b2Math.MulMV(R1, m_localYAxis1);
		
		//m_s1 = b2Cross(d + r1, m_perp); 
		m_s1 = (dX + r1X) * m_perp.y - (dY + r1Y) * m_perp.x;
		//m_s2 = b2Cross(r2, m_perp); 
		m_s2 = r2X * m_perp.y - r2Y * m_perp.x;
		
		var impulse:b2Vec3 = new b2Vec3();
		var C1X:Number = m_perp.x * dX + m_perp.y * dY;
		var C1Y:Number = a2 - a1 - m_refAngle;
		
		linearError = b2Math.Max(linearError, b2Math.Abs(C1X));
		angularError = b2Math.Abs(C1Y);
		
		if (active)
		{
			m1 = m_invMassA;
			m2 = m_invMassB;
			i1 = m_invIA;
			i2 = m_invIB;
			
			m_K.col1.x = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2;
 	  	  	m_K.col1.y = i1 * m_s1 + i2 * m_s2;
 	  	  	m_K.col1.z = i1 * m_s1 * m_a1 + i2 * m_s2 * m_a2;
			m_K.col2.x = m_K.col1.y;
 	  	  	m_K.col2.y = i1 + i2;
 	  	  	m_K.col2.z = i1 * m_a1 + i2 * m_a2;
			m_K.col3.x = m_K.col1.z;
			m_K.col3.y = m_K.col2.z;
 	  	  	m_K.col3.z = m1 + m2 + i1 * m_a1 * m_a1 + i2 * m_a2 * m_a2;
			
			m_K.Solve33(impulse, -C1X, -C1Y, -C2);
		}
		else
		{
			m1 = m_invMassA;
			m2 = m_invMassB;
			i1 = m_invIA;
			i2 = m_invIB;
			
			var k11:Number  = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2;
			var k12:Number = i1 * m_s1 + i2 * m_s2;
			var k22:Number = i1 + i2; 
			
			m_K.col1.Set(k11, k12, 0.0);
			m_K.col2.Set(k12, k22, 0.0);
			
			var impulse1:b2Vec2 = m_K.Solve22(new b2Vec2(), -C1X, -C1Y);
			impulse.x = impulse1.x;
			impulse.y = impulse1.y;
			impulse.z = 0.0;
		}
		
		var PX:Number = impulse.x * m_perp.x + impulse.z * m_axis.x;
		var PY:Number = impulse.x * m_perp.y + impulse.z * m_axis.y;
		var L1:Number = impulse.x * m_s1 + impulse.y + impulse.z * m_a1;
		var L2:Number = impulse.x * m_s2 + impulse.y + impulse.z * m_a2;
		
		c1.x -= m_invMassA * PX;
		c1.y -= m_invMassA * PY;
		a1 -= m_invIA * L1;
		
		c2.x += m_invMassB * PX;
		c2.y += m_invMassB * PY;
		a2 += m_invIB * L2;
		
		// TODO_ERIN remove need for this
		//bA.m_sweep.c = c1;	//Already done by reference
		bA.m_sweep.a = a1;
		//bB.m_sweep.c = c2;	//Already done by reference
		bB.m_sweep.a = a2;
		bA.SynchronizeTransform();
		bB.SynchronizeTransform(); 
		
		return linearError <= b2Settings.b2_linearSlop && angularError <= b2Settings.b2_angularSlop;
		
	}

	b2internal var m_localAnchor1:b2Vec2 = new b2Vec2();
	b2internal var m_localAnchor2:b2Vec2 = new b2Vec2();
	b2internal var m_localXAxis1:b2Vec2 = new b2Vec2();
	private var m_localYAxis1:b2Vec2 = new b2Vec2();
	private var m_refAngle:Number;

	private var m_axis:b2Vec2 = new b2Vec2();
	private var m_perp:b2Vec2 = new b2Vec2();
	private var m_s1:Number;
	private var m_s2:Number;
	private var m_a1:Number;
	private var m_a2:Number;
	
	private var m_K:b2Mat33 = new b2Mat33();
	private var m_impulse:b2Vec3 = new b2Vec3();

	private var m_motorMass:Number;			// effective mass for motor/limit translational constraint.
	private var m_motorImpulse:Number;

	private var m_lowerTranslation:Number;
	private var m_upperTranslation:Number;
	private var m_maxMotorForce:Number;
	private var m_motorSpeed:Number;
	
	private var m_enableLimit:Boolean;
	private var m_enableMotor:Boolean;
	private var m_limitState:int;
};

}
