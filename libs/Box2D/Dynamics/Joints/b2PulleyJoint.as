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

package Box2D.Dynamics.Joints {

	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	
	
	
use namespace b2internal;

	
/**
* The pulley joint is connected to two bodies and two fixed ground points.
* The pulley supports a ratio such that:
* length1 + ratio * length2 <= constant
* Yes, the force transmitted is scaled by the ratio.
* The pulley also enforces a maximum length limit on both sides. This is
* useful to prevent one side of the pulley hitting the top.
* @see b2PulleyJointDef
*/
public class b2PulleyJoint extends b2Joint
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
	public override function GetReactionForce(inv_dt:Number) :b2Vec2
	{
		//b2Vec2 P = m_impulse * m_u2;
		//return inv_dt * P;
		return new b2Vec2(inv_dt * m_impulse * m_u2.x, inv_dt * m_impulse * m_u2.y);
	}

	/** @inheritDoc */
	public override function GetReactionTorque(inv_dt:Number) :Number
	{
		//B2_NOT_USED(inv_dt);
		return 0.0;
	}

	/**
	 * Get the first ground anchor.
	 */
	public function GetGroundAnchorA() :b2Vec2
	{
		//return m_ground.m_xf.position + m_groundAnchor1;
		var a:b2Vec2 = m_ground.m_xf.position.Copy();
		a.Add(m_groundAnchor1);
		return a;
	}

	/**
	 * Get the second ground anchor.
	 */
	public function GetGroundAnchorB() :b2Vec2
	{
		//return m_ground.m_xf.position + m_groundAnchor2;
		var a:b2Vec2 = m_ground.m_xf.position.Copy();
		a.Add(m_groundAnchor2);
		return a;
	}

	/**
	 * Get the current length of the segment attached to body1.
	 */
	public function GetLength1() :Number
	{
		var p:b2Vec2 = m_bodyA.GetWorldPoint(m_localAnchor1);
		//b2Vec2 s = m_ground->m_xf.position + m_groundAnchor1;
		var sX:Number = m_ground.m_xf.position.x + m_groundAnchor1.x;
		var sY:Number = m_ground.m_xf.position.y + m_groundAnchor1.y;
		//b2Vec2 d = p - s;
		var dX:Number = p.x - sX;
		var dY:Number = p.y - sY;
		//return d.Length();
		return Math.sqrt(dX*dX + dY*dY);
	}

	/**
	 * Get the current length of the segment attached to body2.
	 */
	public function GetLength2() :Number
	{
		var p:b2Vec2 = m_bodyB.GetWorldPoint(m_localAnchor2);
		//b2Vec2 s = m_ground->m_xf.position + m_groundAnchor2;
		var sX:Number = m_ground.m_xf.position.x + m_groundAnchor2.x;
		var sY:Number = m_ground.m_xf.position.y + m_groundAnchor2.y;
		//b2Vec2 d = p - s;
		var dX:Number = p.x - sX;
		var dY:Number = p.y - sY;
		//return d.Length();
		return Math.sqrt(dX*dX + dY*dY);
	}

	/**
	 * Get the pulley ratio.
	 */
	public function GetRatio():Number{
		return m_ratio;
	}

	//--------------- Internals Below -------------------

	/** @private */
	public function b2PulleyJoint(def:b2PulleyJointDef){
		
		// parent
		super(def);
		
		var tMat:b2Mat22;
		var tX:Number;
		var tY:Number;
		
		m_ground = m_bodyA.m_world.m_groundBody;
		//m_groundAnchor1 = def->groundAnchorA - m_ground->m_xf.position;
		m_groundAnchor1.x = def.groundAnchorA.x - m_ground.m_xf.position.x;
		m_groundAnchor1.y = def.groundAnchorA.y - m_ground.m_xf.position.y;
		//m_groundAnchor2 = def->groundAnchorB - m_ground->m_xf.position;
		m_groundAnchor2.x = def.groundAnchorB.x - m_ground.m_xf.position.x;
		m_groundAnchor2.y = def.groundAnchorB.y - m_ground.m_xf.position.y;
		//m_localAnchor1 = def->localAnchorA;
		m_localAnchor1.SetV(def.localAnchorA);
		//m_localAnchor2 = def->localAnchorB;
		m_localAnchor2.SetV(def.localAnchorB);
		
		//b2Settings.b2Assert(def.ratio != 0.0);
		m_ratio = def.ratio;
		
		m_constant = def.lengthA + m_ratio * def.lengthB;
		
		m_maxLength1 = b2Math.Min(def.maxLengthA, m_constant - m_ratio * b2_minPulleyLength);
		m_maxLength2 = b2Math.Min(def.maxLengthB, (m_constant - b2_minPulleyLength) / m_ratio);
		
		m_impulse = 0.0;
		m_limitImpulse1 = 0.0;
		m_limitImpulse2 = 0.0;
		
	}

	b2internal override function InitVelocityConstraints(step:b2TimeStep) : void{
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
		
		//b2Vec2 s1 = m_ground->m_xf.position + m_groundAnchor1;
		var s1X:Number = m_ground.m_xf.position.x + m_groundAnchor1.x;
		var s1Y:Number = m_ground.m_xf.position.y + m_groundAnchor1.y;
		//b2Vec2 s2 = m_ground->m_xf.position + m_groundAnchor2;
		var s2X:Number = m_ground.m_xf.position.x + m_groundAnchor2.x;
		var s2Y:Number = m_ground.m_xf.position.y + m_groundAnchor2.y;
		
		// Get the pulley axes.
		//m_u1 = p1 - s1;
		m_u1.Set(p1X - s1X, p1Y - s1Y);
		//m_u2 = p2 - s2;
		m_u2.Set(p2X - s2X, p2Y - s2Y);
		
		var length1:Number = m_u1.Length();
		var length2:Number = m_u2.Length();
		
		if (length1 > b2Settings.b2_linearSlop)
		{
			//m_u1 *= 1.0f / length1;
			m_u1.Multiply(1.0 / length1);
		}
		else
		{
			m_u1.SetZero();
		}
		
		if (length2 > b2Settings.b2_linearSlop)
		{
			//m_u2 *= 1.0f / length2;
			m_u2.Multiply(1.0 / length2);
		}
		else
		{
			m_u2.SetZero();
		}
		
		var C:Number = m_constant - length1 - m_ratio * length2;
		if (C > 0.0)
		{
			m_state = e_inactiveLimit;
			m_impulse = 0.0;
		}
		else
		{
			m_state = e_atUpperLimit;
		}
		
		if (length1 < m_maxLength1)
		{
			m_limitState1 = e_inactiveLimit;
			m_limitImpulse1 = 0.0;
		}
		else
		{
			m_limitState1 = e_atUpperLimit;
		}
		
		if (length2 < m_maxLength2)
		{
			m_limitState2 = e_inactiveLimit;
			m_limitImpulse2 = 0.0;
		}
		else
		{
			m_limitState2 = e_atUpperLimit;
		}
		
		// Compute effective mass.
		//var cr1u1:Number = b2Cross(r1, m_u1);
		var cr1u1:Number = r1X * m_u1.y - r1Y * m_u1.x;
		//var cr2u2:Number = b2Cross(r2, m_u2);
		var cr2u2:Number = r2X * m_u2.y - r2Y * m_u2.x;
		
		m_limitMass1 = bA.m_invMass + bA.m_invI * cr1u1 * cr1u1;
		m_limitMass2 = bB.m_invMass + bB.m_invI * cr2u2 * cr2u2;
		m_pulleyMass = m_limitMass1 + m_ratio * m_ratio * m_limitMass2;
		//b2Settings.b2Assert(m_limitMass1 > Number.MIN_VALUE);
		//b2Settings.b2Assert(m_limitMass2 > Number.MIN_VALUE);
		//b2Settings.b2Assert(m_pulleyMass > Number.MIN_VALUE);
		m_limitMass1 = 1.0 / m_limitMass1;
		m_limitMass2 = 1.0 / m_limitMass2;
		m_pulleyMass = 1.0 / m_pulleyMass;
		
		if (step.warmStarting)
		{
			// Scale impulses to support variable time steps.
			m_impulse *= step.dtRatio;
			m_limitImpulse1 *= step.dtRatio;
			m_limitImpulse2 *= step.dtRatio;
			
			// Warm starting.
			//b2Vec2 P1 = (-m_impulse - m_limitImpulse1) * m_u1;
			var P1X:Number = (-m_impulse - m_limitImpulse1) * m_u1.x;
			var P1Y:Number = (-m_impulse - m_limitImpulse1) * m_u1.y;
			//b2Vec2 P2 = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2;
			var P2X:Number = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2.x;
			var P2Y:Number = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2.y;
			//bA.m_linearVelocity += bA.m_invMass * P1;
			bA.m_linearVelocity.x += bA.m_invMass * P1X;
			bA.m_linearVelocity.y += bA.m_invMass * P1Y;
			//bA.m_angularVelocity += bA.m_invI * b2Cross(r1, P1);
			bA.m_angularVelocity += bA.m_invI * (r1X * P1Y - r1Y * P1X);
			//bB.m_linearVelocity += bB.m_invMass * P2;
			bB.m_linearVelocity.x += bB.m_invMass * P2X;
			bB.m_linearVelocity.y += bB.m_invMass * P2Y;
			//bB.m_angularVelocity += bB.m_invI * b2Cross(r2, P2);
			bB.m_angularVelocity += bB.m_invI * (r2X * P2Y - r2Y * P2X);
		}
		else
		{
			m_impulse = 0.0;
			m_limitImpulse1 = 0.0;
			m_limitImpulse2 = 0.0;
		}
	}
	
	b2internal override function SolveVelocityConstraints(step:b2TimeStep) : void 
	{
		//B2_NOT_USED(step)
		
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
		
		// temp vars
		var v1X:Number;
		var v1Y:Number;
		var v2X:Number;
		var v2Y:Number;
		var P1X:Number;
		var P1Y:Number;
		var P2X:Number;
		var P2Y:Number;
		var Cdot:Number;
		var impulse:Number;
		var oldImpulse:Number;
		
		if (m_state == e_atUpperLimit)
		{
			//b2Vec2 v1 = bA->m_linearVelocity + b2Cross(bA->m_angularVelocity, r1);
			v1X = bA.m_linearVelocity.x + (-bA.m_angularVelocity * r1Y);
			v1Y = bA.m_linearVelocity.y + (bA.m_angularVelocity * r1X);
			//b2Vec2 v2 = bB->m_linearVelocity + b2Cross(bB->m_angularVelocity, r2);
			v2X = bB.m_linearVelocity.x + (-bB.m_angularVelocity * r2Y);
			v2Y = bB.m_linearVelocity.y + (bB.m_angularVelocity * r2X);
			
			//Cdot = -b2Dot(m_u1, v1) - m_ratio * b2Dot(m_u2, v2);
			Cdot = -(m_u1.x * v1X + m_u1.y * v1Y) - m_ratio * (m_u2.x * v2X + m_u2.y * v2Y);
			impulse = m_pulleyMass * (-Cdot);
			oldImpulse = m_impulse;
			m_impulse = b2Math.Max(0.0, m_impulse + impulse);
			impulse = m_impulse - oldImpulse;
			
			//b2Vec2 P1 = -impulse * m_u1;
			P1X = -impulse * m_u1.x;
			P1Y = -impulse * m_u1.y;
			//b2Vec2 P2 = - m_ratio * impulse * m_u2;
			P2X = -m_ratio * impulse * m_u2.x;
			P2Y = -m_ratio * impulse * m_u2.y;
			//bA.m_linearVelocity += bA.m_invMass * P1;
			bA.m_linearVelocity.x += bA.m_invMass * P1X;
			bA.m_linearVelocity.y += bA.m_invMass * P1Y;
			//bA.m_angularVelocity += bA.m_invI * b2Cross(r1, P1);
			bA.m_angularVelocity += bA.m_invI * (r1X * P1Y - r1Y * P1X);
			//bB.m_linearVelocity += bB.m_invMass * P2;
			bB.m_linearVelocity.x += bB.m_invMass * P2X;
			bB.m_linearVelocity.y += bB.m_invMass * P2Y;
			//bB.m_angularVelocity += bB.m_invI * b2Cross(r2, P2);
			bB.m_angularVelocity += bB.m_invI * (r2X * P2Y - r2Y * P2X);
		}
		
		if (m_limitState1 == e_atUpperLimit)
		{
			//b2Vec2 v1 = bA->m_linearVelocity + b2Cross(bA->m_angularVelocity, r1);
			v1X = bA.m_linearVelocity.x + (-bA.m_angularVelocity * r1Y);
			v1Y = bA.m_linearVelocity.y + (bA.m_angularVelocity * r1X);
			
			//float32 Cdot = -b2Dot(m_u1, v1);
			Cdot = -(m_u1.x * v1X + m_u1.y * v1Y);
			impulse = -m_limitMass1 * Cdot;
			oldImpulse = m_limitImpulse1;
			m_limitImpulse1 = b2Math.Max(0.0, m_limitImpulse1 + impulse);
			impulse = m_limitImpulse1 - oldImpulse;
			
			//b2Vec2 P1 = -impulse * m_u1;
			P1X = -impulse * m_u1.x;
			P1Y = -impulse * m_u1.y;
			//bA.m_linearVelocity += bA->m_invMass * P1;
			bA.m_linearVelocity.x += bA.m_invMass * P1X;
			bA.m_linearVelocity.y += bA.m_invMass * P1Y;
			//bA.m_angularVelocity += bA->m_invI * b2Cross(r1, P1);
			bA.m_angularVelocity += bA.m_invI * (r1X * P1Y - r1Y * P1X);
		}
		
		if (m_limitState2 == e_atUpperLimit)
		{
			//b2Vec2 v2 = bB->m_linearVelocity + b2Cross(bB->m_angularVelocity, r2);
			v2X = bB.m_linearVelocity.x + (-bB.m_angularVelocity * r2Y);
			v2Y = bB.m_linearVelocity.y + (bB.m_angularVelocity * r2X);
			
			//float32 Cdot = -b2Dot(m_u2, v2);
			Cdot = -(m_u2.x * v2X + m_u2.y * v2Y);
			impulse = -m_limitMass2 * Cdot;
			oldImpulse = m_limitImpulse2;
			m_limitImpulse2 = b2Math.Max(0.0, m_limitImpulse2 + impulse);
			impulse = m_limitImpulse2 - oldImpulse;
			
			//b2Vec2 P2 = -impulse * m_u2;
			P2X = -impulse * m_u2.x;
			P2Y = -impulse * m_u2.y;
			//bB->m_linearVelocity += bB->m_invMass * P2;
			bB.m_linearVelocity.x += bB.m_invMass * P2X;
			bB.m_linearVelocity.y += bB.m_invMass * P2Y;
			//bB->m_angularVelocity += bB->m_invI * b2Cross(r2, P2);
			bB.m_angularVelocity += bB.m_invI * (r2X * P2Y - r2Y * P2X);
		}
	}
	
	b2internal override function SolvePositionConstraints(baumgarte:Number):Boolean 
	{
		//B2_NOT_USED(baumgarte)
		
		var bA:b2Body = m_bodyA;
		var bB:b2Body = m_bodyB;
		
		var tMat:b2Mat22;
		
		//b2Vec2 s1 = m_ground->m_xf.position + m_groundAnchor1;
		var s1X:Number = m_ground.m_xf.position.x + m_groundAnchor1.x;
		var s1Y:Number = m_ground.m_xf.position.y + m_groundAnchor1.y;
		//b2Vec2 s2 = m_ground->m_xf.position + m_groundAnchor2;
		var s2X:Number = m_ground.m_xf.position.x + m_groundAnchor2.x;
		var s2Y:Number = m_ground.m_xf.position.y + m_groundAnchor2.y;
		
		// temp vars
		var r1X:Number;
		var r1Y:Number;
		var r2X:Number;
		var r2Y:Number;
		var p1X:Number;
		var p1Y:Number;
		var p2X:Number;
		var p2Y:Number;
		var length1:Number;
		var length2:Number;
		var C:Number;
		var impulse:Number;
		var oldImpulse:Number;
		var oldLimitPositionImpulse:Number;
		
		var tX:Number;
		
		var linearError:Number = 0.0;
		
		if (m_state == e_atUpperLimit)
		{
			//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
			tMat = bA.m_xf.R;
			r1X = m_localAnchor1.x - bA.m_sweep.localCenter.x;
			r1Y = m_localAnchor1.y - bA.m_sweep.localCenter.y;
			tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
			r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
			r1X = tX;
			//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
			tMat = bB.m_xf.R;
			r2X = m_localAnchor2.x - bB.m_sweep.localCenter.x;
			r2Y = m_localAnchor2.y - bB.m_sweep.localCenter.y;
			tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
			r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
			r2X = tX;
			
			//b2Vec2 p1 = bA->m_sweep.c + r1;
			p1X = bA.m_sweep.c.x + r1X;
			p1Y = bA.m_sweep.c.y + r1Y;
			//b2Vec2 p2 = bB->m_sweep.c + r2;
			p2X = bB.m_sweep.c.x + r2X;
			p2Y = bB.m_sweep.c.y + r2Y;
			
			// Get the pulley axes.
			//m_u1 = p1 - s1;
			m_u1.Set(p1X - s1X, p1Y - s1Y);
			//m_u2 = p2 - s2;
			m_u2.Set(p2X - s2X, p2Y - s2Y);
			
			length1 = m_u1.Length();
			length2 = m_u2.Length();
			
			if (length1 > b2Settings.b2_linearSlop)
			{
				//m_u1 *= 1.0f / length1;
				m_u1.Multiply( 1.0 / length1 );
			}
			else
			{
				m_u1.SetZero();
			}
			
			if (length2 > b2Settings.b2_linearSlop)
			{
				//m_u2 *= 1.0f / length2;
				m_u2.Multiply( 1.0 / length2 );
			}
			else
			{
				m_u2.SetZero();
			}
			
			C = m_constant - length1 - m_ratio * length2;
			linearError = b2Math.Max(linearError, -C);
			C = b2Math.Clamp(C + b2Settings.b2_linearSlop, -b2Settings.b2_maxLinearCorrection, 0.0);
			impulse = -m_pulleyMass * C;
			
			p1X = -impulse * m_u1.x;
			p1Y = -impulse * m_u1.y;
			p2X = -m_ratio * impulse * m_u2.x;
			p2Y = -m_ratio * impulse * m_u2.y;
			
			bA.m_sweep.c.x += bA.m_invMass * p1X;
			bA.m_sweep.c.y += bA.m_invMass * p1Y;
			bA.m_sweep.a += bA.m_invI * (r1X * p1Y - r1Y * p1X);
			bB.m_sweep.c.x += bB.m_invMass * p2X;
			bB.m_sweep.c.y += bB.m_invMass * p2Y;
			bB.m_sweep.a += bB.m_invI * (r2X * p2Y - r2Y * p2X);
			
			bA.SynchronizeTransform();
			bB.SynchronizeTransform();
		}
		
		if (m_limitState1 == e_atUpperLimit)
		{
			//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
			tMat = bA.m_xf.R;
			r1X = m_localAnchor1.x - bA.m_sweep.localCenter.x;
			r1Y = m_localAnchor1.y - bA.m_sweep.localCenter.y;
			tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
			r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
			r1X = tX;
			//b2Vec2 p1 = bA->m_sweep.c + r1;
			p1X = bA.m_sweep.c.x + r1X;
			p1Y = bA.m_sweep.c.y + r1Y;
			
			//m_u1 = p1 - s1;
			m_u1.Set(p1X - s1X, p1Y - s1Y);
			
			length1 = m_u1.Length();
			
			if (length1 > b2Settings.b2_linearSlop)
			{
				//m_u1 *= 1.0 / length1;
				m_u1.x *= 1.0 / length1;
				m_u1.y *= 1.0 / length1;
			}
			else
			{
				m_u1.SetZero();
			}
			
			C = m_maxLength1 - length1;
			linearError = b2Math.Max(linearError, -C);
			C = b2Math.Clamp(C + b2Settings.b2_linearSlop, -b2Settings.b2_maxLinearCorrection, 0.0);
			impulse = -m_limitMass1 * C;
			
			//P1 = -impulse * m_u1;
			p1X = -impulse * m_u1.x;
			p1Y = -impulse * m_u1.y;
			
			bA.m_sweep.c.x += bA.m_invMass * p1X;
			bA.m_sweep.c.y += bA.m_invMass * p1Y;
			//bA.m_rotation += bA.m_invI * b2Cross(r1, P1);
			bA.m_sweep.a += bA.m_invI * (r1X * p1Y - r1Y * p1X);
			
			bA.SynchronizeTransform();
		}
		
		if (m_limitState2 == e_atUpperLimit)
		{
			//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
			tMat = bB.m_xf.R;
			r2X = m_localAnchor2.x - bB.m_sweep.localCenter.x;
			r2Y = m_localAnchor2.y - bB.m_sweep.localCenter.y;
			tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
			r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
			r2X = tX;
			//b2Vec2 p2 = bB->m_position + r2;
			p2X = bB.m_sweep.c.x + r2X;
			p2Y = bB.m_sweep.c.y + r2Y;
			
			//m_u2 = p2 - s2;
			m_u2.Set(p2X - s2X, p2Y - s2Y);
			
			length2 = m_u2.Length();
			
			if (length2 > b2Settings.b2_linearSlop)
			{
				//m_u2 *= 1.0 / length2;
				m_u2.x *= 1.0 / length2;
				m_u2.y *= 1.0 / length2;
			}
			else
			{
				m_u2.SetZero();
			}
			
			C = m_maxLength2 - length2;
			linearError = b2Math.Max(linearError, -C);
			C = b2Math.Clamp(C + b2Settings.b2_linearSlop, -b2Settings.b2_maxLinearCorrection, 0.0);
			impulse = -m_limitMass2 * C;
			
			//P2 = -impulse * m_u2;
			p2X = -impulse * m_u2.x;
			p2Y = -impulse * m_u2.y;
			
			//bB.m_sweep.c += bB.m_invMass * P2;
			bB.m_sweep.c.x += bB.m_invMass * p2X;
			bB.m_sweep.c.y += bB.m_invMass * p2Y;
			//bB.m_sweep.a += bB.m_invI * b2Cross(r2, P2);
			bB.m_sweep.a += bB.m_invI * (r2X * p2Y - r2Y * p2X);
			
			bB.SynchronizeTransform();
		}
		
		return linearError < b2Settings.b2_linearSlop;
	}
	
	

	private var m_ground:b2Body;
	private var m_groundAnchor1:b2Vec2 = new b2Vec2();
	private var m_groundAnchor2:b2Vec2 = new b2Vec2();
	private var m_localAnchor1:b2Vec2 = new b2Vec2();
	private var m_localAnchor2:b2Vec2 = new b2Vec2();

	private var m_u1:b2Vec2 = new b2Vec2();
	private var m_u2:b2Vec2 = new b2Vec2();
	
	private var m_constant:Number;
	private var m_ratio:Number;
	
	private var m_maxLength1:Number;
	private var m_maxLength2:Number;

	// Effective masses
	private var m_pulleyMass:Number;
	private var m_limitMass1:Number;
	private var m_limitMass2:Number;

	// Impulses for accumulation/warm starting.
	private var m_impulse:Number;
	private var m_limitImpulse1:Number;
	private var m_limitImpulse2:Number;

	private var m_state:int;
	private var m_limitState1:int;
	private var m_limitState2:int;
	
	// static
	static b2internal const b2_minPulleyLength:Number = 2.0;
};
	
	
}