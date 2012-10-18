package mobilenapestarling {

	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.Input;
	import com.citrusengine.core.StarlingCitrusEngine;

	/**
	 * @author Aymeric
	 */
	public class MobileInput extends Input {
		
		private var _screenTouched:Boolean = false;

		public function MobileInput() {
			super();
		}
			
		override public function destroy():void {
			
			(_ce as StarlingCitrusEngine).starling.stage.removeEventListener(TouchEvent.TOUCH, _touchEvent);
			
			super.destroy();
		}

		override public function set enabled(value:Boolean):void {
			
			super.enabled = value;

			_ce = CitrusEngine.getInstance();

			if (enabled)
				(_ce as StarlingCitrusEngine).starling.stage.addEventListener(TouchEvent.TOUCH, _touchEvent);
			else
				(_ce as StarlingCitrusEngine).starling.stage.removeEventListener(TouchEvent.TOUCH, _touchEvent);
		}

		override public function initialize():void {
			
			super.initialize();

			_ce = CitrusEngine.getInstance();

			(_ce as StarlingCitrusEngine).starling.stage.addEventListener(TouchEvent.TOUCH, _touchEvent);
		}

		private function _touchEvent(tEvt:TouchEvent):void {
						
			var touchStart:Touch = tEvt.getTouch((_ce as StarlingCitrusEngine).starling.stage, TouchPhase.BEGAN);
			var touchEnd:Touch = tEvt.getTouch((_ce as StarlingCitrusEngine).starling.stage, TouchPhase.ENDED);

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
