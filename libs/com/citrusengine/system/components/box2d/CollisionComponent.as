package com.citrusengine.system.components.box2d {

	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;

	import com.citrusengine.system.Component;

	/**
	 * The Box2D collision component, extends it to handle collision.
	 */
	public class CollisionComponent extends Component {

		public function CollisionComponent(name:String, params:Object = null) {
			
			super(name, params);
		}

		/**
		 * Override this method to handle the begin contact collision.
		 */
		public function handleBeginContact(contact:b2Contact):void {
			
		}
		
		/**
		 * Override this method to handle the end contact collision.
		 */
		public function handleEndContact(contact:b2Contact):void {
			
		}
		
		/**
		 * Override this method if you want to perform some actions before the collision (deactivate).
		 */
		public function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void {

		}
		
		/**
		 * Override this method if you want to perform some actions after the collision.
		 */
		public function handlePostSolve(contact:b2Contact, impulse:b2ContactImpulse):void {
			
		}
	}
}
