package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2WorldManifold {
		
		public var normal:V2;
		public var points:Array = [];
		
		/// Evaluate the manifold with supplied transforms. This assumes
		/// modest motion from the original state. This does not change the
		/// point count, impulses, etc. The radii must come from the shapes
		/// that generated the manifold.
		/// void Initialize(const b2Manifold* manifold,
		///				const b2Transform& xfA, float32 radiusA,
		///				const b2Transform& xfB, float32 radiusB);
		public function Initialize(manifold:b2Manifold, xfA:XF, radiusA:Number, xfB:XF, radiusB:Number):void {
			if (manifold.pointCount == 0) {
				return;
			}
			var n:V2;
			var planePoint:V2;
			var i:uint;
			var clipPoint:V2;
			var cA:V2;
			var cB:V2;
			switch (manifold.type) {
				case b2Manifold.e_circles:
					var pointA:V2 = xfA.multiply(manifold.localPoint.v2);
					var pointB:V2 = xfB.multiply(manifold.points[0].localPoint.v2);
					n = V2.subtract(pointB, pointA).normalize();
					normal = n;
					cA = pointA.add(V2.multiplyN(normal, radiusA));
					cB = pointB.subtract(V2.multiplyN(normal, radiusB));
					points[0] = V2.add(cA, cB).multiplyN(.5);
					break;
			
				case b2Manifold.e_faceA:
					n = xfA.r.multiplyV(manifold.localNormal.v2);
					planePoint = xfA.multiply(manifold.localPoint.v2);		
					// Ensure normal points from A to B.
					normal = n;
					for(i = 0; i < manifold.pointCount; ++i) {
						clipPoint = xfB.multiply(manifold.points[i].localPoint.v2);
						cA = V2.add(clipPoint, V2.multiplyN(normal, radiusA - normal.dot(V2.subtract(clipPoint, planePoint))));
						cB = V2.subtract(clipPoint, V2.multiplyN(normal, radiusB));
						points[i] = V2.add(cA, cB).multiplyN(.5);
					}			
					break;
			
				case b2Manifold.e_faceB:
					n = xfB.r.multiplyV(manifold.localNormal.v2);
					planePoint = xfB.multiply(manifold.localPoint.v2);
					// Ensure normal points from A to B.
					normal = n.multiplyN(-1);
					for(i = 0; i < manifold.pointCount; ++i) {
						clipPoint = xfA.multiply(manifold.points[i].localPoint.v2);
						cA = V2.subtract(clipPoint, V2.multiplyN(normal, radiusA))
						cB = V2.add(clipPoint, V2.multiplyN(normal, radiusB - normal.dot(V2.subtract(clipPoint, planePoint))));
						points[i] = V2.add(cA, cB).multiplyN(.5);
					}
					break;
			}
		
		}
		
		/**
		 * Ensures that 2 point manifolds always have the points in the same order relative to the normal.
		 * A normal pointing straight up will have point[0] to the left, and point[1] to the right.
		 */
		public function OrientPoints():Boolean {
			var good:Boolean = (
				(normal.x > 0 && points[0].y > points[1].y) ||
				(normal.x < 0 && points[0].y < points[1].y) ||
				(normal.y > 0 && points[0].x < points[1].x) ||
				(normal.y < 0 && points[0].x > points[1].x)
			);
			if(!good) {
				return true;
				points = [points[1], points[0]];
			}
			return false;
		}
		
		/**
		 * If there are more than one contact points, this getter will return the average.
		 */
		public function GetPoint():V2 {
			if(points.length == 0) {
				return null;
			}
			if(points.length == 1) {
				return points[0];
			}
			return new V2((points[0].x + points[1].x) / 2, (points[0].y + points[1].y) / 2);
		}		
	}
}