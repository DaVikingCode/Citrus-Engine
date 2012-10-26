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


// p = attached point, m = mouse point
// C = p - m
// Cdot = v
//      = v + cross(w, r)
// J = [I r_skew]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

/**
* A mouse joint is used to make a point on a body track a
* specified world point. This a soft constraint with a maximum
* force. This allows the constraint to stretch and without
* applying huge forces.
* Note: this joint is not fully documented as it is intended primarily
* for the testbed. See that for more instructions.
* @see b2MouseJointDef
*/

public class b2MouseJoint extends b2Joint
{
	/** @inheritDoc */
	public override function GetAnchorA():b2Vec2{
		return m_target;
	}
	/** @inheritDoc */
	public override function GetAnchorB():b2Vec2{
		return m_bodyB.GetWorldPoint(m_localAnchor);
	}
	/** @inheritDoc */
	public override function GetReactionForce(inv_dt:Number):b2Vec2
	{
		return new b2Vec2(inv_dt * m_impulse.x, inv_dt * m_impulse.y);
	}
	/** @inheritDoc */
	public override function GetReactionTorque(inv_dt:Number):Number
	{
		return 0.0;
	}
	
	public function GetTarget():b2Vec2
	{
		return m_target;
	}
	
	/**
	 * Use this to update the target point.
	 */
	public function SetTarget(target:b2Vec2) : void{
		if (m_bodyB.IsAwake() == false){
			m_bodyB.SetAwake(true);
		}
		m_target = target;
	}

	/// Get the maximum force in Newtons.
	public function GetMaxForce():Number
	{
		return m_maxForce;
	}
	
	/// Set the maximum force in Newtons.
	public function SetMaxForce(maxForce:Number):void
	{
		m_maxForce = maxForce;
	}
	
	/// Get frequency in Hz
	public function GetFrequency():Number
	{
		return m_frequencyHz;
	}
	
	/// Set the frequency in Hz
	public function SetFrequency(hz:Number):void
	{
		m_frequencyHz = hz;
	}
	
	/// Get damping ratio
	public function GetDampingRatio():Number
	{
		return m_dampingRatio;
	}
	
	/// Set damping ratio
	public function SetDampingRatio(ratio:Number):void
	{
		m_dampingRatio = ratio;
	}
	
	//--------------- Internals Below -------------------

	/** @private */
	public function b2MouseJoint(def:b2MouseJointDef){
		super(def);
		
		//b2Settings.b2Assert(def.target.IsValid());
		//b2Settings.b2Assert(b2Math.b2IsValid(def.maxForce) && def.maxForce > 0.0);
		//b2Settings.b2Assert(b2Math.b2IsValid(def.frequencyHz) && def.frequencyHz > 0.0);
		//b2Settings.b2Assert(b2Math.b2IsValid(def.dampingRatio) && def.dampingRatio > 0.0);
		
		m_target.SetV(def.target);
		//m_localAnchor = b2MulT(m_bodyB.m_xf, m_target);
		var tX:Number = m_target.x - m_bodyB.m_xf.position.x;
		var tY:Number = m_target.y - m_bodyB.m_xf.position.y;
		var tMat:b2Mat22 = m_bodyB.m_xf.R;
		m_localAnchor.x = (tX * tMat.col1.x + tY * tMat.col1.y);
		m_localAnchor.y = (tX * tMat.col2.x + tY * tMat.col2.y);
		
		m_maxForce = def.maxForce;
		m_impulse.SetZero();
		
		m_frequencyHz = def.frequencyHz;
		m_dampingRatio = def.dampingRatio;
		
		m_beta = 0.0;
		m_gamma = 0.0;
	}

