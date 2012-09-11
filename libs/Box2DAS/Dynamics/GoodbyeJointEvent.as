package Box2DAS.Dynamics {

	import Box2DAS.Dynamics.Joints.b2Joint;

	import flash.events.Event;
	
	public class GoodbyeJointEvent extends Event {
		
		public static var GOODBYE_JOINT:String = 'onGoodbyeJoint';
		
		public var joint:b2Joint;
		
		public function GoodbyeJointEvent(j:b2Joint) {
			joint = j;
			super(GOODBYE_JOINT);
		}
	}
}