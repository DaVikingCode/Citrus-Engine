package awayphysics.events {
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.dispatch.AWPManifoldPoint;

	import flash.events.Event;

	public class AWPEvent extends Event {
		/**
		 * Dispatched when the body occur collision
		 */
		public static const COLLISION_ADDED : String = "collisionAdded";
		/**
		 * Dispatched when ray collide
		 */
		 public static const RAY_CAST : String = "rayCast";
		/**
		 * stored which object is collide with target object
		 */
		public var collisionObject : AWPCollisionObject;
		/**
		 * stored collision point, normal, impulse etc.
		 */
		public var manifoldPoint : AWPManifoldPoint;

		public function AWPEvent(type : String) {
			super(type);
		}
	}
}