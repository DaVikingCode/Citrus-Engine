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
		private var _worldManifold : b2WorldManifold;
		private var _contacts : Vector.<Box2DContact>;
		private var _c : Box2DContact;

		public function Box2DContactListener() {
			_worldManifold = new b2WorldManifold();
			_contacts = new Vector.<Box2DContact>();
		}

		override public function BeginContact(contact : b2Contact) : void {
			var a : IBox2DPhysicsObject = contact.GetFixtureA().GetBody().GetUserData();
			var b : IBox2DPhysicsObject = contact.GetFixtureB().GetBody().GetUserData();

			if (!a || !b)
				return;

			_contactGetWorldManifoldValues(contact);

			_c = new Box2DContact();
			_c.a = a;
			_c.b = b;
			_c.type = Box2DContact.BEGIN;
			_c.contact = contact;
			_contacts.unshift(_c);
		}

		override public function EndContact(contact : b2Contact) : void {
			var a : IBox2DPhysicsObject = contact.GetFixtureA().GetBody().GetUserData();
			var b : IBox2DPhysicsObject = contact.GetFixtureB().GetBody().GetUserData();

			if (!a || !b)
				return;

			_contactGetWorldManifoldValues(contact);

			_c = new Box2DContact();
			_c.a = a;
			_c.b = b;
			_c.type = Box2DContact.END;
			_c.contact = contact;
			_contacts.unshift(_c);
		}

		override public function PreSolve(contact : b2Contact, oldManifold : b2Manifold) : void {
			var a : IBox2DPhysicsObject = contact.GetFixtureA().GetBody().GetUserData();
			var b : IBox2DPhysicsObject = contact.GetFixtureB().GetBody().GetUserData();

			if (!a || !b)
				return;

			_contactGetWorldManifoldValues(contact);

			_c = new Box2DContact();
			_c.a = a;
			_c.b = b;
			_c.type = Box2DContact.PRESOLVE;
			_c.contact = contact;
			_c.oldManifold = oldManifold;
			_contacts.unshift(_c);
		}

		override public function PostSolve(contact : b2Contact, impulse : b2ContactImpulse) : void {
			var a : IBox2DPhysicsObject = contact.GetFixtureA().GetBody().GetUserData();
			var b : IBox2DPhysicsObject = contact.GetFixtureB().GetBody().GetUserData();

			if (!a || !b)
				return;

			_contactGetWorldManifoldValues(contact);

			_c = new Box2DContact();
			_c.a = a;
			_c.b = b;
			_c.type = Box2DContact.POSTSOLVE;
			_c.contact = contact;
			_c.impulse = impulse;
			_contacts.unshift(_c);
		}

		public function processContacts() : void {
			while ((_c = _contacts.pop()) != null) {
				switch (_c.type) {
					case Box2DContact.BEGIN :
						if (_c.a.beginContactCallEnabled)
							_c.a.handleBeginContact(_c.contact);
						if (_c.b.beginContactCallEnabled)
							_c.b.handleBeginContact(_c.contact);
						break;
					case Box2DContact.END :
						if (_c.a.endContactCallEnabled)
							_c.a.handleEndContact(_c.contact);
						if (_c.b.endContactCallEnabled)
							_c.b.handleEndContact(_c.contact);
						break;
					case Box2DContact.PRESOLVE :
						if (_c.a.preContactCallEnabled)
							_c.a.handlePreSolve(_c.contact, _c.oldManifold);
						if (_c.b.preContactCallEnabled)
							_c.b.handlePreSolve(_c.contact, _c.oldManifold);
						break;
					case Box2DContact.POSTSOLVE :
						if (_c.a.postContactCallEnabled)
							_c.a.handlePostSolve(_c.contact, _c.impulse);
						if (_c.b.postContactCallEnabled)
							_c.b.handlePostSolve(_c.contact, _c.impulse);
						break;
				}
			}
		}

		private function _contactGetWorldManifoldValues(contact : b2Contact) : void {
			contact.GetWorldManifold(_worldManifold);
			contact.normal = _worldManifold.m_normal;
			contact.contactPoints = _worldManifold.m_points;
		}
	}
}

import Box2D.Collision.b2Manifold;
import Box2D.Dynamics.Contacts.b2Contact;
import Box2D.Dynamics.b2ContactImpulse;

import citrus.physics.box2d.IBox2DPhysicsObject;


internal class Box2DContact {
	public static const BEGIN : String = "begin";
	public static const END : String = "end";
	public static const PRESOLVE : String = "preSolve";
	public static const POSTSOLVE : String = "postSolve";
	public var type : String;
	public var a : IBox2DPhysicsObject;
	public var b : IBox2DPhysicsObject;
	public var contact : b2Contact;
	public var oldManifold : b2Manifold;
	public var impulse : b2ContactImpulse;

	public function Box2DContact() {
	}
}
