package Box2DAS.Dynamics {

	import flash.events.Event;
	
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