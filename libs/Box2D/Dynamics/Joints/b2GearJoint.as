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
* A gear joint is used to connect two joints together. Either joint
* can be a revolute or prismatic joint. You specify a gear ratio
* to bind the motions together:
* coordinate1 + ratio * coordinate2 = constant
* The ratio can be negative or positive. If one joint is a revolute joint
* and the other joint is a prismatic joint, then the ratio will have units
* of length or units of 1/length.
* @warning The revolute and prismatic joints must be attached to
* fixed bodies (which must be body1 on those joints).
* @see b2GearJointDef
*/

public class b2GearJoint extends b2Joint
{
	/** @inheritDoc */
	public override function GetAnchorA():b2Vec2{
		//return m_bodyA->GetWorldPoint(m_localAnchor1);
		return m_bodyA.GetWorldPoint(m_localAnchor1);
	}
	/** @inheritDoc */
	public override function GetAnchorB():b2Vec2{
		//return m_bodyB->GetWorldPoint(m_localAnchor2);
		return m_bodyB.GetWorldPoint(m_localAnchor2);
	}
	/** @inheritDoc */
	public override function GetReactionForce(inv_dt:Number):b2Vec2{
		// TODO_ERIN not tested
		// b2Vec2 P = m_impulse * m_J.linear2;
		//return inv_dt * P;
		return new b2Vec2(inv_dt * m_impulse * m_J.linearB.x, inv_dt * m_impulse * m_J.linearB.y);
	}
	/** @inheritDoc */
	public override function GetReactionTorque(inv_dt:Number):Number{
		// TODO_ERIN not tested
		//b2Vec2 r = b2Mul(m_bodyB->m_xf.R, m_localAnchor2 - m_bodyB->GetLocalCenter());
		var tMat:b2Mat22 = m_bodyB.m_xf.R;
		var rX:Number = m_localAnchor1.x - m_bodyB.m_sweep.localCenter.x;
		var rY:Number = m_localAnchor1.y - m_bodyB.m_sweep.localCenter.y;
		var tX:Number = tMat.col1.x * rX + tMat.col2.x * rY;
		rY = tMat.col1.y * rX + tMat.col2.y * rY;
		rX = tX;
		//b2Vec2 P = m_impulse * m_J.linearB;
		var PX:Number = m_impulse * m_J.linearB.x;
		var PY:Number = m_impulse * m_J.linearB.y;
		//float32 L = m_impulse * m_J.angularB - b2Cross(r, P);
		//return inv_dt * L;
		return inv_dt * (m_impulse * m_J.angularB - rX * PY + rY * PX);
	}

	/**
	 * Get the gear ratio.
	 */
	public function GetRatio():Number{
		return m_ratio;
	}
	
	/**
	 * Set the gear ratio.
	 */
	public function SetRatio(ratio:Number):void {
		//b2Settings.b2Assert(b2Math.b2IsValid(ratio));
		m_ratio = ratio;
	}

	//--------------- Internals Below -------------------

	/** @private */
	public function b2GearJoint(def:b2GearJointDef){
		// parent constructor
		super(def);
		
		var type1:int = def.joint1.m_type;
		var type2:int = def.joint2.m_type;
		
		//b2Settings.b2Assert(type1 == b2Joint.e_revoluteJoint || type1 == b2Joint.e_prismaticJoint);
		//b2Settings.b2Assert(type2 == b2Joint.e_revoluteJoint || type2 == b2Joint.e_prismaticJoint);
		//b2Settings.b2Assert(def.joint1.GetBodyA().GetType() == b2Body.b2_staticBody);
		//b2Settings.b2Assert(def.joint2.GetBodyA().GetType() == b2Body.b2_staticBody);
		
		m_revolute1 = null;
		m_prismatic1 = null;
		m_revolute2 = null;
		m_prismatic2 = null;
		
		var coordinate1:Number;
		var coordinate2:Number;
		
		m_ground1 = def.joint1.GetBodyA();
		m_bodyA = def.joint1.GetBodyB();
		if (type1 == b2Joint.e_revoluteJoint)
		{
			m_revolute1 = def.joint1 as b2RevoluteJoint;
			m_groundAnchor1.SetV( m_revolute1.m_localAnchor1 );
			m_localAnchor1.SetV( m_revolute1.m_localAnchor2 );
			coordinate1 = m_revolute1.GetJointAngle();
		}
		else
		{
			m_prismatic1 = def.joint1 as b2PrismaticJoint;
			m_groundAnchor1.SetV( m_prismatic1.m_localAnchor1 );
			m_localAnchor1.SetV( m_prismatic1.m_localAnchor2 );
			coordinate1 = m_prismatic1.GetJointTranslation();
		}
		
		m_ground2 = def.joint2.GetBodyA();
		m_bodyB = def.joint2.GetBodyB();
		if (type2 == b2Joint.e_revoluteJoint)
		{
			m_revolute2 = def.joint2 as b2RevoluteJoint;
			m_groundAnchor2.SetV( m_revolute2.m_localAnchor1 );
			m_localAnchor2.SetV( m_revolute2.m_localAnchor2 );
			coordinate2 = m_revolute2.GetJointAngle();
		}
		else
		{
			m_prismatic2 = def.joint2 as b2PrismaticJoint;
			m_groundAnchor2.SetV( m_prismatic2.m_localAnchor1 );
			m_localAnchor2.SetV( m_prismatic2.m_localAnchor2 );
			coordinate2 = m_prismatic2.GetJointTranslation();
		}
		
		m_ratio = def.ratio;
		
		m_constant = coordinate1 + m_ratio * coordinate2;
		
		m_impulse = 0.0;
		
	}

