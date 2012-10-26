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
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
use namespace b2internal;


//typedef b2Contact* b2ContactCreateFcn(b2Shape* shape1, b2Shape* shape2, b2BlockAllocator* allocator);
//typedef void b2ContactDestroyFcn(b2Contact* contact, b2BlockAllocator* allocator);



/**
* The class manages contact between two shapes. A contact exists for each overlapping
* AABB in the broad-phase (except if filtered). Therefore a contact object may exist
* that has no contact points.
*/
public class b2Contact
{
	/**
	 * Get the contact manifold. Do not modify the manifold unless you understand the
	 * internals of Box2D
	 */
	public function GetManifold():b2Manifold
	{
		return m_manifold;
	}
	
	/**
	 * Get the world manifold
	 */
	public function GetWorldManifold(worldManifold:b2WorldManifold):void
	{
		var bodyA:b2Body = m_fixtureA.GetBody();
		var bodyB:b2Body = m_fixtureB.GetBody();
		var shapeA:b2Shape = m_fixtureA.GetShape();
		var shapeB:b2Shape = m_fixtureB.GetShape();
		
		worldManifold.Initialize(m_manifold, bodyA.GetTransform(), shapeA.m_radius, bodyB.GetTransform(), shapeB.m_radius);
	}
	
	/**
	 * Is this contact touching.
	 */
	public function IsTouching():Boolean
	{
		return (m_flags & e_touchingFlag) == e_touchingFlag; 
	}
	
	/**
	 * Does this contact generate TOI events for continuous simulation
	 */
	public function IsContinuous():Boolean
	{
		return (m_flags & e_continuousFlag) == e_continuousFlag; 
	}
	
	/**
	 * Change this to be a sensor or-non-sensor contact.
	 */
	public function SetSensor(sensor:Boolean):void{
		if (sensor)
		{
			m_flags |= e_sensorFlag;
		}
		else
		{
			m_flags &= ~e_sensorFlag;
		}
	}
	
	/**
	 * Is this contact a sensor?
	 */
	public function IsSensor():Boolean{
		return (m_flags & e_sensorFlag) == e_sensorFlag;
	}
	
	/**
	 * Enable/disable this contact. This can be used inside the pre-solve
	 * contact listener. The contact is only disabled for the current
	 * time step (or sub-step in continuous collision).
	 */
	public function SetEnabled(flag:Boolean):void{
		if (flag)
		{
			m_flags |= e_enabledFlag;
		}
		else
		{
			m_flags &= ~e_enabledFlag;
		}
	}
	
	/**
	 * Has this contact been disabled?
	 * @return
	 */
	public function IsEnabled():Boolean {
		return (m_flags & e_enabledFlag) == e_enabledFlag;
	}
	
	/**
	* Get the next contact in the world's contact list.
	*/
	public function GetNext():b2Contact{
		return m_next;
	}
	
	/**
	* Get the first fixture in this contact.
	*/
	public function GetFixtureA():b2Fixture
	{
		return m_fixtureA;
	}
	
	/**
	* Get the second fixture in this contact.
	*/
	public function GetFixtureB():b2Fixture
	{
		return m_fixtureB;
	}
	
	/**
	 * Flag this contact for filtering. Filtering will occur the next time step.
	 */
	public function FlagForFiltering():void
	{
		m_flags |= e_filterFlag;
	}

	//--------------- Internals Below -------------------
	
	// m_flags
	// enum
	// This contact should not participate in Solve
	// The contact equivalent of sensors
	static b2internal var e_sensorFlag:uint		= 0x0001;
	// Generate TOI events.
	static b2internal var e_continuousFlag:uint	= 0x0002;
	// Used when crawling contact graph when forming islands.
	static b2internal var e_islandFlag:uint		= 0x0004;
	// Used in SolveTOI to indicate the cached toi value is still valid.
	static b2internal var e_toiFlag:uint		= 0x0008;
	// Set when shapes are touching
	static b2internal var e_touchingFlag:uint	= 0x0010;
	// This contact can be disabled (by user)
	static b2internal var e_enabledFlag:uint	= 0x0020;
	// This contact needs filtering because a fixture filter was changed.
	static b2internal var e_filterFlag:uint		= 0x0040;

	public function b2Contact()
	{
		// Real work is done in Reset
	}
	
	/** @private */
	b2internal function Reset(fixtureA:b2Fixture = null, fixtureB:b2Fixture = null):void
	{
		m_flags = e_enabledFlag;
		
		if (!fixtureA || !fixtureB){
			m_fixtureA = null;
			m_fixtureB = null;
			return;
		}
		
		if (fixtureA.IsSensor() || fixtureB.IsSensor())
		{
			m_flags |= e_sensorFlag;
		}
		
		var bodyA:b2Body = fixtureA.GetBody();
		var bodyB:b2Body = fixtureB.GetBody();
		
		if (bodyA.GetType() != b2Body.b2_dynamicBody || bodyA.IsBullet() || bodyB.GetType() != b2Body.b2_dynamicBody || bodyB.IsBullet())
		{
			m_flags |= e_continuousFlag;
		}
		
		m_fixtureA = fixtureA;
		m_fixtureB = fixtureB;
		
		m_manifold.m_pointCount = 0;
		
		m_prev = null;
		m_next = null;
		
		m_nodeA.contact = null;
		m_nodeA.prev = null;
		m_nodeA.next = null;
		m_nodeA.other = null;
		
		m_nodeB.contact = null;
		m_nodeB.prev = null;
		m_nodeB.next = null;
		m_nodeB.other = null;
	}
	
