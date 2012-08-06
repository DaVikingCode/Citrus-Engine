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
	
	/// A line segment (edge) shape. These can be connected in chains or loops
	/// to other edge shapes. The connectivity information is used to ensure
	/// correct contact normals.
	public class b2EdgeShape extends b2Shape {
	
		public function b2EdgeShape(p:int = 0) {
			_ptr = (p == 0 ? lib.b2EdgeShape_new() : p);
			m_vertex0 = new b2Vec2(_ptr + 32);
			m_vertex1 = new b2Vec2(_ptr + 16);
			m_vertex2 = new b2Vec2(_ptr + 24);
			m_vertex3 = new b2Vec2(_ptr + 40);
		}
		
		/// Draw the edge. You must set the stroke/fill style before calling.
		public override function Draw(g:Graphics, xf:XF, scale:Number = 1, options:Object = null):void {
			var v1:V2 = xf.multiply(m_vertex1.v2);
			var v2:V2 = xf.multiply(m_vertex2.v2);
			g.moveTo(v1.x * scale, v1.y * scale);
			g.lineTo(v2.x * scale, v2.y * scale); 
		}
		
		public var m_vertex0:b2Vec2; // m_vertex0 = new b2Vec2(_ptr + 32);
		public var m_vertex1:b2Vec2; // m_vertex1 = new b2Vec2(_ptr + 16);
		public var m_vertex2:b2Vec2; // m_vertex2 = new b2Vec2(_ptr + 24);
		public var m_vertex3:b2Vec2; // m_vertex3 = new b2Vec2(_ptr + 40);
		public function get m_hasVertex0():Boolean { return mem._mru8(_ptr + 48) == 1; }
		public function set m_hasVertex0(v:Boolean):void { mem._mw8(_ptr + 48, v ? 1 : 0); }
		public function get m_hasVertex3():Boolean { return mem._mru8(_ptr + 49) == 1; }
		public function set m_hasVertex3(v:Boolean):void { mem._mw8(_ptr + 49, v ? 1 : 0); }
	
	}
}