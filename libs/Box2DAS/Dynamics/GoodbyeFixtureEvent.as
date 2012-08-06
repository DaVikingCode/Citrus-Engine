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
	
	public class GoodbyeFixtureEvent extends Event {
		
		public static var GOODBYE_FIXTURE:String = 'onGoodbyeFixture';
		
		public var fixture:b2Fixture;
		
		public function GoodbyeFixtureEvent(f:b2Fixture) {
			fixture = f;
			super(GOODBYE_FIXTURE);
		}
	}
}