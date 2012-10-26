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

package Box2D.Collision 
{

	import Box2D.Common.*;
	import Box2D.Common.Math.*;

internal class b2Simplex
{
	
public function b2Simplex()
{
	m_vertices[0] = m_v1;
	m_vertices[1] = m_v2;
	m_vertices[2] = m_v3;
}

public function ReadCache(cache:b2SimplexCache, 
			proxyA:b2DistanceProxy, transformA:b2Transform,
			proxyB:b2DistanceProxy, transformB:b2Transform):void
{
	b2Settings.b2Assert(0 <= cache.count && cache.count <= 3);
	
	var wALocal:b2Vec2;
	var wBLocal:b2Vec2;
	
	// Copy data from cache.
	m_count = cache.count;
	var vertices:Vector.<b2SimplexVertex> = m_vertices;
	for (var i:int = 0; i < m_count; i++)
	{
		var v:b2SimplexVertex = vertices[i];
		v.indexA = cache.indexA[i];
		v.indexB = cache.indexB[i];
		wALocal = proxyA.GetVertex(v.indexA);
		wBLocal = proxyB.GetVertex(v.indexB);
		v.wA = b2Math.MulX(transformA, wALocal);
		v.wB = b2Math.MulX(transformB, wBLocal);
		v.w = b2Math.SubtractVV(v.wB, v.wA);
		v.a = 0;
	}
	
	// Compute the new simplex metric, if it substantially different than
	// old metric then flush the simplex
	if (m_count > 1)
	{
		var metric1:Number = cache.metric;
		var metric2:Number = GetMetric();
		if (metric2 < .5 * metric1 || 2.0 * metric1 < metric2 || metric2 < Number.MIN_VALUE)
		{
			// Reset the simplex
			m_count = 0;
		}
	}
	
	// If the cache is empty or invalid
	if (m_count == 0)
	{
		v = vertices[0];
		v.indexA = 0;
		v.indexB = 0;
		wALocal = proxyA.GetVertex(0);
		wBLocal = proxyB.GetVertex(0);
		v.wA = b2Math.MulX(transformA, wALocal);
		v.wB = b2Math.MulX(transformB, wBLocal);
		v.w = b2Math.SubtractVV(v.wB, v.wA);
		m_count = 1;
	}
}

public function WriteCache(cache:b2SimplexCache):void
{
	cache.metric = GetMetric();
	cache.count = uint(m_count);
	var vertices:Vector.<b2SimplexVertex> = m_vertices;
	for (var i:int = 0; i < m_count; i++)
	{
		cache.indexA[i] = uint(vertices[i].indexA);
		cache.indexB[i] = uint(vertices[i].indexB);
	}
}

public function GetSearchDirection():b2Vec2
{
	switch(m_count)
	{
		case 1:
			return m_v1.w.GetNegative();
			
		case 2:
		{
			var e12:b2Vec2 = b2Math.SubtractVV(m_v2.w, m_v1.w);
			var sgn:Number = b2Math.CrossVV(e12, m_v1.w.GetNegative());
			if (sgn > 0.0)
			{
				// Origin is left of e12.
				return b2Math.CrossFV(1.0, e12);
			}else {
				// Origin is right of e12.
				return b2Math.CrossVF(e12, 1.0);
			}
		}
		default:
		b2Settings.b2Assert(false);
		return new b2Vec2();
	}
}

public function GetClosestPoint():b2Vec2
{
	switch(m_count)
	{
		case 0:
			b2Settings.b2Assert(false);
			return new b2Vec2();
		case 1:
			return m_v1.w;
		case 2:
			return new b2Vec2(
					m_v1.a * m_v1.w.x + m_v2.a * m_v2.w.x,
					m_v1.a * m_v1.w.y + m_v2.a * m_v2.w.y);
		default:
			b2Settings.b2Assert(false);
			return new b2Vec2();
	}
}

public function GetWitnessPoints(pA:b2Vec2, pB:b2Vec2):void
{
	switch(m_count)
	{
		case 0:
			b2Settings.b2Assert(false);
			break;
		case 1:
			pA.SetV(m_v1.wA);
			pB.SetV(m_v1.wB);
			break;
		case 2:
			pA.x = m_v1.a * m_v1.wA.x + m_v2.a * m_v2.wA.x;
			pA.y = m_v1.a * m_v1.wA.y + m_v2.a * m_v2.wA.y;
			pB.x = m_v1.a * m_v1.wB.x + m_v2.a * m_v2.wB.x;
			pB.y = m_v1.a * m_v1.wB.y + m_v2.a * m_v2.wB.y;
			break;
		case 3:
			pB.x = pA.x = m_v1.a * m_v1.wA.x + m_v2.a * m_v2.wA.x + m_v3.a * m_v3.wA.x;
			pB.y = pA.y = m_v1.a * m_v1.wA.y + m_v2.a * m_v2.wA.y + m_v3.a * m_v3.wA.y;
			break;
		default:
			b2Settings.b2Assert(false);
			break;
	}
}

public function GetMetric():Number
{
	switch (m_count)
	{
	case 0:
		b2Settings.b2Assert(false);
		return 0.0;

	case 1:
		return 0.0;

	case 2:
		return b2Math.SubtractVV(m_v1.w, m_v2.w).Length();

	case 3:
		return b2Math.CrossVV(b2Math.SubtractVV(m_v2.w, m_v1.w),b2Math.SubtractVV(m_v3.w, m_v1.w));

	default:
		b2Settings.b2Assert(false);
		return 0.0;
	}
}

// Solve a line segment using barycentric coordinates.
//
// p = a1 * w1 + a2 * w2
// a1 + a2 = 1
//
// The vector from the origin to the closest point on the line is
// perpendicular to the line.
// e12 = w2 - w1
// dot(p, e) = 0
// a1 * dot(w1, e) + a2 * dot(w2, e) = 0
//
// 2-by-2 linear system
// [1      1     ][a1] = [1]
// [w1.e12 w2.e12][a2] = [0]
//
// Define
// d12_1 =  dot(w2, e12)
// d12_2 = -dot(w1, e12)
// d12 = d12_1 + d12_2
//
// Solution
// a1 = d12_1 / d12
// a2 = d12_2 / d12
public function Solve2():void
{
	var w1:b2Vec2 = m_v1.w;
	var w2:b2Vec2 = m_v2.w;
	var e12:b2Vec2 = b2Math.SubtractVV(w2, w1);
	
	// w1 region
	var d12_2:Number = -(w1.x * e12.x + w1.y * e12.y);
	if (d12_2 <= 0.0)
	{
		// a2 <= 0, so we clamp it to 0
		m_v1.a = 1.0;
		m_count = 1;
		return;
	}
	
	// w2 region
	var d12_1:Number = (w2.x * e12.x + w2.y * e12.y);
	if (d12_1 <= 0.0)
	{
		// a1 <= 0, so we clamp it to 0
		m_v2.a = 1.0;
		m_count = 1;
		m_v1.Set(m_v2);
		return;
	}
	
	// Must be in e12 region.
	var inv_d12:Number = 1.0 / (d12_1 + d12_2);
	m_v1.a = d12_1 * inv_d12;
	m_v2.a = d12_2 * inv_d12;
	m_count = 2;
}

public function Solve3():void
{
	var w1:b2Vec2 = m_v1.w;
	var w2:b2Vec2 = m_v2.w;
	var w3:b2Vec2 = m_v3.w;
	
	// Edge12
	// [1      1     ][a1] = [1]
	// [w1.e12 w2.e12][a2] = [0]
	// a3 = 0
	var e12:b2Vec2 = b2Math.SubtractVV(w2, w1);
	var w1e12:Number = b2Math.Dot(w1, e12);
	var w2e12:Number = b2Math.Dot(w2, e12);
	var d12_1:Number = w2e12;
	var d12_2:Number = -w1e12;

	// Edge13
	// [1      1     ][a1] = [1]
	// [w1.e13 w3.e13][a3] = [0]
	// a2 = 0
	var e13:b2Vec2 = b2Math.SubtractVV(w3, w1);
	var w1e13:Number = b2Math.Dot(w1, e13);
	var w3e13:Number = b2Math.Dot(w3, e13);
	var d13_1:Number = w3e13;
	var d13_2:Number = -w1e13;

	// Edge23
	// [1      1     ][a2] = [1]
	// [w2.e23 w3.e23][a3] = [0]
	// a1 = 0
	var e23:b2Vec2 = b2Math.SubtractVV(w3, w2);
	var w2e23:Number = b2Math.Dot(w2, e23);
	var w3e23:Number = b2Math.Dot(w3, e23);
	var d23_1:Number = w3e23;
	var d23_2:Number = -w2e23;
	
	// Triangle123
	var n123:Number = b2Math.CrossVV(e12, e13);

	var d123_1:Number = n123 * b2Math.CrossVV(w2, w3);
	var d123_2:Number = n123 * b2Math.CrossVV(w3, w1);
	var d123_3:Number = n123 * b2Math.CrossVV(w1, w2);

	// w1 region
	if (d12_2 <= 0.0 && d13_2 <= 0.0)
	{
		m_v1.a = 1.0;
		m_count = 1;
		return;
	}

	// e12
	if (d12_1 > 0.0 && d12_2 > 0.0 && d123_3 <= 0.0)
	{
		var inv_d12:Number = 1.0 / (d12_1 + d12_2);
		m_v1.a = d12_1 * inv_d12;
		m_v2.a = d12_2 * inv_d12;
		m_count = 2;
		return;
	}

	// e13
	if (d13_1 > 0.0 && d13_2 > 0.0 && d123_2 <= 0.0)
	{
		var inv_d13:Number = 1.0 / (d13_1 + d13_2);
		m_v1.a = d13_1 * inv_d13;
		m_v3.a = d13_2 * inv_d13;
		m_count = 2;
		m_v2.Set(m_v3);
		return;
	}

	// w2 region
	if (d12_1 <= 0.0 && d23_2 <= 0.0)
	{
		m_v2.a = 1.0;
		m_count = 1;
		m_v1.Set(m_v2);
		return;
	}

	// w3 region
	if (d13_1 <= 0.0 && d23_1 <= 0.0)
	{
		m_v3.a = 1.0;
		m_count = 1;
		m_v1.Set(m_v3);
		return;
	}

	// e23
	if (d23_1 > 0.0 && d23_2 > 0.0 && d123_1 <= 0.0)
	{
		var inv_d23:Number = 1.0 / (d23_1 + d23_2);
		m_v2.a = d23_1 * inv_d23;
		m_v3.a = d23_2 * inv_d23;
		m_count = 2;
		m_v1.Set(m_v3);
		return;
	}

	// Must be in triangle123
	var inv_d123:Number = 1.0 / (d123_1 + d123_2 + d123_3);
	m_v1.a = d123_1 * inv_d123;
	m_v2.a = d123_2 * inv_d123;
	m_v3.a = d123_3 * inv_d123;
	m_count = 3;
}

public var m_v1:b2SimplexVertex = new b2SimplexVertex();
public var m_v2:b2SimplexVertex = new b2SimplexVertex();
public var m_v3:b2SimplexVertex = new b2SimplexVertex();
public var m_vertices:Vector.<b2SimplexVertex> = new Vector.<b2SimplexVertex>(3);
public var m_count:int;
}
	
}