	b2internal function Update(listener:b2ContactListener) : void
	{
		// Swap old & new manifold
		var tManifold:b2Manifold = m_oldManifold;
		m_oldManifold = m_manifold;
		m_manifold = tManifold;
		
		// Re-enable this contact
		m_flags |= e_enabledFlag;
		
		var touching:Boolean = false;
		var wasTouching:Boolean = (m_flags & e_touchingFlag) == e_touchingFlag;
		
		var bodyA:b2Body = m_fixtureA.m_body;
		var bodyB:b2Body = m_fixtureB.m_body;
		
		var aabbOverlap:Boolean = m_fixtureA.m_aabb.TestOverlap(m_fixtureB.m_aabb);
		
		// Is this contat a sensor?
		if (m_flags  & e_sensorFlag)
		{
			if (aabbOverlap)
			{
				var shapeA:b2Shape = m_fixtureA.GetShape();
				var shapeB:b2Shape = m_fixtureB.GetShape();
				var xfA:b2Transform = bodyA.GetTransform();
				var xfB:b2Transform = bodyB.GetTransform();
				touching = b2Shape.TestOverlap(shapeA, xfA, shapeB, xfB);
			}
			
			// Sensors don't generate manifolds
			m_manifold.m_pointCount = 0;
		}
		else
		{
			// Slow contacts don't generate TOI events.
			if (bodyA.GetType() != b2Body.b2_dynamicBody || bodyA.IsBullet() || bodyB.GetType() != b2Body.b2_dynamicBody || bodyB.IsBullet())
			{
				m_flags |= e_continuousFlag;
			}
			else
			{
				m_flags &= ~e_continuousFlag;
			}
			
			if (aabbOverlap)
			{
				Evaluate();
				
				touching = m_manifold.m_pointCount > 0;
				
				// Match old contact ids to new contact ids and copy the
				// stored impulses to warm start the solver.
				for (var i:int = 0; i < m_manifold.m_pointCount; ++i)
				{
					var mp2:b2ManifoldPoint = m_manifold.m_points[i];
					mp2.m_normalImpulse = 0.0;
					mp2.m_tangentImpulse = 0.0;
					var id2:b2ContactID = mp2.m_id;

					for (var j:int = 0; j < m_oldManifold.m_pointCount; ++j)
					{
						var mp1:b2ManifoldPoint = m_oldManifold.m_points[j];

						if (mp1.m_id.key == id2.key)
						{
							mp2.m_normalImpulse = mp1.m_normalImpulse;
							mp2.m_tangentImpulse = mp1.m_tangentImpulse;
							break;
						}
					}
				}

			}
			else
			{
				m_manifold.m_pointCount = 0;
			}
			if (touching != wasTouching)
			{
				bodyA.SetAwake(true);
				bodyB.SetAwake(true);
			}
		}
				
		if (touching)
		{
			m_flags |= e_touchingFlag;
		}
		else
		{
			m_flags &= ~e_touchingFlag;
		}

		if (wasTouching == false && touching == true)
		{
			listener.BeginContact(this);
		}

		if (wasTouching == true && touching == false)
		{
			listener.EndContact(this);
		}

		if ((m_flags & e_sensorFlag) == 0)
		{
			listener.PreSolve(this, m_oldManifold);
		}
	}

	//virtual ~b2Contact() {}

	b2internal virtual function Evaluate() : void{};
	
	private static var s_input:b2TOIInput = new b2TOIInput();
	b2internal function ComputeTOI(sweepA:b2Sweep, sweepB:b2Sweep):Number
	{
		s_input.proxyA.Set(m_fixtureA.GetShape());
		s_input.proxyB.Set(m_fixtureB.GetShape());
		s_input.sweepA = sweepA;
		s_input.sweepB = sweepB;
		s_input.tolerance = b2Settings.b2_linearSlop;
		return b2TimeOfImpact.TimeOfImpact(s_input);
	}
	
	b2internal var m_flags:uint;

	// World pool and list pointers.
	b2internal var m_prev:b2Contact;
	b2internal var m_next:b2Contact;

	// Nodes for connecting bodies.
	b2internal var m_nodeA:b2ContactEdge = new b2ContactEdge();
	b2internal var m_nodeB:b2ContactEdge = new b2ContactEdge();

	b2internal var m_fixtureA:b2Fixture;
	b2internal var m_fixtureB:b2Fixture;

	b2internal var m_manifold:b2Manifold = new b2Manifold();
	b2internal var m_oldManifold:b2Manifold = new b2Manifold();
	
	b2internal var m_toi:Number;
};


}
