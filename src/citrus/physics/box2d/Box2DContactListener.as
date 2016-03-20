package citrus.physics.box2d {

	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;

	/**
	 * Used to report the contact's interaction between objects. It calls function in Box2dPhysicsObject.
	 */
	public class Box2DContactListener extends b2ContactListener {
		
		private var _worldManifold:b2WorldManifold;

		public function Box2DContactListener() {
			_worldManifold = new b2WorldManifold();
		}

		override public function BeginContact(contact:b2Contact):void {
			
			var a:IBox2DPhysicsObject = contact.GetFixtureA().GetBody().GetUserData();
			var b:IBox2DPhysicsObject = contact.GetFixtureB().GetBody().GetUserData();
			
			if (!a || !b)
				return;
			
			_contactGetWorldManifoldValues(contact);
			
			if (a.beginContactCallEnabled)
				a.handleBeginContact(contact);
				
			if (b.beginContactCallEnabled)
				b.handleBeginContact(contact);
		}
			
		override public function EndContact(contact:b2Contact):void {
			
			var a:IBox2DPhysicsObject = contact.GetFixtureA().GetBody().GetUserData();
			var b:IBox2DPhysicsObject = contact.GetFixtureB().GetBody().GetUserData();
			
			if (!a || !b)
				return;
			
			_contactGetWorldManifoldValues(contact);
			
			if (a.endContactCallEnabled)
				a.handleEndContact(contact);
				
			if (b.endContactCallEnabled)
				b.handleEndContact(contact);
		}

		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void {
			
			var a:IBox2DPhysicsObject = contact.GetFixtureA().GetBody().GetUserData();
			var b:IBox2DPhysicsObject = contact.GetFixtureB().GetBody().GetUserData();
			
			if (!a || !b)
				return;
			
			_contactGetWorldManifoldValues(contact);
			
			if (a.preContactCallEnabled)
				a.handlePreSolve(contact, oldManifold);
				
			if (b.preContactCallEnabled)
				b.handlePreSolve(contact, oldManifold);
		}

		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void {
			
			var a:IBox2DPhysicsObject = contact.GetFixtureA().GetBody().GetUserData();
			var b:IBox2DPhysicsObject = contact.GetFixtureB().GetBody().GetUserData();
			
			if (!a || !b)
				return;
			
			_contactGetWorldManifoldValues(contact);
			
			if (a.postContactCallEnabled)
				a.handlePostSolve(contact, impulse);
				
			if (b.postContactCallEnabled)
				b.handlePostSolve(contact, impulse);
		}
		
		private function _contactGetWorldManifoldValues(contact:b2Contact):void {
			contact.GetWorldManifold(_worldManifold);
			contact.normal = _worldManifold.m_normal;
			contact.contactPoints = _worldManifold.m_points;
		}

	}
}
