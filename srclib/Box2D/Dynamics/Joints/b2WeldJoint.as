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

// Point-to-point constraint
// Cdot = v2 - v1
//      = v2 + cross(w2, r2) - v1 - cross(w1, r1)
// J = [-I -r1_skew I r2_skew ]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

// Angle constraint
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
// K = invI1 + invI2

/**
 * A weld joint essentially glues two bodies together. A weld joint may
 * distort somewhat because the island constraint solver is approximate.
 */
public class b2WeldJoint extends b2Joint
{
	/** @inheritDoc */
	public override function GetAnchorA():b2Vec2{
		return m_bodyA.GetWorldPoint(m_localAnchorA);
	}
	/** @inheritDoc */
	public override function GetAnchorB():b2Vec2{
		return m_bodyB.GetWorldPoint(m_localAnchorB);
	}
	
	/** @inheritDoc */
	public override function GetReactionForce(inv_dt:Number):b2Vec2
	{
		return new b2Vec2(inv_dt * m_impulse.x, inv_dt * m_impulse.y);
	}

	/** @inheritDoc */
	public override function GetReactionTorque(inv_dt:Number):Number
	{
		return inv_dt * m_impulse.z;
	}
	
	//--------------- Internals Below -------------------

	/** @private */
	public function b2WeldJoint(def:b2WeldJointDef){
		super(def);
		
		m_localAnchorA.SetV(def.localAnchorA);
		m_localAnchorB.SetV(def.localAnchorB);
		m_referenceAngle = def.referenceAngle;

		m_impulse.SetZero();
		m_mass = new b2Mat33();
	}

