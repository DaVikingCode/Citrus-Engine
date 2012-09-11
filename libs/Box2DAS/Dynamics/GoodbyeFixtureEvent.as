package Box2DAS.Dynamics {

	import flash.events.Event;
	
	public class GoodbyeFixtureEvent extends Event {
		
		public static var GOODBYE_FIXTURE:String = 'onGoodbyeFixture';
		
		public var fixture:b2Fixture;
		
		public function GoodbyeFixtureEvent(f:b2Fixture) {
			fixture = f;
			super(GOODBYE_FIXTURE);
		}
	}
}