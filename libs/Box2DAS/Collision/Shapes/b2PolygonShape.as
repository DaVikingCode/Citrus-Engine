package Box2DAS.Collision.Shapes {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.display.*;
	
	
	public class b2PolygonShape extends b2Shape {
	
		public function b2PolygonShape(p:int = 0) {
			_ptr = (p == 0 ? lib.b2PolygonShape_new() : p);
			m_centroid = new b2Vec2(_ptr + 16);
		}
		
		public override function destroy():void {
			lib.b2PolygonShape_delete(_ptr);
			super.destroy();
		}
		
		/// Draw the polygon to a graphics object. You must set the fill/stroke style before calling.
		public override function Draw(g:Graphics, xf:XF, scale:Number = 1, options:Object = null):void {
			var vertices:Vector.<V2> = m_vertices;
			var vertexCount:Number = m_vertexCount;
			var v:V2 = xf.multiply(vertices[0]);
			g.moveTo(v.x * scale, v.y * scale);
			if(options && options.startPoint) {
				g.drawCircle(v.x * scale, v.y * scale, 3);			
			}
			for(var i:int = 1; i < vertexCount; ++i) {
				v = xf.multiply(vertices[i]);
				g.lineTo(v.x * scale, v.y * scale);
			}
			v = xf.multiply(vertices[0]);
			g.lineTo(v.x * scale, v.y * scale);
			//g.endFill();
		}
		
		/// Decompose a concave polygon into a bunch of convex ones. Pass it vector of vertices
		/// in [x1, y1, x2, y2...] format. Returns a vector list of b2PolygonShapes that represent
		/// the decomposition.
		public static function Decompose(v:Vector.<Number>):Vector.<b2PolygonShape> {
			var result:Vector.<b2PolygonShape> = new Vector.<b2PolygonShape>();			
			if(v.length <= 2) {
				return result;
			}
			lib.b2PolygonShape_Decompose(v);
			var p:Array = b2Base.getArr();
			for(var i:int = 0; i < p.length; ++i) {
				result[i] = new b2PolygonShape(p[i]);
			}
			return result;
		}
		
		/// Check the orientation of vertices. If they are in the wrong direction, flip them. Returns true if the vertecies need to be flipped.
		public static function CheckVertexDirection(v:Vector.<V2>):Boolean {
			if(v.length > 2) {
				var wind:Number = 0;
				var i:int = 0;
				while(wind == 0 && i < (v.length - 2)) {
					wind = v[i].winding(v[i + 1], v[i + 2]);
					++i;
				}
				if(wind < 0) {
					return false;
				}
			}
			return true;
		}
		
		/// If the vertices are in the wrong direction, flips them. Returns true if they were ok to start with, false if they were flipped.
		public static function EnsureCorrectVertexDirection(v:Vector.<V2>):Boolean {
			if(!CheckVertexDirection(v)) {
				ReverseVertices(v);
				return false;
			}
			return true;
		}
		
		/// Reverses the direction of a V2 vector.
		public static function ReverseVertices(v:Vector.<V2>):void {
			var low:uint = 0;
			var high:uint = v.length - 1;
			var tmp:Number;
			while(high > low) {
				tmp = v[low].x;
				v[low].x = v[high].x;
				v[high].x = tmp;
				tmp = v[low].y;
				v[low].y = v[high].y;
				v[high].y = tmp;
				++low;
				--high;
			}			
		}
		
		/// Copy vertices. This assumes the vertices define a convex polygon.
		/// It is assumed that the exterior is the the right of each edge.
		/// void Set(const b2Vec2* vertices, int32 vertexCount);
		public function Set(v:Vector.<V2>):void {
			m_vertices = v;
			var l:uint = v.length;
			// Compute normals. Ensure the edges have non-zero length.
			var n:Vector.<V2> = new Vector.<V2>();
			for (var i:uint = 0; i < l; ++i) {
				var edge:V2 = V2.subtract(v[i + 1 < l ? i + 1 : 0], v[i]);
				n[i] = V2.crossVN(edge, 1).normalize();
			}
			m_normals = n;
			m_centroid.v2 = ComputeCentroid(v);
		}

		/// Build vertices to represent an axis-aligned box.
		/// @param hx the half-width.
		/// @param hy the half-height.
		/// void SetAsBox(float32 hx, float32 hy);
		/// Build vertices to represent an oriented box.
		/// @param hx the half-width.
		/// @param hy the half-height.
		/// @param center the center of the box in local coordinates.
		/// @param angle the rotation of the box in local coordinates.
		/// void SetAsBox(float32 hx, float32 hy, const b2Vec2& center, float32 angle);
		public function SetAsBox(hx:Number, hy:Number, center:V2 = null, angle:Number = 0):void {
			var v:Vector.<V2> = Vector.<V2>([
				new V2(-hx, -hy),
				new V2(hx,  -hy),
				new V2(hx, hy),
				new V2(-hx, hy)
			]);
			var n:Vector.<V2> = Vector.<V2>([
				new V2(0.0, -1.0),
				new V2(1.0, 0.0),
				new V2(0.0, 1.0),
				new V2(-1.0, 0.0)
			]);
			m_centroid.x = 0;
			m_centroid.y = 0;
			if(angle != 0 || center != null) {
				var xf:XF = new XF();
				if(center) {
					m_centroid.v2 = center;
					xf.p.copy(center);
				}
				xf.angle = angle;
				for(var i:int = 0; i < 4; ++i) {
					v[i] = xf.multiply(v[i]);
					n[i] = xf.r.multiplyV(n[i]);
				}
			}
			m_vertices = v;
			m_normals = n;
		}
	
		/// Set this as a single edge.
		/// void SetAsEdge(const b2Vec2& v1, const b2Vec2& v2);
		public function SetAsEdge(v1:V2, v2:V2):void {
			m_vertices = Vector.<V2>([v1, v2]);
			var n0:V2 = V2.crossVN(V2.subtract(v2, v1), 1).normalize();
			m_normals = Vector.<V2>([n0, V2.invert(n0)]);
		}
		
		/// @see b2Shape::TestPoint
		/// bool TestPoint(const b2Transform& transform, const b2Vec2& p) const;
		public override function TestPoint(xf:XF, p:V2):Boolean {
			var pLocal:V2 = xf.r.multiplyVT(V2.subtract(p, xf.p));
			var v:Vector.<V2> = m_vertices;
			var n:Vector.<V2> = m_normals;
			for(var i:uint = 0; i < m_vertexCount; ++i) {
				var dot:Number = n[i].dot(V2.subtract(pLocal, v[i]));
				if (dot > 0) {
					return false;
				}
			}
			return true;
		}
	
		/// Implement b2Shape.
		/// void RayCast(b2RayCastOutput* output, const b2RayCastInput& input, const b2Transform& transform) const;
		public override function RayCast(output:*, input:*, transform:XF):Boolean {
			/// NOT IMPLEMENTED.
			return false;
		}
		
		/// @see b2Shape::ComputeAABB
		/// void ComputeAABB(b2AABB* aabb, const b2Transform& transform) const;
		public override function ComputeAABB(aabb:AABB, xf:XF):void {
			/// NOT IMPLEMENTED.
		}
	
		/// @see b2Shape::ComputeMass
		/// void ComputeMass(b2MassData* massData, float32 density) const;
		public override function ComputeMass(massData:b2MassData, density:Number):void {
			/// NOT IMPLEMENTED.
		}
		
		/// Get the supporting vertex index in the given direction.
		/// int32 GetSupport(const b2Vec2& d) const;
		public function GetSupport():int {
			/// NOT IMPLEMENTED.
			return 0;
		}
	
		/// Get the supporting vertex in the given direction.
		/// const b2Vec2& GetSupportVertex(const b2Vec2& d) const;
		public function GetSupportVertex():int {
			/// NOT IMPLEMENTED.
			return 0;
		}
	
		/// Get the vertex count.
		/// int32 GetVertexCount() const { return m_vertexCount; }
		public function GetVertexCount():uint {
			return m_vertexCount;
		}
	
		/// Get a vertex by index.
		/// const b2Vec2& GetVertex(int32 index) const;
		public function GetVertex(i:uint):V2 {
			return m_vertices[i];
		}
		
		///static b2Vec2 ComputeCentroid(const b2Vec2* vs, int32 count)
		public static function ComputeCentroid(vs:Vector.<V2>):V2 {
			var l:Number = vs.length;
			if(l == 2) {
				return V2.subtract(vs[1], vs[0]);
			}
			var inv3:Number = 1.0 / 3.0;
			var pRef:V2 = new V2();
			var area:Number = 0;
			var c:V2 = new V2();
			for(var i:uint = 0; i < l; ++i) {
				// Triangle vertices.
				var p1:V2 = pRef;
				var p2:V2 = vs[i];
				var p3:V2 = i + 1 < l ? vs[i+1] : vs[0];
		
				var e1:V2 = V2.subtract(p2, p1);
				var e2:V2 = V2.subtract(p3, p1);
		
				var D:Number = e1.cross(e2);
		
				var triangleArea:Number = D / 2;
				area += triangleArea;
		
				// Area weighted centroid
				c.add(V2.add(p1, p2).add(p3).multiplyN(triangleArea * inv3));
			}
			c.multiplyN(1 / area);
			return c;
		}
		
		/// @see b2Shape::ComputeSubmergedArea
		public override function ComputeSubmergedArea(normal:V2, offset:Number, xf:XF, c:V2):Number {
			//Transform plane into shape co-ordinates
			var normalL:V2 = xf.r.multiplyVT(normal);
			var offsetL:Number = offset - normal.dot(xf.p);
			
			var depths:Array = [];
			var diveCount:int = 0;
			var intoIndex:int = -1;
			var outoIndex:int = -1;
			
			var v:Vector.<V2> = m_vertices;
			
			var tVec:V2 = null;
			var lastSubmerged:Boolean = false;
			var i:int;
			for(i = 0; i < v.length; i++) {
				depths[i] = normalL.dot(v[i]) - offsetL;
				var isSubmerged:Boolean = depths[i] < 0;
				if(i > 0) {
					if(isSubmerged) {
						if(!lastSubmerged) {
							intoIndex = i - 1;
							diveCount++;
						}
					}
					else {
						if(lastSubmerged) {
							outoIndex = i - 1;
							diveCount++;
						}
					}
				}
				lastSubmerged = isSubmerged;
			}
			switch(diveCount) {
				case 0:
					if(lastSubmerged) {
						c.copy(xf.multiply(m_centroid.v2));
						return m_area;
					}
					else { //Completely dry
						return 0;
					}
					break;
				case 1:
					if(intoIndex == -1) {
						intoIndex = m_vertexCount - 1;
					}
					else {
						outoIndex = m_vertexCount - 1;
					}
					break;
			}
			var intoIndex2:int = (intoIndex + 1) % m_vertexCount;
			var outoIndex2:int = (outoIndex + 1) % m_vertexCount;
			
			var intoLambda:Number = (0 - depths[intoIndex]) / (depths[intoIndex2] - depths[intoIndex]);
			var outoLambda:Number = (0 - depths[outoIndex]) / (depths[outoIndex2] - depths[outoIndex]);
			
			var intoVec:V2 = new V2(
				v[intoIndex].x * (1 - intoLambda) + v[intoIndex2].x * intoLambda,
				v[intoIndex].y * (1 - intoLambda) + v[intoIndex2].y * intoLambda
			);
			var outoVec:V2 = new V2(
				v[outoIndex].x * (1 - outoLambda) + v[outoIndex2].x * outoLambda,
				v[outoIndex].y * (1 - outoLambda) + v[outoIndex2].y * outoLambda
			);
			
			//Initialize accumulator
			var area:Number = 0;
			c.zero();
			var p2:V2 = v[intoIndex2];
			var p3:V2;
			
			var k_inv3:Number = 1.0 / 3.0;
			
			//An awkward loop from intoIndex2+1 to outIndex2
			i = intoIndex2;
			while(i != outoIndex2) {
				i= (i + 1) % m_vertexCount;
				if(i == outoIndex2) {
					p3 = outoVec;
				}
				else {
					p3 = v[i];
				}
				//Add the triangle formed by intoVec,p2,p3
				//b2Vec2 e1 = p2 - p1;
				var e1X:Number = p2.x - intoVec.x;
				var e1Y:Number = p2.y - intoVec.y;
				//b2Vec2 e2 = p3 - p1;
				var e2X:Number = p3.x - intoVec.x;
				var e2Y:Number = p3.y - intoVec.y;
				
				//float32 D = b2Cross(e1, e2);
				var D:Number = e1X * e2Y - e1Y * e2X;
				
				//float32 triangleArea = 0.5f * D;
				var triangleArea:Number = 0.5 * D;
				area += triangleArea;
				
				// Area weighted centroid
				//center += triangleArea * k_inv3 * (p1 + p2 + p3);
				c.x += triangleArea * k_inv3 * (intoVec.x + p2.x + p3.x);
				c.y += triangleArea * k_inv3 * (intoVec.y + p2.y + p3.y);
				p2 = p3;
			}
			
			//Normalize and transform centroid
			c.x /= area;
			c.y /= area;
			
			c.copy(xf.multiply(c));
			

			
			return area;
		}
		
		public var m_centroid:b2Vec2;
		public function get m_vertices():Vector.<V2> { return readVertices(_ptr + 24, m_vertexCount); }
		public function set m_vertices(v:Vector.<V2>):void { writeVertices(_ptr + 24, v); m_vertexCount = v.length; }
		public function get m_normals():Vector.<V2> { return readVertices(_ptr + 88, m_vertexCount); }
		public function set m_normals(v:Vector.<V2>):void { writeVertices(_ptr + 88, v); m_vertexCount = v.length; }
		public function get m_vertexCount():int { return mem._mr32(_ptr + 152); }
		public function set m_vertexCount(v:int):void { mem._mw32(_ptr + 152, v); }
	
	}
}