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
* Pulley joint definition. This requires two ground anchors,
* two dynamic body anchor points, max lengths for each side,
* and a pulley ratio.
* @see b2PulleyJoint
*/

public class b2PulleyJointDef extends b2JointDef
{
	public function b2PulleyJointDef()
	{
		type = b2Joint.e_pulleyJoint;
		groundAnchorA.Set(-1.0, 1.0);
		groundAnchorB.Set(1.0, 1.0);
		localAnchorA.Set(-1.0, 0.0);
		localAnchorB.Set(1.0, 0.0);
		lengthA = 0.0;
		maxLengthA = 0.0;
		lengthB = 0.0;
		maxLengthB = 0.0;
		ratio = 1.0;
		collideConnected = true;
	}
	
	public function Initialize(bA:b2Body, bB:b2Body,
				gaA:b2Vec2, gaB:b2Vec2,
				anchorA:b2Vec2, anchorB:b2Vec2,
				r:Number) : void
	{
		bodyA = bA;
		bodyB = bB;
		groundAnchorA.SetV( gaA );
		groundAnchorB.SetV( gaB );
		localAnchorA = bodyA.GetLocalPoint(anchorA);
		localAnchorB = bodyB.GetLocalPoint(anchorB);
		//b2Vec2 d1 = anchorA - gaA;
		var d1X:Number = anchorA.x - gaA.x;
		var d1Y:Number = anchorA.y - gaA.y;
		//length1 = d1.Length();
		lengthA = Math.sqrt(d1X*d1X + d1Y*d1Y);
		
		//b2Vec2 d2 = anchor2 - ga2;
		var d2X:Number = anchorB.x - gaB.x;
		var d2Y:Number = anchorB.y - gaB.y;
		//length2 = d2.Length();
		lengthB = Math.sqrt(d2X*d2X + d2Y*d2Y);
		
		ratio = r;
		//b2Settings.b2Assert(ratio > Number.MIN_VALUE);
		var C:Number = lengthA + ratio * lengthB;
		maxLengthA = C - ratio * b2PulleyJoint.b2_minPulleyLength;
		maxLengthB = (C - b2PulleyJoint.b2_minPulleyLength) / ratio;
	}

	/**
	* The first ground anchor in world coordinates. This point never moves.
	*/
	public var groundAnchorA:b2Vec2 = new b2Vec2();
	
	/**
	* The second ground anchor in world coordinates. This point never moves.
	*/
	public var groundAnchorB:b2Vec2 = new b2Vec2();
	
	/**
	* The local anchor point relative to bodyA's origin.
	*/
	public var localAnchorA:b2Vec2 = new b2Vec2();
	
	/**
	* The local anchor point relative to bodyB's origin.
	*/
	public var localAnchorB:b2Vec2 = new b2Vec2();
	
	/**
	* The a reference length for the segment attached to bodyA.
	*/
	public var lengthA:Number;
	
	/**
	* The maximum length of the segment attached to bodyA.
	*/
	public var maxLengthA:Number;
	
	/**
	* The a reference length for the segment attached to bodyB.
	*/
	public var lengthB:Number;
	
	/**
	* The maximum length of the segment attached to bodyB.
	*/
	public var maxLengthB:Number;
	
	/**
	* The pulley ratio, used to simulate a block-and-tackle.
	*/
	public var ratio:Number;
	
};

}