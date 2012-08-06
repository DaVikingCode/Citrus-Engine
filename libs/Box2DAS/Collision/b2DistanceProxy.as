package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// A distance proxy is used by the GJK algorithm.
	/// It encapsulates any shape.	
	public class b2DistanceProxy extends b2Base {
		
		public function b2DistanceProxy(p:int) {
			_ptr = p;
		}
		
		/// Note: m_vertices is a pointer. You can't actually get vertices from it.
		public function get m_vertices():int { return mem._mr32(_ptr + 16); }
		public function set m_vertices(v:int):void { mem._mw32(_ptr + 16, v); }
		
		public function get m_count():int { return mem._mr32(_ptr + 20); }
		public function set m_count(v:int):void { mem._mw32(_ptr + 20, v); }
		public function get m_radius():Number { return mem._mrf(_ptr + 24); }
		public function set m_radius(v:Number):void { mem._mwf(_ptr + 24, v); }
		
		public function Set(shape:b2Shape):void {
			switch (shape.m_type) {
				case b2Shape.e_circle:
					var circle:b2CircleShape = shape as b2CircleShape;
					m_vertices = circle._ptr + 16; // Address of m_p variable.
					m_count = 1;
					m_radius = circle.m_radius;
					break;
		
				case b2Shape.e_polygon:
					var polygon:b2PolygonShape = shape as b2PolygonShape;
					m_vertices = polygon._ptr + 24; // Address of m_vertices.
					m_count = polygon.m_vertexCount;
					m_radius = polygon.m_radius;
					break;
			}
		}
	}
}