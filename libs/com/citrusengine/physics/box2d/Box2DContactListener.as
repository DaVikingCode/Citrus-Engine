package com.citrusengine.physics.box2d {

	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactListener;

	/**
	 * @author Aymeric
	 */
	public class Box2DContactListener extends b2ContactListener {

		public function Box2DContactListener() {
		}

		override public function BeginContact(contact:b2Contact):void {
			
			contact.GetFixtureA().GetBody().GetUserData().handleBeginContact(contact);
			contact.GetFixtureB().GetBody().GetUserData().handleBeginContact(contact);
		}
			
		override public function EndContact(contact:b2Contact):void {
			
			contact.GetFixtureA().GetBody().GetUserData().handleEndContact(contact);
			contact.GetFixtureB().GetBody().GetUserData().handleEndContact(contact);
		}

		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void {
			
			contact.GetFixtureA().GetBody().GetUserData().handlePreSolve(contact, oldManifold);
			contact.GetFixtureB().GetBody().GetUserData().handlePreSolve(contact, oldManifold);
		}

		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void {
			
			contact.GetFixtureA().GetBody().GetUserData().handlePostSolve(contact, impulse);
			contact.GetFixtureB().GetBody().GetUserData().handlePostSolve(contact, impulse);
		}

	}
}
