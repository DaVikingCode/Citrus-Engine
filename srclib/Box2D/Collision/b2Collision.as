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

package Box2D.Collision{

	import Box2D.Collision.Shapes.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
use namespace b2internal;


/**
* @private
*/
public class b2Collision{
	
	// Null feature
	static public const b2_nullFeature:uint = 0x000000ff;//UCHAR_MAX;
	
	// Sutherland-Hodgman clipping.
	static public function ClipSegmentToLine(vOut:Vector.<ClipVertex>, vIn:Vector.<ClipVertex>, normal:b2Vec2, offset:Number):int
	{
		var cv:ClipVertex;
		
		// Start with no output points
		var numOut:int = 0;
		
		cv = vIn[0];
		var vIn0:b2Vec2 = cv.v;
		cv = vIn[1];
		var vIn1:b2Vec2 = cv.v;
		
		// Calculate the distance of end points to the line
		var distance0:Number = normal.x * vIn0.x + normal.y * vIn0.y - offset;
		var distance1:Number = normal.x * vIn1.x + normal.y * vIn1.y - offset;
		
		// If the points are behind the plane
		if (distance0 <= 0.0) vOut[numOut++].Set(vIn[0]);
		if (distance1 <= 0.0) vOut[numOut++].Set(vIn[1]);
		
		// If the points are on different sides of the plane
		if (distance0 * distance1 < 0.0)
		{
			// Find intersection point of edge and plane
			var interp:Number = distance0 / (distance0 - distance1);
			// expanded for performance 
			// vOut[numOut].v = vIn[0].v + interp * (vIn[1].v - vIn[0].v);
			cv = vOut[numOut];
			var tVec:b2Vec2 = cv.v;
			tVec.x = vIn0.x + interp * (vIn1.x - vIn0.x);
			tVec.y = vIn0.y + interp * (vIn1.y - vIn0.y);
			cv = vOut[numOut];
			var cv2: ClipVertex;
			if (distance0 > 0.0)
			{
				cv2 = vIn[0];
				cv.id = cv2.id;
			}
			else
			{
				cv2 = vIn[1];
				cv.id = cv2.id;
			}
			++numOut;
		}
		
		return numOut;
	}
	
	
	// Find the separation between poly1 and poly2 for a give edge normal on poly1.
	static public function EdgeSeparation(	poly1:b2PolygonShape, xf1:b2Transform, edge1:int, 
											poly2:b2PolygonShape, xf2:b2Transform):Number
	{
		var count1:int = poly1.m_vertexCount;
		var vertices1:Vector.<b2Vec2> = poly1.m_vertices;
		var normals1:Vector.<b2Vec2> = poly1.m_normals;
		
		var count2:int = poly2.m_vertexCount;
		var vertices2:Vector.<b2Vec2> = poly2.m_vertices;
		
		//b2Assert(0 <= edge1 && edge1 < count1);
		
		var tMat:b2Mat22;
		var tVec:b2Vec2;
		
		// Convert normal from poly1's frame into poly2's frame.
		//b2Vec2 normal1World = b2Mul(xf1.R, normals1[edge1]);
		tMat = xf1.R;
		tVec = normals1[edge1];
		var normal1WorldX:Number = (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		var normal1WorldY:Number = (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		//b2Vec2 normal1 = b2MulT(xf2.R, normal1World);
		tMat = xf2.R;
		var normal1X:Number = (tMat.col1.x * normal1WorldX + tMat.col1.y * normal1WorldY);
		var normal1Y:Number = (tMat.col2.x * normal1WorldX + tMat.col2.y * normal1WorldY);
		
		// Find support vertex on poly2 for -normal.
		var index:int = 0;
		var minDot:Number = Number.MAX_VALUE;
		for (var i:int = 0; i < count2; ++i)
		{
			//float32 dot = b2Dot(poly2->m_vertices[i], normal1);
			tVec = vertices2[i];
			var dot:Number = tVec.x * normal1X + tVec.y * normal1Y;
			if (dot < minDot)
			{
				minDot = dot;
				index = i;
			}
		}
		
		//b2Vec2 v1 = b2Mul(xf1, vertices1[edge1]);
		tVec = vertices1[edge1];
		tMat = xf1.R;
		var v1X:Number = xf1.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		var v1Y:Number = xf1.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		//b2Vec2 v2 = b2Mul(xf2, vertices2[index]);
		tVec = vertices2[index];
		tMat = xf2.R;
		var v2X:Number = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		var v2Y:Number = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		
		//var separation:Number = b2Math.b2Dot( b2Math.SubtractVV( v2, v1 ) , normal);
		v2X -= v1X;
		v2Y -= v1Y;
		//float32 separation = b2Dot(v2 - v1, normal1World);
		var separation:Number = v2X * normal1WorldX + v2Y * normal1WorldY;
		return separation;
	}
	
	
	
	
	// Find the max separation between poly1 and poly2 using edge normals
	// from poly1.
	static public function FindMaxSeparation(edgeIndex:Vector.<int>, 
											poly1:b2PolygonShape, xf1:b2Transform, 
											poly2:b2PolygonShape, xf2:b2Transform):Number
	{
		var count1:int = poly1.m_vertexCount;
		var normals1:Vector.<b2Vec2> = poly1.m_normals;
		
		var tVec:b2Vec2;
		var tMat:b2Mat22;
		
		// Vector pointing from the centroid of poly1 to the centroid of poly2.
		//b2Vec2 d = b2Mul(xf2, poly2->m_centroid) - b2Mul(xf1, poly1->m_centroid);
		tMat = xf2.R;
		tVec = poly2.m_centroid;
		var dX:Number = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		var dY:Number = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		tMat = xf1.R;
		tVec = poly1.m_centroid;
		dX -= xf1.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		dY -= xf1.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		
		//b2Vec2 dLocal1 = b2MulT(xf1.R, d);
		var dLocal1X:Number = (dX * xf1.R.col1.x + dY * xf1.R.col1.y);
		var dLocal1Y:Number = (dX * xf1.R.col2.x + dY * xf1.R.col2.y);
		
		// Get support vertex as a hint for our search
		var edge:int = 0;
		var maxDot:Number = -Number.MAX_VALUE;
		for (var i:int = 0; i < count1; ++i)
		{
			//var dot:Number = b2Math.b2Dot(normals1[i], dLocal1);
			tVec = normals1[i];
			var dot:Number = (tVec.x * dLocal1X + tVec.y * dLocal1Y);
			if (dot > maxDot)
			{
				maxDot = dot;
				edge = i;
			}
		}
		
		// Get the separation for the edge normal.
		var s:Number = EdgeSeparation(poly1, xf1, edge, poly2, xf2);
		
		// Check the separation for the previous edge normal.
		var prevEdge:int = edge - 1 >= 0 ? edge - 1 : count1 - 1;
		var sPrev:Number = EdgeSeparation(poly1, xf1, prevEdge, poly2, xf2);
		
		// Check the separation for the next edge normal.
		var nextEdge:int = edge + 1 < count1 ? edge + 1 : 0;
		var sNext:Number = EdgeSeparation(poly1, xf1, nextEdge, poly2, xf2);
		
		// Find the best edge and the search direction.
		var bestEdge:int;
		var bestSeparation:Number;
		var increment:int;
		if (sPrev > s && sPrev > sNext)
		{
			increment = -1;
			bestEdge = prevEdge;
			bestSeparation = sPrev;
		}
		else if (sNext > s)
		{
			increment = 1;
			bestEdge = nextEdge;
			bestSeparation = sNext;
		}
		else
		{
			// pointer out
			edgeIndex[0] = edge;
			return s;
		}
		
		// Perform a local search for the best edge normal.
		while (true)
		{
			
			if (increment == -1)
				edge = bestEdge - 1 >= 0 ? bestEdge - 1 : count1 - 1;
			else
				edge = bestEdge + 1 < count1 ? bestEdge + 1 : 0;
			
			s = EdgeSeparation(poly1, xf1, edge, poly2, xf2);
			
			if (s > bestSeparation)
			{
				bestEdge = edge;
				bestSeparation = s;
			}
			else
			{
				break;
			}
		}
		
		// pointer out
		edgeIndex[0] = bestEdge;
		return bestSeparation;
	}
	
	
	
	static public function FindIncidentEdge(c:Vector.<ClipVertex>, 
											poly1:b2PolygonShape, xf1:b2Transform, edge1:int, 
											poly2:b2PolygonShape, xf2:b2Transform) : void
	{
		var count1:int = poly1.m_vertexCount;
		var normals1:Vector.<b2Vec2> = poly1.m_normals;
		
		var count2:int = poly2.m_vertexCount;
		var vertices2:Vector.<b2Vec2> = poly2.m_vertices;
		var normals2:Vector.<b2Vec2> = poly2.m_normals;
		
		//b2Assert(0 <= edge1 && edge1 < count1);
		
		var tMat:b2Mat22;
		var tVec:b2Vec2;
		
		// Get the normal of the reference edge in poly2's frame.
		//b2Vec2 normal1 = b2MulT(xf2.R, b2Mul(xf1.R, normals1[edge1]));
		tMat = xf1.R;
		tVec = normals1[edge1];
		var normal1X:Number = (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		var normal1Y:Number = (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		tMat = xf2.R;
		var tX:Number = (tMat.col1.x * normal1X + tMat.col1.y * normal1Y);
		normal1Y = 		(tMat.col2.x * normal1X + tMat.col2.y * normal1Y);
		normal1X = tX;
		
		// Find the incident edge on poly2.
		var index:int = 0;
		var minDot:Number = Number.MAX_VALUE;
		for (var i:int = 0; i < count2; ++i)
		{
			//var dot:Number = b2Dot(normal1, normals2[i]);
			tVec = normals2[i];
			var dot:Number = (normal1X * tVec.x + normal1Y * tVec.y);
			if (dot < minDot)
			{
				minDot = dot;
				index = i;
			}
		}
		
		var tClip:ClipVertex;
		// Build the clip vertices for the incident edge.
		var i1:int = index;
		var i2:int = i1 + 1 < count2 ? i1 + 1 : 0;
		
		tClip = c[0];
		//c[0].v = b2Mul(xf2, vertices2[i1]);
		tVec = vertices2[i1];
		tMat = xf2.R;
		tClip.v.x = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		tClip.v.y = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		
		tClip.id.features.referenceEdge = edge1;
		tClip.id.features.incidentEdge = i1;
		tClip.id.features.incidentVertex = 0;
		
		tClip = c[1];
		//c[1].v = b2Mul(xf2, vertices2[i2]);
		tVec = vertices2[i2];
		tMat = xf2.R;
		tClip.v.x = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		tClip.v.y = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		
		tClip.id.features.referenceEdge = edge1;
		tClip.id.features.incidentEdge = i2;
		tClip.id.features.incidentVertex = 1;
	}
	
	
	private static function MakeClipPointVector():Vector.<ClipVertex>
	{
		var r:Vector.<ClipVertex> = new Vector.<ClipVertex>(2);
		r[0] = new ClipVertex();
		r[1] = new ClipVertex();
		return r;
	}
	private static var s_incidentEdge:Vector.<ClipVertex> = MakeClipPointVector();
	private static var s_clipPoints1:Vector.<ClipVertex> = MakeClipPointVector();
	private static var s_clipPoints2:Vector.<ClipVertex> = MakeClipPointVector();
	private static var s_edgeAO:Vector.<int> = new Vector.<int>(1);
	private static var s_edgeBO:Vector.<int> = new Vector.<int>(1);
	private static var s_localTangent:b2Vec2 = new b2Vec2();
	private static var s_localNormal:b2Vec2 = new b2Vec2();
	private static var s_planePoint:b2Vec2 = new b2Vec2();
	private static var s_normal:b2Vec2 = new b2Vec2();
	private static var s_tangent:b2Vec2 = new b2Vec2();
	private static var s_tangent2:b2Vec2 = new b2Vec2();
	private static var s_v11:b2Vec2 = new b2Vec2();
	private static var s_v12:b2Vec2 = new b2Vec2();
	// Find edge normal of max separation on A - return if separating axis is found
	// Find edge normal of max separation on B - return if separation axis is found
	// Choose reference edge as min(minA, minB)
	// Find incident edge
	// Clip
	static private var b2CollidePolyTempVec:b2Vec2 = new b2Vec2();
	// The normal points from 1 to 2
	static public function CollidePolygons(manifold:b2Manifold, 
											polyA:b2PolygonShape, xfA:b2Transform,
											polyB:b2PolygonShape, xfB:b2Transform) : void
	{
		var cv: ClipVertex;
		
		manifold.m_pointCount = 0;
		var totalRadius:Number = polyA.m_radius + polyB.m_radius;

		var edgeA:int = 0;
		s_edgeAO[0] = edgeA;
		var separationA:Number = FindMaxSeparation(s_edgeAO, polyA, xfA, polyB, xfB);
		edgeA = s_edgeAO[0];
		if (separationA > totalRadius)
			return;

		var edgeB:int = 0;
		s_edgeBO[0] = edgeB;
		var separationB:Number = FindMaxSeparation(s_edgeBO, polyB, xfB, polyA, xfA);
		edgeB = s_edgeBO[0];
		if (separationB > totalRadius)
			return;

		var poly1:b2PolygonShape;	// reference poly
		var poly2:b2PolygonShape;	// incident poly
		var xf1:b2Transform;
		var xf2:b2Transform;
		var edge1:int;		// reference edge
		var flip:uint;
		const k_relativeTol:Number = 0.98;
		const k_absoluteTol:Number = 0.001;
		var tMat:b2Mat22;

		if (separationB > k_relativeTol * separationA + k_absoluteTol)
		{
			poly1 = polyB;
			poly2 = polyA;
			xf1 = xfB;
			xf2 = xfA;
			edge1 = edgeB;
			manifold.m_type = b2Manifold.e_faceB;
			flip = 1;
		}
		else
		{
			poly1 = polyA;
			poly2 = polyB;
			xf1 = xfA;
			xf2 = xfB;
			edge1 = edgeA;
			manifold.m_type = b2Manifold.e_faceA;
			flip = 0;
		}

		var incidentEdge:Vector.<ClipVertex> = s_incidentEdge; 
		FindIncidentEdge(incidentEdge, poly1, xf1, edge1, poly2, xf2);

		var count1:int = poly1.m_vertexCount;
		var vertices1:Vector.<b2Vec2> = poly1.m_vertices;

		var local_v11:b2Vec2 = vertices1[edge1];
		var local_v12:b2Vec2;
		if (edge1 + 1 < count1) {
			local_v12 = vertices1[int(edge1+1)];
		} else {
			local_v12 = vertices1[0];
		}

		var localTangent:b2Vec2 = s_localTangent;
		localTangent.Set(local_v12.x - local_v11.x, local_v12.y - local_v11.y);
		localTangent.Normalize();
		
		var localNormal:b2Vec2 = s_localNormal;
		localNormal.x = localTangent.y;
		localNormal.y = -localTangent.x;
		
		var planePoint:b2Vec2 = s_planePoint;
		planePoint.Set(0.5 * (local_v11.x + local_v12.x), 0.5 * (local_v11.y + local_v12.y));
		
		var tangent:b2Vec2 = s_tangent;
		//tangent = b2Math.b2MulMV(xf1.R, localTangent);
		tMat = xf1.R;
		tangent.x = (tMat.col1.x * localTangent.x + tMat.col2.x * localTangent.y);
		tangent.y = (tMat.col1.y * localTangent.x + tMat.col2.y * localTangent.y);
		var tangent2:b2Vec2 = s_tangent2;
		tangent2.x = - tangent.x;
		tangent2.y = - tangent.y;
		var normal:b2Vec2 = s_normal;
		normal.x = tangent.y;
		normal.y = -tangent.x;

		//v11 = b2Math.MulX(xf1, local_v11);
		//v12 = b2Math.MulX(xf1, local_v12);
		var v11:b2Vec2 = s_v11;
		var v12:b2Vec2 = s_v12;
		v11.x = xf1.position.x + (tMat.col1.x * local_v11.x + tMat.col2.x * local_v11.y);
		v11.y = xf1.position.y + (tMat.col1.y * local_v11.x + tMat.col2.y * local_v11.y);
		v12.x = xf1.position.x + (tMat.col1.x * local_v12.x + tMat.col2.x * local_v12.y);
		v12.y = xf1.position.y + (tMat.col1.y * local_v12.x + tMat.col2.y * local_v12.y);

		// Face offset
		var frontOffset:Number = normal.x * v11.x + normal.y * v11.y;
		// Side offsets, extended by polytope skin thickness
		var sideOffset1:Number = -tangent.x * v11.x - tangent.y * v11.y + totalRadius;
		var sideOffset2:Number = tangent.x * v12.x + tangent.y * v12.y + totalRadius;

		// Clip incident edge against extruded edge1 side edges.
		var clipPoints1:Vector.<ClipVertex> = s_clipPoints1;
		var clipPoints2:Vector.<ClipVertex> = s_clipPoints2;
		var np:int;

		// Clip to box side 1
		//np = ClipSegmentToLine(clipPoints1, incidentEdge, -tangent, sideOffset1);
		np = ClipSegmentToLine(clipPoints1, incidentEdge, tangent2, sideOffset1);

		if (np < 2)
			return;

		// Clip to negative box side 1
		np = ClipSegmentToLine(clipPoints2, clipPoints1,  tangent, sideOffset2);

		if (np < 2)
			return;

		// Now clipPoints2 contains the clipped points.
		manifold.m_localPlaneNormal.SetV(localNormal);
		manifold.m_localPoint.SetV(planePoint);
		
		var pointCount:int = 0;
		for (var i:int = 0; i < b2Settings.b2_maxManifoldPoints;++i)
		{
			cv = clipPoints2[i];
			var separation:Number = normal.x * cv.v.x + normal.y * cv.v.y - frontOffset;
			if (separation <= totalRadius)
			{
				var cp:b2ManifoldPoint = manifold.m_points[ pointCount ];
				//cp.m_localPoint = b2Math.b2MulXT(xf2, cv.v);
				tMat = xf2.R;
				var tX:Number = cv.v.x - xf2.position.x;
				var tY:Number = cv.v.y - xf2.position.y;
				cp.m_localPoint.x = (tX * tMat.col1.x + tY * tMat.col1.y );
				cp.m_localPoint.y = (tX * tMat.col2.x + tY * tMat.col2.y );
				cp.m_id.Set(cv.id);
				cp.m_id.features.flip = flip;
				++pointCount;
			}
		}
		
		manifold.m_pointCount = pointCount;
	}
	
	
	
	static public function CollideCircles(
		manifold:b2Manifold, 
		circle1:b2CircleShape, xf1:b2Transform, 
		circle2:b2CircleShape, xf2:b2Transform) : void
	{
		manifold.m_pointCount = 0;
		
		var tMat:b2Mat22;
		var tVec:b2Vec2;
		
		//b2Vec2 p1 = b2Mul(xf1, circle1->m_p);
		tMat = xf1.R; tVec = circle1.m_p;
		var p1X:Number = xf1.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		var p1Y:Number = xf1.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		//b2Vec2 p2 = b2Mul(xf2, circle2->m_p);
		tMat = xf2.R; tVec = circle2.m_p;
		var p2X:Number = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		var p2Y:Number = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		//b2Vec2 d = p2 - p1;
		var dX:Number = p2X - p1X;
		var dY:Number = p2Y - p1Y;
		//var distSqr:Number = b2Math.b2Dot(d, d);
		var distSqr:Number = dX * dX + dY * dY;
		var radius:Number = circle1.m_radius + circle2.m_radius;
		if (distSqr > radius * radius)
		{
			return;
		}
		manifold.m_type = b2Manifold.e_circles;
		manifold.m_localPoint.SetV(circle1.m_p);
		manifold.m_localPlaneNormal.SetZero();
		manifold.m_pointCount = 1;
		manifold.m_points[0].m_localPoint.SetV(circle2.m_p);
		manifold.m_points[0].m_id.key = 0;
	}
	
	
	
	static public function CollidePolygonAndCircle(
		manifold:b2Manifold, 
		polygon:b2PolygonShape, xf1:b2Transform,
		circle:b2CircleShape, xf2:b2Transform) : void
	{
		manifold.m_pointCount = 0;
		var tPoint:b2ManifoldPoint;
		
		var dX:Number;
		var dY:Number;
		var positionX:Number;
		var positionY:Number;
		
		var tVec:b2Vec2;
		var tMat:b2Mat22;
		
		// Compute circle position in the frame of the polygon.
		//b2Vec2 c = b2Mul(xf2, circle->m_localPosition);
		tMat = xf2.R;
		tVec = circle.m_p;
		var cX:Number = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		var cY:Number = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		
		//b2Vec2 cLocal = b2MulT(xf1, c);
		dX = cX - xf1.position.x;
		dY = cY - xf1.position.y;
		tMat = xf1.R;
		var cLocalX:Number = (dX * tMat.col1.x + dY * tMat.col1.y);
		var cLocalY:Number = (dX * tMat.col2.x + dY * tMat.col2.y);
		
		var dist:Number;
		
		// Find the min separating edge.
		var normalIndex:int = 0;
		var separation:Number = -Number.MAX_VALUE;
		var radius:Number = polygon.m_radius + circle.m_radius;
		var vertexCount:int = polygon.m_vertexCount;
		var vertices:Vector.<b2Vec2> = polygon.m_vertices;
		var normals:Vector.<b2Vec2> = polygon.m_normals;

		for (var i:int = 0; i < vertexCount; ++i)
		{
			//float32 s = b2Dot(normals[i], cLocal - vertices[i]);
			tVec = vertices[i];
			dX = cLocalX-tVec.x;
			dY = cLocalY-tVec.y;
			tVec = normals[i];
			var s:Number = tVec.x * dX + tVec.y * dY;
			
			if (s > radius)
			{
				// Early out.
				return;
			}
			
			if (s > separation)
			{
				separation = s;
				normalIndex = i;
			}
		}
		// Vertices that subtend the incident face
		var vertIndex1:int = normalIndex;
		var vertIndex2:int = vertIndex1 + 1 < vertexCount?vertIndex1 + 1:0;
		var v1:b2Vec2 = vertices[vertIndex1];
		var v2:b2Vec2 = vertices[vertIndex2];
		
		// If the center is inside the polygon ...
		if (separation < Number.MIN_VALUE)
		{
			manifold.m_pointCount = 1;
			manifold.m_type = b2Manifold.e_faceA;
			manifold.m_localPlaneNormal.SetV(normals[normalIndex]);
			manifold.m_localPoint.x = 0.5 * (v1.x + v2.x);
			manifold.m_localPoint.y = 0.5 * (v1.y + v2.y);
			manifold.m_points[0].m_localPoint.SetV(circle.m_p);
			manifold.m_points[0].m_id.key = 0;
			return;
		}
		
		// Project the circle center onto the edge segment.
		var u1:Number = (cLocalX - v1.x) * (v2.x - v1.x) + (cLocalY - v1.y) * (v2.y - v1.y);
		var u2:Number = (cLocalX - v2.x) * (v1.x - v2.x) + (cLocalY - v2.y) * (v1.y - v2.y);
		if (u1 <= 0.0)
		{
			if ((cLocalX-v1.x)*(cLocalX-v1.x)+(cLocalY-v1.y)*(cLocalY-v1.y) > radius * radius)
				return;
			manifold.m_pointCount = 1;
			manifold.m_type = b2Manifold.e_faceA;
			manifold.m_localPlaneNormal.x = cLocalX - v1.x;
			manifold.m_localPlaneNormal.y = cLocalY - v1.y;
			manifold.m_localPlaneNormal.Normalize();
			manifold.m_localPoint.SetV(v1);
			manifold.m_points[0].m_localPoint.SetV(circle.m_p);
			manifold.m_points[0].m_id.key = 0;
		}
		else if (u2 <= 0)
		{
			if ((cLocalX-v2.x)*(cLocalX-v2.x)+(cLocalY-v2.y)*(cLocalY-v2.y) > radius * radius)
				return;
			manifold.m_pointCount = 1;
			manifold.m_type = b2Manifold.e_faceA;
			manifold.m_localPlaneNormal.x = cLocalX - v2.x;
			manifold.m_localPlaneNormal.y = cLocalY - v2.y;
			manifold.m_localPlaneNormal.Normalize();
			manifold.m_localPoint.SetV(v2);
			manifold.m_points[0].m_localPoint.SetV(circle.m_p);
			manifold.m_points[0].m_id.key = 0;
		}
		else
		{
			var faceCenterX:Number = 0.5 * (v1.x + v2.x);
			var faceCenterY:Number = 0.5 * (v1.y + v2.y);
			separation = (cLocalX - faceCenterX) * normals[vertIndex1].x + (cLocalY - faceCenterY) * normals[vertIndex1].y;
			if (separation > radius)
				return;
			manifold.m_pointCount = 1;
			manifold.m_type = b2Manifold.e_faceA;
			manifold.m_localPlaneNormal.x = normals[vertIndex1].x;
			manifold.m_localPlaneNormal.y = normals[vertIndex1].y;
			manifold.m_localPlaneNormal.Normalize();
			manifold.m_localPoint.Set(faceCenterX,faceCenterY);
			manifold.m_points[0].m_localPoint.SetV(circle.m_p);
			manifold.m_points[0].m_id.key = 0;
		}
	}




	static public function TestOverlap(a:b2AABB, b:b2AABB):Boolean
	{
		var t1:b2Vec2 = b.lowerBound;
		var t2:b2Vec2 = a.upperBound;
		//d1 = b2Math.SubtractVV(b.lowerBound, a.upperBound);
		var d1X:Number = t1.x - t2.x;
		var d1Y:Number = t1.y - t2.y;
		//d2 = b2Math.SubtractVV(a.lowerBound, b.upperBound);
		t1 = a.lowerBound;
		t2 = b.upperBound;
		var d2X:Number = t1.x - t2.x;
		var d2Y:Number = t1.y - t2.y;
		
		if (d1X > 0.0 || d1Y > 0.0)
			return false;
		
		if (d2X > 0.0 || d2Y > 0.0)
			return false;
		
		return true;
	}
	
	
	

}

}