	b2internal override function InitVelocityConstraints(step:b2TimeStep) : void {
		var tMat:b2Mat22;
		var tX:Number;
		
		var bA:b2Body = m_bodyA;
		var bB:b2Body= m_bodyB;

		// Compute the effective mass matrix.
		//b2Vec2 rA = b2Mul(bA->m_xf.R, m_localAnchorA - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var rAX:Number = m_localAnchorA.x - bA.m_sweep.localCenter.x;
		var rAY:Number = m_localAnchorA.y - bA.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rAX + tMat.col2.x * rAY);
		rAY = (tMat.col1.y * rAX + tMat.col2.y * rAY);
		rAX = tX;
		//b2Vec2 rB = b2Mul(bB->m_xf.R, m_localAnchorB - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var rBX:Number = m_localAnchorB.x - bB.m_sweep.localCenter.x;
		var rBY:Number = m_localAnchorB.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rBX + tMat.col2.x * rBY);
		rBY = (tMat.col1.y * rBX + tMat.col2.y * rBY);
		rBX = tX;

		// J = [-I -r1_skew I r2_skew]
		//     [ 0       -1 0       1]
		// r_skew = [-ry; rx]

		// Matlab
		// K = [ mA+r1y^2*iA+mB+r2y^2*iB,  -r1y*iA*r1x-r2y*iB*r2x,          -r1y*iA-r2y*iB]
		//     [  -r1y*iA*r1x-r2y*iB*r2x, mA+r1x^2*iA+mB+r2x^2*iB,           r1x*iA+r2x*iB]
		//     [          -r1y*iA-r2y*iB,           r1x*iA+r2x*iB,                   iA+iB]

		var mA:Number = bA.m_invMass
		var mB:Number = bB.m_invMass;
		var iA:Number = bA.m_invI
		var iB:Number = bB.m_invI;
		
		m_mass.col1.x = mA + mB + rAY * rAY * iA + rBY * rBY * iB;
		m_mass.col2.x = -rAY * rAX * iA - rBY * rBX * iB;
		m_mass.col3.x = -rAY * iA - rBY * iB;
		m_mass.col1.y = m_mass.col2.x;
		m_mass.col2.y = mA + mB + rAX * rAX * iA + rBX * rBX * iB;
		m_mass.col3.y = rAX * iA + rBX * iB;
		m_mass.col1.z = m_mass.col3.x;
		m_mass.col2.z = m_mass.col3.y;
		m_mass.col3.z = iA + iB;
		
		if (step.warmStarting)
		{
			// Scale impulses to support a variable time step.
			m_impulse.x *= step.dtRatio;
			m_impulse.y *= step.dtRatio;
			m_impulse.z *= step.dtRatio;

			bA.m_linearVelocity.x -= mA * m_impulse.x;
			bA.m_linearVelocity.y -= mA * m_impulse.y;
			bA.m_angularVelocity -= iA * (rAX * m_impulse.y - rAY * m_impulse.x + m_impulse.z);

			bB.m_linearVelocity.x += mB * m_impulse.x;
			bB.m_linearVelocity.y += mB * m_impulse.y;
			bB.m_angularVelocity += iB * (rBX * m_impulse.y - rBY * m_impulse.x + m_impulse.z);
		}
		else
		{
			m_impulse.SetZero();
		}

	}
	
	
	
	b2internal override function SolveVelocityConstraints(step:b2TimeStep): void{
		//B2_NOT_USED(step);
		var tMat:b2Mat22;
		var tX:Number;

		var bA:b2Body = m_bodyA;
		var bB:b2Body= m_bodyB;

		var vA:b2Vec2 = bA.m_linearVelocity;
		var wA:Number = bA.m_angularVelocity;
		var vB:b2Vec2 = bB.m_linearVelocity;
		var wB:Number = bB.m_angularVelocity;

		var mA:Number = bA.m_invMass
		var mB:Number = bB.m_invMass;
		var iA:Number = bA.m_invI
		var iB:Number = bB.m_invI;

		//b2Vec2 rA = b2Mul(bA->m_xf.R, m_localAnchorA - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var rAX:Number = m_localAnchorA.x - bA.m_sweep.localCenter.x;
		var rAY:Number = m_localAnchorA.y - bA.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rAX + tMat.col2.x * rAY);
		rAY = (tMat.col1.y * rAX + tMat.col2.y * rAY);
		rAX = tX;
		//b2Vec2 rB = b2Mul(bB->m_xf.R, m_localAnchorB - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var rBX:Number = m_localAnchorB.x - bB.m_sweep.localCenter.x;
		var rBY:Number = m_localAnchorB.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rBX + tMat.col2.x * rBY);
		rBY = (tMat.col1.y * rBX + tMat.col2.y * rBY);
		rBX = tX;

		
		// Solve point-to-point constraint
		var Cdot1X:Number = vB.x - wB * rBY - vA.x + wA * rAY;
		var Cdot1Y:Number = vB.y + wB * rBX - vA.y - wA * rAX;
		var Cdot2:Number = wB - wA;
		var impulse:b2Vec3 = new b2Vec3();
		m_mass.Solve33(impulse, -Cdot1X, -Cdot1Y, -Cdot2);
		
		m_impulse.Add(impulse);
		
		vA.x -= mA * impulse.x;
		vA.y -= mA * impulse.y;
		wA -= iA * (rAX * impulse.y - rAY * impulse.x + impulse.z);

		vB.x += mB * impulse.x;
		vB.y += mB * impulse.y;
		wB += iB * (rBX * impulse.y - rBY * impulse.x + impulse.z);

		// References has made some sets unnecessary
		//bA->m_linearVelocity = vA;
		bA.m_angularVelocity = wA;
		//bB->m_linearVelocity = vB;
		bB.m_angularVelocity = wB;

	}
	
	b2internal override function SolvePositionConstraints(baumgarte:Number):Boolean
	{
		//B2_NOT_USED(baumgarte);
				var tMat:b2Mat22;
		var tX:Number;
		
		var bA:b2Body = m_bodyA;
		var bB:b2Body= m_bodyB;

		// Compute the effective mass matrix.
		//b2Vec2 rA = b2Mul(bA->m_xf.R, m_localAnchorA - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		var rAX:Number = m_localAnchorA.x - bA.m_sweep.localCenter.x;
		var rAY:Number = m_localAnchorA.y - bA.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rAX + tMat.col2.x * rAY);
		rAY = (tMat.col1.y * rAX + tMat.col2.y * rAY);
		rAX = tX;
		//b2Vec2 rB = b2Mul(bB->m_xf.R, m_localAnchorB - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		var rBX:Number = m_localAnchorB.x - bB.m_sweep.localCenter.x;
		var rBY:Number = m_localAnchorB.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rBX + tMat.col2.x * rBY);
		rBY = (tMat.col1.y * rBX + tMat.col2.y * rBY);
		rBX = tX;

		// J = [-I -r1_skew I r2_skew]
		//     [ 0       -1 0       1]
		// r_skew = [-ry; rx]

		// Matlab
		// K = [ mA+r1y^2*iA+mB+r2y^2*iB,  -r1y*iA*r1x-r2y*iB*r2x,          -r1y*iA-r2y*iB]
		//     [  -r1y*iA*r1x-r2y*iB*r2x, mA+r1x^2*iA+mB+r2x^2*iB,           r1x*iA+r2x*iB]
		//     [          -r1y*iA-r2y*iB,           r1x*iA+r2x*iB,                   iA+iB]

		var mA:Number = bA.m_invMass
		var mB:Number = bB.m_invMass;
		var iA:Number = bA.m_invI
		var iB:Number = bB.m_invI;
		
		//b2Vec2 C1 =  bB->m_sweep.c + rB - bA->m_sweep.c - rA;
		var C1X:Number =  bB.m_sweep.c.x + rBX - bA.m_sweep.c.x - rAX;
		var C1Y:Number =  bB.m_sweep.c.y + rBY - bA.m_sweep.c.y - rAY;
		var C2:Number = bB.m_sweep.a - bA.m_sweep.a - m_referenceAngle;

		// Handle large detachment.
		var k_allowedStretch:Number = 10.0 * b2Settings.b2_linearSlop;
		var positionError:Number = Math.sqrt(C1X * C1X + C1Y * C1Y);
		var angularError:Number = b2Math.Abs(C2);
		if (positionError > k_allowedStretch)
		{
			iA *= 1.0;
			iB *= 1.0;
		}
		
		m_mass.col1.x = mA + mB + rAY * rAY * iA + rBY * rBY * iB;
		m_mass.col2.x = -rAY * rAX * iA - rBY * rBX * iB;
		m_mass.col3.x = -rAY * iA - rBY * iB;
		m_mass.col1.y = m_mass.col2.x;
		m_mass.col2.y = mA + mB + rAX * rAX * iA + rBX * rBX * iB;
		m_mass.col3.y = rAX * iA + rBX * iB;
		m_mass.col1.z = m_mass.col3.x;
		m_mass.col2.z = m_mass.col3.y;
		m_mass.col3.z = iA + iB;
		
		var impulse:b2Vec3 = new b2Vec3();
		m_mass.Solve33(impulse, -C1X, -C1Y, -C2);
		

		bA.m_sweep.c.x -= mA * impulse.x;
		bA.m_sweep.c.y -= mA * impulse.y;
		bA.m_sweep.a -= iA * (rAX * impulse.y - rAY * impulse.x + impulse.z);

		bB.m_sweep.c.x += mB * impulse.x;
		bB.m_sweep.c.y += mB * impulse.y;
		bB.m_sweep.a += iB * (rBX * impulse.y - rBY * impulse.x + impulse.z);

		bA.SynchronizeTransform();
		bB.SynchronizeTransform();

		return positionError <= b2Settings.b2_linearSlop && angularError <= b2Settings.b2_angularSlop;

	}

	private var m_localAnchorA:b2Vec2 = new b2Vec2();
	private var m_localAnchorB:b2Vec2 = new b2Vec2();
	private var m_referenceAngle:Number;
	
	private var m_impulse:b2Vec3 = new b2Vec3();
	private var m_mass:b2Mat33 = new b2Mat33();
};

}