	b2internal override function InitVelocityConstraints(step:b2TimeStep) : void{
		var g1:b2Body = m_ground1;
		var g2:b2Body = m_ground2;
		var bA:b2Body = m_bodyA;
		var bB:b2Body = m_bodyB;
		
		// temp vars
		var ugX:Number;
		var ugY:Number;
		var rX:Number;
		var rY:Number;
		var tMat:b2Mat22;
		var tVec:b2Vec2;
		var crug:Number;
		var tX:Number;
		
		var K:Number = 0.0;
		m_J.SetZero();
		
		if (m_revolute1)
		{
			m_J.angularA = -1.0;
			K += bA.m_invI;
		}
		else
		{
			//b2Vec2 ug = b2MulMV(g1->m_xf.R, m_prismatic1->m_localXAxis1);
			tMat = g1.m_xf.R;
			tVec = m_prismatic1.m_localXAxis1;
			ugX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
			ugY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
			//b2Vec2 r = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
			tMat = bA.m_xf.R;
			rX = m_localAnchor1.x - bA.m_sweep.localCenter.x;
			rY = m_localAnchor1.y - bA.m_sweep.localCenter.y;
			tX = tMat.col1.x * rX + tMat.col2.x * rY;
			rY = tMat.col1.y * rX + tMat.col2.y * rY;
			rX = tX;
			
			//var crug:Number = b2Cross(r, ug);
			crug = rX * ugY - rY * ugX;
			//m_J.linearA = -ug;
			m_J.linearA.Set(-ugX, -ugY);
			m_J.angularA = -crug;
			K += bA.m_invMass + bA.m_invI * crug * crug;
		}
		
		if (m_revolute2)
		{
			m_J.angularB = -m_ratio;
			K += m_ratio * m_ratio * bB.m_invI;
		}
		else
		{
			//b2Vec2 ug = b2Mul(g2->m_xf.R, m_prismatic2->m_localXAxis1);
			tMat = g2.m_xf.R;
			tVec = m_prismatic2.m_localXAxis1;
			ugX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
			ugY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
			//b2Vec2 r = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
			tMat = bB.m_xf.R;
			rX = m_localAnchor2.x - bB.m_sweep.localCenter.x;
			rY = m_localAnchor2.y - bB.m_sweep.localCenter.y;
			tX = tMat.col1.x * rX + tMat.col2.x * rY;
			rY = tMat.col1.y * rX + tMat.col2.y * rY;
			rX = tX;
			
			//float32 crug = b2Cross(r, ug);
			crug = rX * ugY - rY * ugX;
			//m_J.linearB = -m_ratio * ug;
			m_J.linearB.Set(-m_ratio*ugX, -m_ratio*ugY);
			m_J.angularB = -m_ratio * crug;
			K += m_ratio * m_ratio * (bB.m_invMass + bB.m_invI * crug * crug);
		}
		
		// Compute effective mass.
		m_mass = K > 0.0?1.0 / K:0.0;
		
		if (step.warmStarting)
		{
			// Warm starting.
			//bA.m_linearVelocity += bA.m_invMass * m_impulse * m_J.linearA;
			bA.m_linearVelocity.x += bA.m_invMass * m_impulse * m_J.linearA.x;
			bA.m_linearVelocity.y += bA.m_invMass * m_impulse * m_J.linearA.y;
			bA.m_angularVelocity += bA.m_invI * m_impulse * m_J.angularA;
			//bB.m_linearVelocity += bB.m_invMass * m_impulse * m_J.linearB;
			bB.m_linearVelocity.x += bB.m_invMass * m_impulse * m_J.linearB.x;
			bB.m_linearVelocity.y += bB.m_invMass * m_impulse * m_J.linearB.y;
			bB.m_angularVelocity += bB.m_invI * m_impulse * m_J.angularB;
		}
		else
		{
			m_impulse = 0.0;
		}
	}
	
