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

package Box2D.Collision.Shapes{



	import Box2D.Collision.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
use namespace b2internal;



/**
* A circle shape.
* @see b2CircleDef
*/
public class b2CircleShape extends b2Shape
{
	override public function Copy():b2Shape 
	{
		var s:b2Shape = new b2CircleShape();
		s.Set(this);
		return s;
	}
	
	override public function Set(other:b2Shape):void 
	{
		super.Set(other);
		if (other is b2CircleShape)
		{
			var other2:b2CircleShape = other as b2CircleShape;
			m_p.SetV(other2.m_p);
		}
	}
	
	/**
	* @inheritDoc
	*/
	public override function TestPoint(transform:b2Transform, p:b2Vec2) : Boolean{
		//b2Vec2 center = transform.position + b2Mul(transform.R, m_p);
		var tMat:b2Mat22 = transform.R;
		var dX:Number = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y);
		var dY:Number = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y);
		//b2Vec2 d = p - center;
		dX = p.x - dX;
		dY = p.y - dY;
		//return b2Dot(d, d) <= m_radius * m_radius;
		return (dX*dX + dY*dY) <= m_radius * m_radius;
	}

	/**
	* @inheritDoc
	*/
	public override function RayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform):Boolean
	{
		//b2Vec2 position = transform.position + b2Mul(transform.R, m_p);
		var tMat:b2Mat22 = transform.R;
		var positionX:Number = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y);
		var positionY:Number = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y);
		
		//b2Vec2 s = input.p1 - position;
		var sX:Number = input.p1.x - positionX;
		var sY:Number = input.p1.y - positionY;
		//float32 b = b2Dot(s, s) - m_radius * m_radius;
		var b:Number = (sX*sX + sY*sY) - m_radius * m_radius;
		
		/*// Does the segment start inside the circle?
		if (b < 0.0)
		{
			output.fraction = 0;
			output.hit = e_startsInsideCollide;
			return;
		}*/
		
		// Solve quadratic equation.
		//b2Vec2 r = input.p2 - input.p1;
		var rX:Number = input.p2.x - input.p1.x;
		var rY:Number = input.p2.y - input.p1.y;
		//float32 c =  b2Dot(s, r);
		var c:Number =  (sX*rX + sY*rY);
		//float32 rr = b2Dot(r, r);
		var rr:Number = (rX*rX + rY*rY);
		var sigma:Number = c * c - rr * b;
		
		// Check for negative discriminant and short segment.
		if (sigma < 0.0 || rr < Number.MIN_VALUE)
		{
			return false;
		}
		
		// Find the point of intersection of the line with the circle.
		var a:Number = -(c + Math.sqrt(sigma));
		
		// Is the intersection point on the segment?
		if (0.0 <= a && a <= input.maxFraction * rr)
		{
			a /= rr;
			output.fraction = a;
			// manual inline of: output.normal = s + a * r;
			output.normal.x = sX + a * rX;
			output.normal.y = sY + a * rY;
			output.normal.Normalize();
			return true;
		}
		
		return false;
	}

	/**
	* @inheritDoc
	*/
	public override function ComputeAABB(aabb:b2AABB, transform:b2Transform) : void{
		//b2Vec2 p = transform.position + b2Mul(transform.R, m_p);
		var tMat:b2Mat22 = transform.R;
		var pX:Number = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y);
		var pY:Number = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y);
		aabb.lowerBound.Set(pX - m_radius, pY - m_radius);
		aabb.upperBound.Set(pX + m_radius, pY + m_radius);
	}

	/**
	* @inheritDoc
	*/
	public override function ComputeMass(massData:b2MassData, density:Number) : void{
		massData.mass = density * b2Settings.b2_pi * m_radius * m_radius;
		massData.center.SetV(m_p);
		
		// inertia about the local origin
		//massData.I = massData.mass * (0.5 * m_radius * m_radius + b2Dot(m_p, m_p));
		massData.I = massData.mass * (0.5 * m_radius * m_radius + (m_p.x*m_p.x + m_p.y*m_p.y));
	}
	
	/**
	* @inheritDoc
	*/
	public override function ComputeSubmergedArea(
			normal:b2Vec2,
			offset:Number,
			xf:b2Transform,
			c:b2Vec2):Number
	{
		var p:b2Vec2 = b2Math.MulX(xf, m_p);
		var l:Number = -(b2Math.Dot(normal, p) - offset);
		
		if (l < -m_radius + Number.MIN_VALUE)
		{
			//Completely dry
			return 0;
		}
		if (l > m_radius)
		{
			//Completely wet
			c.SetV(p);
			return Math.PI * m_radius * m_radius;
		}
		
		//Magic
		var r2:Number = m_radius * m_radius;
		var l2:Number = l * l;
		var area:Number = r2 *( Math.asin(l / m_radius) + Math.PI / 2) + l * Math.sqrt( r2 - l2 );
		var com:Number = -2 / 3 * Math.pow(r2 - l2, 1.5) / area;
		
		c.x = p.x + normal.x * com;
		c.y = p.y + normal.y * com;
		
		return area;
	}

	/**
	 * Get the local position of this circle in its parent body.
	 */
	public function GetLocalPosition() : b2Vec2{
		return m_p;
	}
	
	/**
	 * Set the local position of this circle in its parent body.
	 */
	public function SetLocalPosition(position:b2Vec2):void {
		m_p.SetV(position);
	}
	
	/**
	 * Get the radius of the circle
	 */
	public function GetRadius():Number
	{
		return m_radius;
	}
	
	/**
	 * Set the radius of the circle
	 */
	public function SetRadius(radius:Number):void
	{
		m_radius = radius;
	}

	public function b2CircleShape(radius:Number = 0){
		super();
		m_type = e_circleShape;
		m_radius = radius;
	}

	// Local position in parent body
	b2internal var m_p:b2Vec2 = new b2Vec2();
	
};

}
