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
	
	
	/// A shape is used for collision detection. You can create a shape however you like.
	/// Shapes used for simulation in b2World are created automatically when a b2Fixture
	/// is created.
	public class b2Shape extends b2Base {
	
		public function GetType():int {
			return m_type;
		}
		
		public function create(b:b2Body, f:b2FixtureDef = null):b2Fixture {
			f ||= b2Def.fixture;
			f.shape = this;
			return new b2Fixture(b, f);
		}
		
		/// Base draw function.
		public function Draw(g:Graphics, xf:XF, scale:Number = 1, options:Object = null):void {
		}

		/// Test a point for containment in this shape. This only works for convex shapes.
		/// @param xf the shape world transform.
		/// @param p a point in world coordinates.
		/// virtual bool TestPoint(const b2Transform& xf, const b2Vec2& p) const = 0;
		public virtual function TestPoint(xf:XF, p:V2):Boolean {
			return false;
		}
	
		/// Cast a ray against this shape.
		/// @param output the ray-cast results.
		/// @param input the ray-cast input parameters.
		/// @param transform the transform to be applied to the shape.
		/// virtual bool RayCast(b2RayCastOutput* output, const b2RayCastInput& input, const b2Transform& transform) const = 0;
		public virtual function RayCast(output:*, input:*, transform:XF):Boolean {
			return false;
		}
	
		/// Given a transform, compute the associated axis aligned bounding box for this shape.
		/// @param aabb returns the axis aligned box.
		/// @param xf the world transform of the shape.
		/// virtual void ComputeAABB(b2AABB* aabb, const b2Transform& xf) const = 0;
		public virtual function ComputeAABB(aabb:AABB, xf:XF):void {
		}
	
		/// Compute the mass properties of this shape using its dimensions and density.
		/// The inertia tensor is computed about the local origin, not the centroid.
		/// @param massData returns the mass data for this shape.
		/// @param density the density in kilograms per meter squared.
		/// virtual void ComputeMass(b2MassData* massData, float32 density) const = 0;
		public virtual function ComputeMass(massData:b2MassData, density:Number):void {
		}
	
		/// Compute the volume and centroid of this shape intersected with a half plane
		/// @param normal the surface normal
		/// @param offset the surface offset along normal
		/// @param xf the shape transform
		/// @param c returns the centroid
		/// @return the total volume less than offset along normal
		public virtual function ComputeSubmergedArea(normal:V2, offset:Number, xf:XF, c:V2): Number {
			return 0;
		};
	
		public static const e_unknown:int = -1;
		public static const e_circle:int = 0;
		public static const e_edge:int = 1;
		public static const e_polygon:int = 2;
		public static const e_loop:int = 3;
		public static const e_typeCount:int = 4;
		
		public function get m_type():int { return mem._mrs8(_ptr + 4); }
		public function set m_type(v:int):void { mem._mw8(_ptr + 4, v); }
		public function get m_radius():Number { return mem._mrf(_ptr + 8); }
		public function set m_radius(v:Number):void { mem._mwf(_ptr + 8, v); }
		public function get m_area():Number { return mem._mrf(_ptr + 12); }
		public function set m_area(v:Number):void { mem._mwf(_ptr + 12, v); }
	
	}
}