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
 * An edge shape.
 * @private
 * @see b2EdgeChainDef
 */
public class b2EdgeShape extends b2Shape
{
	/**
	* Returns false. Edges cannot contain points. 
	*/
	public override function TestPoint(transform:b2Transform, p:b2Vec2) : Boolean{
		return false;
	}

	/**
	* @inheritDoc
	*/
	public override function RayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform):Boolean
	{
		var tMat:b2Mat22;
		var rX: Number = input.p2.x - input.p1.x;
		var rY: Number = input.p2.y - input.p1.y;
		
		//b2Vec2 v1 = b2Mul(transform, m_v1);
		tMat = transform.R;
		var v1X: Number = transform.position.x + (tMat.col1.x * m_v1.x + tMat.col2.x * m_v1.y);
		var v1Y: Number = transform.position.y + (tMat.col1.y * m_v1.x + tMat.col2.y * m_v1.y);
		
		//b2Vec2 n = b2Cross(d, 1.0);
		var nX: Number = transform.position.y + (tMat.col1.y * m_v2.x + tMat.col2.y * m_v2.y) - v1Y;
		var nY: Number = -(transform.position.x + (tMat.col1.x * m_v2.x + tMat.col2.x * m_v2.y) - v1X);
		
		var k_slop: Number = 100.0 * Number.MIN_VALUE;
		var denom: Number = -(rX * nX + rY * nY);
	
		// Cull back facing collision and ignore parallel segments.
		if (denom > k_slop)
		{
			// Does the segment intersect the infinite line associated with this segment?
			var bX: Number = input.p1.x - v1X;
			var bY: Number = input.p1.y - v1Y;
			var a: Number = (bX * nX + bY * nY);
	
			if (0.0 <= a && a <= input.maxFraction * denom)
			{
				var mu2: Number = -rX * bY + rY * bX;
	
				// Does the segment intersect this segment?
				if (-k_slop * denom <= mu2 && mu2 <= denom * (1.0 + k_slop))
				{
					a /= denom;
					output.fraction = a;
					var nLen: Number = Math.sqrt(nX * nX + nY * nY);
					output.normal.x = nX / nLen;
					output.normal.y = nY / nLen;
					return true;
				}
			}
		}
		
		return false;
	}

	/**
	* @inheritDoc
	*/
	public override function ComputeAABB(aabb:b2AABB, transform:b2Transform) : void{
		var tMat:b2Mat22 = transform.R;
		//b2Vec2 v1 = b2Mul(transform, m_v1);
		var v1X:Number = transform.position.x + (tMat.col1.x * m_v1.x + tMat.col2.x * m_v1.y);
		var v1Y:Number = transform.position.y + (tMat.col1.y * m_v1.x + tMat.col2.y * m_v1.y);
		//b2Vec2 v2 = b2Mul(transform, m_v2);
		var v2X:Number = transform.position.x + (tMat.col1.x * m_v2.x + tMat.col2.x * m_v2.y);
		var v2Y:Number = transform.position.y + (tMat.col1.y * m_v2.x + tMat.col2.y * m_v2.y);
		if (v1X < v2X) {
			aabb.lowerBound.x = v1X;
			aabb.upperBound.x = v2X;
		} else {
			aabb.lowerBound.x = v2X;
			aabb.upperBound.x = v1X;
		}
		if (v1Y < v2Y) {
			aabb.lowerBound.y = v1Y;
			aabb.upperBound.y = v2Y;
		} else {
			aabb.lowerBound.y = v2Y;
			aabb.upperBound.y = v1Y;
		}
	}

	/**
	* @inheritDoc
	*/
	public override function ComputeMass(massData:b2MassData, density:Number) : void{
		massData.mass = 0;
		massData.center.SetV(m_v1);
		massData.I = 0;
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
		// Note that v0 is independant of any details of the specific edge
		// We are relying on v0 being consistent between multiple edges of the same body
		//b2Vec2 v0 = offset * normal;
		var v0:b2Vec2 = new b2Vec2(normal.x * offset, normal.y * offset);
		
		var v1:b2Vec2 = b2Math.MulX(xf, m_v1);
		var v2:b2Vec2 = b2Math.MulX(xf, m_v2);
		
		var d1:Number = b2Math.Dot(normal, v1) - offset;
		var d2:Number = b2Math.Dot(normal, v2) - offset;
		if (d1 > 0)
		{
			if (d2 > 0)
			{
				return 0;
			}
			else
			{
				//v1 = -d2 / (d1 - d2) * v1 + d1 / (d1 - d2) * v2;
				v1.x = -d2 / (d1 - d2) * v1.x + d1 / (d1 - d2) * v2.x;
				v1.y = -d2 / (d1 - d2) * v1.y + d1 / (d1 - d2) * v2.y;
			}
		}
		else
		{
			if (d2 > 0)
			{
				//v2 = -d2 / (d1 - d2) * v1 + d1 / (d1 - d2) * v2;
				v2.x = -d2 / (d1 - d2) * v1.x + d1 / (d1 - d2) * v2.x;
				v2.y = -d2 / (d1 - d2) * v1.y + d1 / (d1 - d2) * v2.y;
			}
			else
			{
				// Nothing
			}
		}
		// v0,v1,v2 represents a fully submerged triangle
		// Area weighted centroid
		c.x = (v0.x + v1.x + v2.x) / 3;
		c.y = (v0.y + v1.y + v2.y) / 3;
		
		//b2Vec2 e1 = v1 - v0;
		//b2Vec2 e2 = v2 - v0;
		//return 0.5f * b2Cross(e1, e2);
		return 0.5 * ( (v1.x - v0.x) * (v2.y - v0.y) - (v1.y - v0.y) * (v2.x - v0.x) );
	}

	/**
	* Get the distance from vertex1 to vertex2.
	*/
	public function GetLength(): Number
	{
		return m_length;
	}

	/**
	* Get the local position of vertex1 in parent body.
	*/
	public function GetVertex1(): b2Vec2
	{
		return m_v1;
	}

	/**
	* Get the local position of vertex2 in parent body.
	*/
	public function GetVertex2(): b2Vec2
	{
		return m_v2;
	}

	/**
	* Get a core vertex in local coordinates. These vertices
	* represent a smaller edge that is used for time of impact
	* computations.
	*/
	public function GetCoreVertex1(): b2Vec2
	{
		return m_coreV1;
	}

	/**
	* Get a core vertex in local coordinates. These vertices
	* represent a smaller edge that is used for time of impact
	* computations.
	*/
	public function GetCoreVertex2(): b2Vec2
	{
		return m_coreV2;
	}
	
	/**
	* Get a perpendicular unit vector, pointing
	* from the solid side to the empty side.
	*/
	public function GetNormalVector(): b2Vec2
	{
		return m_normal;
	}
	
	
	/**
	* Get a parallel unit vector, pointing
	* from vertex1 to vertex2.
	*/
	public function GetDirectionVector(): b2Vec2
	{
		return m_direction;
	}
	
	/**
	* Returns a unit vector halfway between 
	* m_direction and m_prevEdge.m_direction.
	*/
	public function GetCorner1Vector(): b2Vec2
	{
		return m_cornerDir1;
	}
	
	/**
	* Returns a unit vector halfway between 
	* m_direction and m_nextEdge.m_direction.
	*/
	public function GetCorner2Vector(): b2Vec2
	{
		return m_cornerDir2;
	}
	
	/**
	* Returns true if the first corner of this edge
	* bends towards the solid side.
	*/
	public function Corner1IsConvex(): Boolean
	{
		return m_cornerConvex1;
	}
	
	/**
	* Returns true if the second corner of this edge
	* bends towards the solid side. 
	*/
	public function Corner2IsConvex(): Boolean
	{
		return m_cornerConvex2;
	}

	/**
	* Get the first vertex and apply the supplied transform.
	*/
	public function GetFirstVertex(xf: b2Transform): b2Vec2
	{
		//return b2Mul(xf, m_coreV1);
		var tMat:b2Mat22 = xf.R;
		return new b2Vec2(xf.position.x + (tMat.col1.x * m_coreV1.x + tMat.col2.x * m_coreV1.y),
		                  xf.position.y + (tMat.col1.y * m_coreV1.x + tMat.col2.y * m_coreV1.y));
	}
	
	/**
	* Get the next edge in the chain.
	*/
	public function GetNextEdge(): b2EdgeShape
	{
		return m_nextEdge;
	}
	
	/**
	* Get the previous edge in the chain.
	*/
	public function GetPrevEdge(): b2EdgeShape
	{
		return m_prevEdge;
	}

	private var s_supportVec:b2Vec2 = new b2Vec2();
	/**
	* Get the support point in the given world direction.
	* Use the supplied transform.
	*/
	public function Support(xf:b2Transform, dX:Number, dY:Number) : b2Vec2{
		var tMat:b2Mat22 = xf.R;
		//b2Vec2 v1 = b2Mul(xf, m_coreV1);
		var v1X:Number = xf.position.x + (tMat.col1.x * m_coreV1.x + tMat.col2.x * m_coreV1.y);
		var v1Y:Number = xf.position.y + (tMat.col1.y * m_coreV1.x + tMat.col2.y * m_coreV1.y);
		
		//b2Vec2 v2 = b2Mul(xf, m_coreV2);
		var v2X:Number = xf.position.x + (tMat.col1.x * m_coreV2.x + tMat.col2.x * m_coreV2.y);
		var v2Y:Number = xf.position.y + (tMat.col1.y * m_coreV2.x + tMat.col2.y * m_coreV2.y);
		
		if ((v1X * dX + v1Y * dY) > (v2X * dX + v2Y * dY)) {
			s_supportVec.x = v1X;
			s_supportVec.y = v1Y;
		} else {
			s_supportVec.x = v2X;
			s_supportVec.y = v2Y;
		}
		return s_supportVec;
	}
	
	//--------------- Internals Below -------------------

	/**
	* @private
	*/
	public function b2EdgeShape(v1: b2Vec2, v2: b2Vec2){
		super();
		m_type = e_edgeShape;
		
		m_prevEdge = null;
		m_nextEdge = null;
		
		m_v1 = v1;
		m_v2 = v2;
		
		m_direction.Set(m_v2.x - m_v1.x, m_v2.y - m_v1.y);
		m_length = m_direction.Normalize();
		m_normal.Set(m_direction.y, -m_direction.x);
		
		m_coreV1.Set(-b2Settings.b2_toiSlop * (m_normal.x - m_direction.x) + m_v1.x,
		             -b2Settings.b2_toiSlop * (m_normal.y - m_direction.y) + m_v1.y)
		m_coreV2.Set(-b2Settings.b2_toiSlop * (m_normal.x + m_direction.x) + m_v2.x,
		             -b2Settings.b2_toiSlop * (m_normal.y + m_direction.y) + m_v2.y)
		
		m_cornerDir1 = m_normal;
		m_cornerDir2.Set(-m_normal.x, -m_normal.y);
	}

	/**
	* @private
	*/
	b2internal function SetPrevEdge(edge: b2EdgeShape, core: b2Vec2, cornerDir: b2Vec2, convex: Boolean): void
	{
		m_prevEdge = edge;
		m_coreV1 = core;
		m_cornerDir1 = cornerDir;
		m_cornerConvex1 = convex;
	}
	
	/**
	* @private
	*/
	b2internal function SetNextEdge(edge: b2EdgeShape, core: b2Vec2, cornerDir: b2Vec2, convex: Boolean): void
	{
		m_nextEdge = edge;
		m_coreV2 = core;
		m_cornerDir2 = cornerDir;
		m_cornerConvex2 = convex;
	}

	b2internal var m_v1:b2Vec2 = new b2Vec2();
	b2internal var m_v2:b2Vec2 = new b2Vec2();
	
	b2internal var m_coreV1:b2Vec2 = new b2Vec2();
	b2internal var m_coreV2:b2Vec2 = new b2Vec2();
	
	b2internal var m_length:Number;
	
	b2internal var m_normal:b2Vec2 = new b2Vec2();
	
	b2internal var m_direction:b2Vec2 = new b2Vec2();
	
	b2internal var m_cornerDir1:b2Vec2 = new b2Vec2();
	
	b2internal var m_cornerDir2:b2Vec2 = new b2Vec2();
	
	b2internal var m_cornerConvex1:Boolean;
	b2internal var m_cornerConvex2:Boolean;
	
	b2internal var m_nextEdge:b2EdgeShape;
	b2internal var m_prevEdge:b2EdgeShape;
	
};

}
