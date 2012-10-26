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
use namespace b2internal;

/**
 * This is used to compute the current state of a contact manifold.
 */
public class b2WorldManifold 
{
	public function b2WorldManifold()
	{
		m_points = new Vector.<b2Vec2>(b2Settings.b2_maxManifoldPoints)
		for (var i:int = 0; i < b2Settings.b2_maxManifoldPoints; i++)
		{
			m_points[i] = new b2Vec2();
		}
	}
	/**
	 * Evaluate the manifold with supplied transforms. This assumes
	 * modest motion from the original state. This does not change the
	 * point count, impulses, etc. The radii must come from the shapes
	 * that generated the manifold.
	 */
	public function Initialize(manifold:b2Manifold,
					xfA:b2Transform, radiusA:Number,
					xfB:b2Transform, radiusB:Number):void
	{
		if (manifold.m_pointCount == 0)
		{
			return;
		}
		
		var i:int;
		var tVec:b2Vec2;
		var tMat:b2Mat22;
		var normalX:Number;
		var normalY:Number;
		var planePointX:Number;
		var planePointY:Number;
		var clipPointX:Number;
		var clipPointY:Number;
		
		switch(manifold.m_type)
		{
			case b2Manifold.e_circles:
			{
				//var pointA:b2Vec2 = b2Math.b2MulX(xfA, manifold.m_localPoint);
				tMat = xfA.R;
				tVec = manifold.m_localPoint;
				var pointAX:Number = xfA.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				var pointAY:Number = xfA.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				//var pointB:b2Vec2 = b2Math.b2MulX(xfB, manifold.m_points[0].m_localPoint);
				tMat = xfB.R;
				tVec = manifold.m_points[0].m_localPoint;
				var pointBX:Number = xfB.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				var pointBY:Number = xfB.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				
				var dX:Number = pointBX - pointAX;
				var dY:Number = pointBY - pointAY;
				var d2:Number = dX * dX + dY * dY;
				if (d2 > Number.MIN_VALUE * Number.MIN_VALUE)
				{
					var d:Number = Math.sqrt(d2);
					m_normal.x = dX/d;
					m_normal.y = dY/d;
				}else {
					m_normal.x = 1;
					m_normal.y = 0;
				}
				
				//b2Vec2 cA = pointA + radiusA * m_normal;
				var cAX:Number = pointAX + radiusA * m_normal.x;
				var cAY:Number = pointAY + radiusA * m_normal.y;
				//b2Vec2 cB = pointB - radiusB * m_normal;
				var cBX:Number = pointBX - radiusB * m_normal.x;
				var cBY:Number = pointBY - radiusB * m_normal.y;
				m_points[0].x = 0.5 * (cAX + cBX);
				m_points[0].y = 0.5 * (cAY + cBY);
			}
			break;
			case b2Manifold.e_faceA:
			{
				//normal = b2Math.b2MulMV(xfA.R, manifold.m_localPlaneNormal);
				tMat = xfA.R;
				tVec = manifold.m_localPlaneNormal;
				normalX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				normalY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				
				//planePoint = b2Math.b2MulX(xfA, manifold.m_localPoint);
				tMat = xfA.R;
				tVec = manifold.m_localPoint;
				planePointX = xfA.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				planePointY = xfA.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				
				// Ensure normal points from A to B
				m_normal.x = normalX;
				m_normal.y = normalY;
				for (i = 0; i < manifold.m_pointCount; i++)
				{
					//clipPoint = b2Math.b2MulX(xfB, manifold.m_points[i].m_localPoint);
					tMat = xfB.R;
					tVec = manifold.m_points[i].m_localPoint;
					clipPointX = xfB.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
					clipPointY = xfB.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
					
					//b2Vec2 cA = clipPoint + (radiusA - b2Dot(clipPoint - planePoint, normal)) * normal;
					//b2Vec2 cB = clipPoint - radiusB * normal;
					//m_points[i] = 0.5f * (cA + cB);
					m_points[i].x = clipPointX + 0.5 * (radiusA - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusB ) * normalX;
					m_points[i].y = clipPointY + 0.5 * (radiusA - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusB ) * normalY;
					
				}
			}
			break;
			case b2Manifold.e_faceB:
			{
				//normal = b2Math.b2MulMV(xfB.R, manifold.m_localPlaneNormal);
				tMat = xfB.R;
				tVec = manifold.m_localPlaneNormal;
				normalX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				normalY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				
				//planePoint = b2Math.b2MulX(xfB, manifold.m_localPoint);
				tMat = xfB.R;
				tVec = manifold.m_localPoint;
				planePointX = xfB.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
				planePointY = xfB.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
				
				// Ensure normal points from A to B
				m_normal.x = -normalX;
				m_normal.y = -normalY;
				for (i = 0; i < manifold.m_pointCount; i++)
				{
					//clipPoint = b2Math.b2MulX(xfA, manifold.m_points[i].m_localPoint);
					tMat = xfA.R;
					tVec = manifold.m_points[i].m_localPoint;
					clipPointX = xfA.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
					clipPointY = xfA.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
					
					//b2Vec2 cA = clipPoint - radiusA * normal;
					//b2Vec2 cB = clipPoint + (radiusB - b2Dot(clipPoint - planePoint, normal)) * normal;
					//m_points[i] = 0.5f * (cA + cB);
					m_points[i].x = clipPointX + 0.5 * (radiusB - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusA ) * normalX;
					m_points[i].y = clipPointY + 0.5 * (radiusB - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusA ) * normalY;
					
				}
			}
			break;
		}
	}

	/**
	 * world vector pointing from A to B
	 */
	public var m_normal:b2Vec2 = new b2Vec2();						
	/**
	 * world contact point (point of intersection)
	 */
	public var m_points:Vector.<b2Vec2>;
	
}
	
}