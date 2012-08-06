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
	
	public class StepEvent extends Event {
		
		public static var STEP:String = 'onStep';
		
		public var timeStep:Number;
		public var velocityIterations:Number;
		public var positionIterations:Number;
		public var stepTime:Number;
		
		public function StepEvent(ts:Number, vi:Number, pi:Number, st:Number) {
			timeStep = ts;
			velocityIterations = vi;
			positionIterations = pi;
			stepTime = st;
			super(STEP);
		}
	}
}