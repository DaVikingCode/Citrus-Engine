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
	import flash.utils.*;
	
	/// Implement this class to get contact information. You can use these results for
	/// things like sounds and game logic. You can also get contact results by
	/// traversing the contact lists after the time step. However, you might miss
	/// some contacts because continuous physics leads to sub-stepping.
	/// Additionally you may receive multiple callbacks for the same contact in a
	/// single time step.
	/// You should strive to make your callbacks efficient because there may be
	/// many callbacks per time step.
	/// @warning You cannot create/destroy Box2D entities inside these callbacks.
	///
	/// Default AS3 Implementation: If the fixture userData is an event dispatcher (like
	/// a display object) then an AS3 native event will be dispatched off of that object.
	///
	public class b2ContactListener {
		
		/// Called when two fixtures begin to touch.
		public function BeginContact(c:b2Contact):void {
			ContactDispatch(ContactEvent.BEGIN_CONTACT, c);
		}
		
		/// Called when two fixtures cease to touch.
		public function EndContact(c:b2Contact):void {
			ContactDispatch(ContactEvent.END_CONTACT, c);
		}
		
		/// This is called after a contact is updated. This allows you to inspect a
		/// contact before it goes to the solver. If you are careful, you can modify the
		/// contact manifold (e.g. disable contact).
		/// A copy of the old manifold is provided so that you can detect changes.
		/// Note: this is called only for awake bodies.
		/// Note: this is called even when the number of contact points is zero.
		/// Note: this is not called for sensors.
		/// Note: if you set the number of contact points to zero, you will not
		/// get an EndContact callback. However, you may get a BeginContact callback
		/// the next step.		
		public function PreSolve(c:b2Contact, o:b2Manifold):void {
			ContactDispatch(ContactEvent.PRE_SOLVE, c, o);
		}
		
		/// This lets you inspect a contact after the solver is finished. This is useful
		/// for inspecting impulses.
		/// Note: the contact manifold does not include time of impact impulses, which can be
		/// arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
		/// in a separate data structure.
		/// Note: this is only called for contacts that are touching, solid, and awake.		
		public function PostSolve(c:b2Contact, i:b2ContactImpulse):void {
			ContactDispatch(ContactEvent.POST_SOLVE, c, null, i);
		}
		
		public function ContactDispatch(typ:String, c:b2Contact, o:b2Manifold = null, i:b2ContactImpulse = null):void {
			c.m_fixtureA.dispatchEvent(new ContactEvent(typ, c, 1, o, i));
			c.m_fixtureB.dispatchEvent(new ContactEvent(typ, c, -1, o, i));
		}
	}
}