	b2internal override function SolveVelocityConstraints(step:b2TimeStep): void
	{
		//B2_NOT_USED(step);
		
		var bA:b2Body = m_bodyA;
		var bB:b2Body = m_bodyB;
		
		var Cdot:Number = m_J.Compute(	bA.m_linearVelocity, bA.m_angularVelocity,
										bB.m_linearVelocity, bB.m_angularVelocity);
		
		var impulse:Number = - m_mass * Cdot;
		m_impulse += impulse;
		
		bA.m_linearVelocity.x += bA.m_invMass * impulse * m_J.linearA.x;
		bA.m_linearVelocity.y += bA.m_invMass * impulse * m_J.linearA.y;
		bA.m_angularVelocity  += bA.m_invI * impulse * m_J.angularA;
		bB.m_linearVelocity.x += bB.m_invMass * impulse * m_J.linearB.x;
		bB.m_linearVelocity.y += bB.m_invMass * impulse * m_J.linearB.y;
		bB.m_angularVelocity  += bB.m_invI * impulse * m_J.angularB;
	}
	
	b2internal override function SolvePositionConstraints(baumgarte:Number):Boolean
	{
		//B2_NOT_USED(baumgarte);
		
		var linearError:Number = 0.0;
		
		var bA:b2Body = m_bodyA;
		var bB:b2Body = m_bodyB;
		
		var coordinate1:Number;
		var coordinate2:Number;
		if (m_revolute1)
		{
			coordinate1 = m_revolute1.GetJointAngle();
		}
		else
		{
			coordinate1 = m_prismatic1.GetJointTranslation();
		}
		
		if (m_revolute2)
		{
			coordinate2 = m_revolute2.GetJointAngle();
		}
		else
		{
			coordinate2 = m_prismatic2.GetJointTranslation();
		}
		
		var C:Number = m_constant - (coordinate1 + m_ratio * coordinate2);
		
		var impulse:Number = -m_mass * C;
		
		bA.m_sweep.c.x += bA.m_invMass * impulse * m_J.linearA.x;
		bA.m_sweep.c.y += bA.m_invMass * impulse * m_J.linearA.y;
		bA.m_sweep.a += bA.m_invI * impulse * m_J.angularA;
		bB.m_sweep.c.x += bB.m_invMass * impulse * m_J.linearB.x;
		bB.m_sweep.c.y += bB.m_invMass * impulse * m_J.linearB.y;
		bB.m_sweep.a += bB.m_invI * impulse * m_J.angularB;
		
		bA.SynchronizeTransform();
		bB.SynchronizeTransform();
		
		// TODO_ERIN not implemented
		return linearError < b2Settings.b2_linearSlop;
	}

	private var m_ground1:b2Body;
	private var m_ground2:b2Body;

	// One of these is NULL.
	private var m_revolute1:b2RevoluteJoint;
	private var m_prismatic1:b2PrismaticJoint;

	// One of these is NULL.
	private var m_revolute2:b2RevoluteJoint;
	private var m_prismatic2:b2PrismaticJoint;

	private var m_groundAnchor1:b2Vec2 = new b2Vec2();
	private var m_groundAnchor2:b2Vec2 = new b2Vec2();

	private var m_localAnchor1:b2Vec2 = new b2Vec2();
	private var m_localAnchor2:b2Vec2 = new b2Vec2();

	private var m_J:b2Jacobian = new b2Jacobian();

	private var m_constant:Number;
	private var m_ratio:Number;

	// Effective mass
	private var m_mass:Number;

	// Impulse for accumulation/warm starting.
	private var m_impulse:Number;
};


}