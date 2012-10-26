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

	import Box2D.Common.Math.*;
	import Box2D.Common.b2internal;
	import Box2D.Dynamics.*;
	
	
use namespace b2internal;



/**
* Revolute joint definition. This requires defining an
* anchor point where the bodies are joined. The definition
* uses local anchor points so that the initial configuration
* can violate the constraint slightly. You also need to
* specify the initial relative angle for joint limits. This
* helps when saving and loading a game.
* The local anchor points are measured from the body's origin
* rather than the center of mass because:
* 1. you might not know where the center of mass will be.
* 2. if you add/remove shapes from a body and recompute the mass,
* the joints will be broken.
* @see b2RevoluteJoint
*/

public class b2RevoluteJointDef extends b2JointDef
{
	public function b2RevoluteJointDef()
	{
		type = b2Joint.e_revoluteJoint;
		localAnchorA.Set(0.0, 0.0);
		localAnchorB.Set(0.0, 0.0);
		referenceAngle = 0.0;
		lowerAngle = 0.0;
		upperAngle = 0.0;
		maxMotorTorque = 0.0;
		motorSpeed = 0.0;
		enableLimit = false;
		enableMotor = false;
	}

	/**
	* Initialize the bodies, anchors, and reference angle using the world
	* anchor.
	*/
	public function Initialize(bA:b2Body, bB:b2Body, anchor:b2Vec2) : void{
		bodyA = bA;
		bodyB = bB;
		localAnchorA = bodyA.GetLocalPoint(anchor);
		localAnchorB = bodyB.GetLocalPoint(anchor);
		referenceAngle = bodyB.GetAngle() - bodyA.GetAngle();
	}

	/**
	* The local anchor point relative to bodyA's origin.
	*/
	public var localAnchorA:b2Vec2 = new b2Vec2();

	/**
	* The local anchor point relative to bodyB's origin.
	*/
	public var localAnchorB:b2Vec2 = new b2Vec2();

	/**
	* The bodyB angle minus bodyA angle in the reference state (radians).
	*/
	public var referenceAngle:Number;

	/**
	* A flag to enable joint limits.
	*/
	public var enableLimit:Boolean;

	/**
	* The lower angle for the joint limit (radians).
	*/
	public var lowerAngle:Number;

	/**
	* The upper angle for the joint limit (radians).
	*/
	public var upperAngle:Number;

	/**
	* A flag to enable the joint motor.
	*/
	public var enableMotor:Boolean;

	/**
	* The desired motor speed. Usually in radians per second.
	*/
	public var motorSpeed:Number;

	/**
	* The maximum motor torque used to achieve the desired motor speed.
	* Usually in N-m.
	*/
	public var maxMotorTorque:Number;
	
};

}