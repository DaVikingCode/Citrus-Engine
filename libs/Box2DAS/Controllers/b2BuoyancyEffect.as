package Box2DAS.Controllers {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.utils.*;

	public class b2BuoyancyEffect extends b2Effect {
		
		/// The outer surface normal
		public var normal:V2 = new V2(0,-1);
		/// The height of the fluid surface along the normal
		public var offset:Number = 0;
		/// The fluid density
		public var density:Number = 1;
		/// Fluid velocity, for drag calculations
		public var velocity:V2 = new V2(0,0);
		/// Linear drag co-efficient
		public var linearDrag:Number = 2;
		/// Linear drag co-efficient
		public var angularDrag:Number = 1;
		/// If false, bodies are assumed to be uniformly dense, otherwise use the shapes densities
		public var useDensity:Boolean = false; //False by default to prevent a gotcha
		/// Gravity vector, if the world's gravity is not used
		public var gravity:V2 = new V2(0, 10);
		
		public override function Apply(body:b2Body):void {
			if(!body.IsAwake() || !body.IsDynamic()){
				return;
			}
			for(var f:b2Fixture = body.GetFixtureList(); f; f = f.GetNext()) {
				ApplyToFixture(f);
			}
			
		}
		
		public function ApplyToFixture(f:b2Fixture):Boolean {
			var body:b2Body = f.m_body;
			var areac:V2 = new V2();
			var massc:V2 = new V2();
			var area:Number = 0;
			var mass:Number = 0;
				
			var shape:b2Shape = f.m_shape;
			
			var sc:V2 = new V2();
			var sarea:Number = shape.ComputeSubmergedArea(normal, offset, body.m_xf.xf, sc);
			area += sarea;
			areac.x += sarea * sc.x;
			areac.y += sarea * sc.y;
			var shapeDensity:Number = useDensity ? f.m_density : 1;
			mass += sarea * shapeDensity;
			massc.x += sarea * sc.x * shapeDensity;
			massc.y += sarea * sc.y * shapeDensity;			

			areac.x /= area;
			areac.y /= area;
			massc.x /= mass;
			massc.y /= mass;
			if(area < Number.MIN_VALUE) {
				return false;
			}

			// buoyancy force.
			body.ApplyForce(V2.invert(gravity).multiplyN(density * area), massc);
			// linear drag.
			body.ApplyForce(
				body.GetLinearVelocityFromWorldPoint(areac)
				.subtract(velocity)
				.multiplyN(-linearDrag * area),
				areac);
			/// angular drag.
			body.ApplyTorque(-body.GetInertia() / body.GetMass() * area * body.GetAngularVelocity() * angularDrag);		
			return true;
		}
	}
}