	// Presolve vars
	private var K:b2Mat22 = new b2Mat22();
	private var K1:b2Mat22 = new b2Mat22();
	private var K2:b2Mat22 = new b2Mat22();
	b2internal override function InitVelocityConstraints(step:b2TimeStep): void{
		var b:b2Body = m_bodyB;
		
		var mass:Number = b.GetMass();
		
		// Frequency
		var omega:Number = 2.0 * Math.PI * m_frequencyHz;
		
		// Damping co-efficient
		var d:Number = 2.0 * mass * m_dampingRatio * omega;
		
		// Spring stiffness
		var k:Number = mass * omega * omega;
		
		// magic formulas
		// gamma has units of inverse mass
		// beta hs units of inverse time
		//b2Settings.b2Assert(d + step.dt * k > Number.MIN_VALUE)
		m_gamma = step.dt * (d + step.dt * k);
		m_gamma = m_gamma != 0 ? 1 / m_gamma:0.0;
		m_beta = step.dt * k * m_gamma;
		
		var tMat:b2Mat22;
		
		// Compute the effective mass matrix.
		//b2Vec2 r = b2Mul(b->m_xf.R, m_localAnchor - b->GetLocalCenter());
		tMat = b.m_xf.R;
		var rX:Number = m_localAnchor.x - b.m_sweep.localCenter.x;
		var rY:Number = m_localAnchor.y - b.m_sweep.localCenter.y;
		var tX:Number = (tMat.col1.x * rX + tMat.col2.x * rY);
		rY = (tMat.col1.y * rX + tMat.col2.y * rY);
		rX = tX;
		
		// K    = [(1/m1 + 1/m2) * eye(2) - skew(r1) * invI1 * skew(r1) - skew(r2) * invI2 * skew(r2)]
		//      = [1/m1+1/m2     0    ] + invI1 * [r1.y*r1.y -r1.x*r1.y] + invI2 * [r1.y*r1.y -r1.x*r1.y]
		//        [    0     1/m1+1/m2]           [-r1.x*r1.y r1.x*r1.x]           [-r1.x*r1.y r1.x*r1.x]
		var invMass:Number = b.m_invMass;
		var invI:Number = b.m_invI;
		
		//b2Mat22 K1;
		K1.col1.x = invMass;	K1.col2.x = 0.0;
		K1.col1.y = 0.0;		K1.col2.y = invMass;
		
		//b2Mat22 K2;
		K2.col1.x =  invI * rY * rY;	K2.col2.x = -invI * rX * rY;
		K2.col1.y = -invI * rX * rY;	K2.col2.y =  invI * rX * rX;
		
		//b2Mat22 K = K1 + K2;
		K.SetM(K1);
		K.AddM(K2);
		K.col1.x += m_gamma;
		K.col2.y += m_gamma;
		
		//m_ptpMass = K.GetInverse();
		K.GetInverse(m_mass);
		
		//m_C = b.m_position + r - m_target;
		m_C.x = b.m_sweep.c.x + rX - m_target.x;
		m_C.y = b.m_sweep.c.y + rY - m_target.y;
		
		// Cheat with some damping
		b.m_angularVelocity *= 0.98;
		
		// Warm starting.
		m_impulse.x *= step.dtRatio;
		m_impulse.y *= step.dtRatio;
		//b.m_linearVelocity += invMass * m_impulse;
		b.m_linearVelocity.x += invMass * m_impulse.x;
		b.m_linearVelocity.y += invMass * m_impulse.y;
		//b.m_angularVelocity += invI * b2Cross(r, m_impulse);
		b.m_angularVelocity += invI * (rX * m_impulse.y - rY * m_impulse.x);
	}
	
	b2internal override function SolveVelocityConstraints(step:b2TimeStep) : void{
		var b:b2Body = m_bodyB;
		
		var tMat:b2Mat22;
		var tX:Number;
		var tY:Number;
		
		// Compute the effective mass matrix.
		//b2Vec2 r = b2Mul(b->m_xf.R, m_localAnchor - b->GetLocalCenter());
		tMat = b.m_xf.R;
		var rX:Number = m_localAnchor.x - b.m_sweep.localCenter.x;
		var rY:Number = m_localAnchor.y - b.m_sweep.localCenter.y;
		tX = (tMat.col1.x * rX + tMat.col2.x * rY);
		rY = (tMat.col1.y * rX + tMat.col2.y * rY);
		rX = tX;
		
		// Cdot = v + cross(w, r)
		//b2Vec2 Cdot = b->m_linearVelocity + b2Cross(b->m_angularVelocity, r);
		var CdotX:Number = b.m_linearVelocity.x + (-b.m_angularVelocity * rY);
		var CdotY:Number = b.m_linearVelocity.y + (b.m_angularVelocity * rX);
		//b2Vec2 impulse = - b2Mul(m_mass, Cdot + m_beta * m_C + m_gamma * m_impulse);
		tMat = m_mass;
		tX = CdotX + m_beta * m_C.x + m_gamma * m_impulse.x;
		tY = CdotY + m_beta * m_C.y + m_gamma * m_impulse.y;
		var impulseX:Number = -(tMat.col1.x * tX + tMat.col2.x * tY);
		var impulseY:Number = -(tMat.col1.y * tX + tMat.col2.y * tY);
		
		var oldImpulseX:Number = m_impulse.x;
		var oldImpulseY:Number = m_impulse.y;
		//m_impulse += impulse;
		m_impulse.x += impulseX;
		m_impulse.y += impulseY;
		var maxImpulse:Number = step.dt * m_maxForce;
		if (m_impulse.LengthSquared() > maxImpulse*maxImpulse)
		{
			//m_impulse *= m_maxImpulse / m_impulse.Length();
			m_impulse.Multiply(maxImpulse / m_impulse.Length());
		}
		//impulse = m_impulse - oldImpulse;
		impulseX = m_impulse.x - oldImpulseX;
		impulseY = m_impulse.y - oldImpulseY;
		
		//b->m_linearVelocity += b->m_invMass * impulse;
		b.m_linearVelocity.x += b.m_invMass * impulseX;
		b.m_linearVelocity.y += b.m_invMass * impulseY;
		//b->m_angularVelocity += b->m_invI * b2Cross(r, P);
		b.m_angularVelocity += b.m_invI * (rX * impulseY - rY * impulseX);
	}

	b2internal override function SolvePositionConstraints(baumgarte:Number):Boolean { 
		//B2_NOT_USED(baumgarte);
		return true; 
	}

	private var m_localAnchor:b2Vec2 = new b2Vec2();
	private var m_target:b2Vec2 = new b2Vec2();
	private var m_impulse:b2Vec2 = new b2Vec2();

	private var m_mass:b2Mat22 = new b2Mat22();	// effective mass for point-to-point constraint.
	private var m_C:b2Vec2 = new b2Vec2();			// position error
	private var m_maxForce:Number;
	private var m_frequencyHz:Number;
	private var m_dampingRatio:Number;
	private var m_beta:Number;						// bias factor
	private var m_gamma:Number;						// softness
};

}
