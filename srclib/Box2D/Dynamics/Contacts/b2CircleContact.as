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

package Box2D.Dynamics.Contacts{


	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
use namespace b2internal;

/**
* @private
*/
public class b2CircleContact extends b2Contact
{
	static public function Create(allocator:*):b2Contact{
		return new b2CircleContact();
	}
	static public function Destroy(contact:b2Contact, allocator:*) : void{
		//
	}

	public function Reset(fixtureA:b2Fixture, fixtureB:b2Fixture):void{
		super.Reset(fixtureA, fixtureB);
		//b2Settings.b2Assert(m_shape1.m_type == b2Shape.e_circleShape);
		//b2Settings.b2Assert(m_shape2.m_type == b2Shape.e_circleShape);
	}
	//~b2CircleContact() {}
	
	b2internal override function Evaluate() : void{
		var bA:b2Body = m_fixtureA.GetBody();
		var bB:b2Body = m_fixtureB.GetBody();
		
		b2Collision.CollideCircles(m_manifold, 
					m_fixtureA.GetShape() as b2CircleShape, bA.m_xf, 
					m_fixtureB.GetShape() as b2CircleShape, bB.m_xf);
	}
};

}