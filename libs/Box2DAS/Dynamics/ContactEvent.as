package Box2DAS.Dynamics {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.events.*;
	
	/**
	 * A native flash event class for handling Box2d contact events. If a fixture's user data implements
	 * IEventDispatcher (for example, if m_userData is a MovieClip), that event dispatcher will be used
	 * to broadcast contact events involving the fixture. 
	 *
	 * GOTCHA: A fixture will only dispatch contact events if reportBeginContact, reportEndContact, etc. are set to true.
	 */
	public class ContactEvent extends Event {
		
		/// The various event types.		
		public static var BEGIN_CONTACT:String = 'onBeginContact';
		public static var END_CONTACT:String = 'onEndContact';
		public static var PRE_SOLVE:String = 'onPreSolve';
		public static var POST_SOLVE:String = 'onPostSolve';
		
		/// Use to track information about the event.
		public var userData:*;
		
		/// The world the event occurred in.
		public var world:b2World;
		
		/// The b2Contact. 
		public var contact:b2Contact;
		
		/// The "target" b2Fixture. This fixture's userData is dispatching the event (fixture.m_userData = this.target).
		public var fixture:b2Fixture;
		
		/// The other b2Fixture involved in the collision.
		public var other:b2Fixture;
		
		/// the "target" property is the fixture userData dispatching the event, the "relatedObject" is the userData
		/// of the other fixture involved in the contact.
		public var relatedObject:*;
		
		/// Cached b2WorldManifold.
		public var worldManifold:b2WorldManifold = new b2WorldManifold();
		
		/// The world's step time the world manifold was calculated at. As long as this matches the
		/// current step time of the world, return the cached worldManifold.
		public var worldManifoldTime:int;
		
		/// For preSolve events.
		public var oldManifold:b2Manifold;
		
		/// For postSolve events.
		public var impulses:b2ContactImpulse;
		
		/// Indicates the "directionality" of the contact with respect to the fixture dispatching the event.
		/// if(fixture = contact.m_fixtureA) bias = 1.
		/// if(fixture = contact.m_fixtureB) bias = -1.
		public var bias:int;
		
		public function ContactEvent(t:String, c:b2Contact, bi:int, o:b2Manifold = null, i:b2ContactImpulse = null) {
			world = c.m_fixtureA.m_body.m_world;
			contact = c;
			bias = bi;
			oldManifold = o;
			impulses = i;
			if(bi == 1) {
				fixture = c.m_fixtureA;
				other = c.m_fixtureB;
			}
			else {
				fixture = c.m_fixtureB;
				other = c.m_fixtureA;
			}
			relatedObject = other.m_userData;
			super(t, fixture.m_bubbleContacts, true);
		}
		
		/**
		 * Clone the event for re-dispatching.
		 */
		public override function clone():Event {
			return new ContactEvent(type, contact, bias, oldManifold, impulses);
		}
		
		/**
		 * Disables a contact by setting it as a sensor for the life of the contact.
		 */
		public override function preventDefault():void {
			super.preventDefault();
			//contact.SetSensor(true);
			contact.SetEnabled(false);
		}
		
		/**
		 * Returns true if the contacts is touching, is not a sensor, and has not been disabled.
		 */
		public function isSolid():Boolean {
			return contact.IsSolid();
		}
		
		/**
		 * Get the world normal of the contact that points from fixture to other.
		 */
		public function get normal():V2 {
			return getWorldManifold().normal;
		}
		
		/**
		 * Get the world point of contact (for 2-point contacts, this is the average).
		 */
		public function get point():V2 {
			return getWorldManifold().GetPoint();
		}
	
		/**
		 * Get the point count from the contact.
		 */
		public function get pointCount():uint {
			return contact.m_manifold.pointCount;
		}
		
		/**
		 * Applies an impulse to the other body in the direction of the normal.
		 */
		public function applyImpulse(base:Number, massFactor:Number = 0):void {
			var m:b2WorldManifold = getWorldManifold();
			var o:b2Body = other.m_body;
			var v:V2 = V2.multiplyN(m.normal, base + o.GetMass() * massFactor);
			o.ApplyImpulse(v, m.GetPoint());
		}
		
		/**
		 * Applies a force to the other body in the direction of the normal.
		 */
		public function applyForce(base:Number, massFactor:Number = 0, self:Boolean = false):void {
			var m:b2WorldManifold = getWorldManifold();
			var o:b2Body = other.m_body;
			var v:V2 = V2.multiplyN(m.normal, base + o.GetMass() * massFactor);
			o.ApplyForce(v, m.GetPoint());
			if(self) {
				fixture.m_body.ApplyForce(v.multiplyN(-1), m.GetPoint());
			}
		}
		
		/**
		 * Returns the world manifold. Very important if you plan on actually doing anything significant
		 * with contacts. The normal will be oriented based on "bias" so that it is always pointing from 
		 * the target fixture to the other fixture. This way you don't have to worry about the direction of the
		 * normal.
		 */
		public function getWorldManifold():b2WorldManifold {
			/// Return the cached world manifold if appropriate.
			if(!world.IsLocked() && worldManifoldTime == world.stepTime) {
				return worldManifold;
			}
			worldManifoldTime = world.stepTime;
			worldManifold = new b2WorldManifold();
			contact.GetWorldManifold(worldManifold);
			if(worldManifold.normal) {
				worldManifold.normal.multiplyN(bias);
			}
			return worldManifold;
		}
		
		/**
		 * Update the contact. This ensures the contact has the right, current information.
		 */
		public function update():void {
			contact.Update();
		}
	}
}