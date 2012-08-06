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
	
	public class GoodbyeJointEvent extends Event {
		
		public static var GOODBYE_JOINT:String = 'onGoodbyeJoint';
		
		public var joint:b2Joint;
		
		public function GoodbyeJointEvent(j:b2Joint) {
			joint = j;
			super(GOODBYE_JOINT);
		}
	}
}