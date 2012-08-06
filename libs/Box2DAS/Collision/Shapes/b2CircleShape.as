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
	
	/// A circle shape.
	public class b2CircleShape extends b2Shape {
	
		public function b2CircleShape(p:int = 0) {
			_ptr = ((p == 0) ? lib.b2CircleShape_new() : p);
			m_p = new b2Vec2(_ptr + 16);
		}
		
		public override function destroy():void {
			lib.b2CircleShape_delete(_ptr);
			super.destroy();
		}
		
		/// Draw the circle. You must set the stroke/fill style before calling.
		public override function Draw(g:Graphics, xf:XF, scale:Number = 1, options:Object = null):void {
			var center:V2 = xf.multiply(m_p.v2);
			g.drawCircle(center.x * scale, center.y * scale, m_radius * scale);
			g.moveTo(center.x * scale, center.y * scale);
			var ax:V2 = V2.multiplyN(xf.r.c1, m_radius).add(center);
			g.lineTo(ax.x * scale, ax.y * scale);
		}

		/// Implement b2Shape.
		/// bool TestPoint(const b2Transform& transform, const b2Vec2& p) const;
		public override function TestPoint(transform:XF, p:V2):Boolean {
			var center:V2 = transform.p.clone().add(transform.r.multiplyV(m_p.v2));
			var d:V2 = p.clone().subtract(center);
			return (d.dot(d) <= (m_radius * m_radius));
		}
	
		/// Implement b2Shape.
		/// bool RayCast(b2RayCastOutput* output, const b2RayCastInput& input, const b2Transform& transform) const;
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
		
		/// @see b2Shape::ComputeSubmergedArea
		public override function ComputeSubmergedArea(normal:V2, offset:Number, xf:XF, c:V2):Number {
			var p:V2 = xf.multiply(m_p.v2);
			var l:Number = -(normal.dot(p) - offset);
			var r:Number = m_radius;
			if(l < -r){ //Completely dry
				return 0;
			}
			if(l > r) { //Completely wet
				c.copy(p);
				return m_area;
			}
			var r2:Number = r * r;
			var l2:Number = l * l;
			var area:Number = r2 * (Math.asin(l / r) + Math.PI / 2) + l * Math.sqrt(r2 - l2);
			var com:Number = -2.0 / 3.0 * Math.pow(r2 - l2, 1.5) / area;
			c.x = p.x + normal.x * com;
			c.y = p.y + normal.y * com;
			return area;
		}

		public var m_p:b2Vec2;
	
	}
}