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
	
	
	/// A loop shape is a free form sequence of line segments that form a circular list.
	/// The loop may cross upon itself, but this is not recommended for smooth collision.
	/// The loop has double sided collision, so you can use inside and outside collision.
	/// Therefore, you may use any winding order.
	public class b2LoopShape extends b2Shape {
	
		public function b2LoopShape(p:int = 0) {
			_ptr = (p == 0 ? lib.b2LoopShape_new() : p);
		}
		
		public function set m_vertices(v:Vector.<V2>):void {
			if(m_verticesSet) {
				destroyVertices();
			}
			m_verticesSet = true;
			m_verticesPtr = lib.b2Vec2Array_new(v.length);
			m_count = v.length;
			writeVertices(m_verticesPtr, v);
		}
		
		public function get m_vertices():Vector.<V2> {
			return readVertices(m_verticesPtr, m_count);
		}
		
		public function destroyVertices():void {
			m_verticesSet = false;
			lib.b2Vec2Array_delete(m_verticesPtr);
		}
		
		public override function destroy():void {
			destroyVertices();
			super.destroy();
		}
		
		/// Draw the loop to a graphics object. You must set the fill/stroke style before calling.
		public override function Draw(g:Graphics, xf:XF, scale:Number = 1, options:Object = null):void {
			var vertices:Vector.<V2> = m_vertices;
			var vertexCount:Number = m_count;
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
		}
		
		public var m_verticesSet:Boolean = false;
		public function get m_verticesPtr():int { return mem._mr32(_ptr + 16); }
		public function set m_verticesPtr(v:int):void { mem._mw32(_ptr + 16, v); }
		public function get m_count():int { return mem._mr32(_ptr + 20); }
		public function set m_count(v:int):void { mem._mw32(_ptr + 20, v); }
	
	}
}