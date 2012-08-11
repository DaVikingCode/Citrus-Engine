package mobilenapestarling {

	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.Input;

	/**
	 * @author Aymeric
	 */
	public class MobileInput extends Input {

		private var _ce:CitrusEngine;
		
		private var _screenTouched:Boolean = false;

		public function MobileInput() {
			super();
		}

		override public function set enabled(value:Boolean):void {
			
			super.enabled = value;

			_ce = CitrusEngine.getInstance();

			if (enabled)
				_ce.starling.stage.addEventListener(TouchEvent.TOUCH, _touchEvent);
			else
				_ce.starling.stage.removeEventListener(TouchEvent.TOUCH, _touchEvent);
		}

		override public function initialize():void {
			
			super.initialize();

			_ce = CitrusEngine.getInstance();

			_ce.starling.stage.addEventListener(TouchEvent.TOUCH, _touchEvent);
		}

		private function _touchEvent(tEvt:TouchEvent):void {
						
			var touchStart:Touch = tEvt.getTouch(_ce.starling.stage, TouchPhase.BEGAN);
			var touchEnd:Touch = tEvt.getTouch(_ce.starling.stage, TouchPhase.ENDED);

			if (touchStart)
				_screenTouched = true;
			
			if (touchEnd)
				_screenTouched = false;
		}

		public function get screenTouched():Boolean {
			return _screenTouched;
		}
	}
}
