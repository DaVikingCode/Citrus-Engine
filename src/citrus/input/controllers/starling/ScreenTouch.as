package citrus.input.controllers.starling 
{
	import citrus.input.InputController;
	import citrus.view.starlingview.StarlingView;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import starling.events.Touch;
	import starling.events.TouchPhase;
	
	/**
	 * ScreenTouch is a small InputController to get a starling touch into the input system :
	 * the common use case is if you want your hero to react on the touch of a screen and handle that
	 * in the hero's update loop without having to change your code, for example having ScreenTouch with
	 * "jump" for touchAction, let's you touch the touchTarget(the state by default) and make your Hero jump
	 * with no changes to Hero's code as it will respond to justDid("jump").
	 */
	public class ScreenTouch extends InputController
	{
		/**
		 * By default, the touchTarget will be set to the state so that anything outside will not be considered.
		 */
		public var touchTarget:Sprite;
		/**
		 * touch action is the action triggered on touch, it is jump by default.
		 */
		public var touchAction:String = "jump";
		
		public function ScreenTouch(name:String, params:Object = null)
		{
			super(name, params);
			
			if (!touchTarget)
			touchTarget = ((_ce.state.view as StarlingView).viewRoot as Sprite);
			
			touchTarget.addEventListener(TouchEvent.TOUCH, _handleTouch);
		}
		
		private function _handleTouch(e:TouchEvent):void
		{
			var t:Touch = e.getTouch(touchTarget);
			if (t)
			{
				switch (t.phase) {
					
					case TouchPhase.BEGAN:
						triggerON(touchAction, 1, defaultChannel);
						break;
					default:
					case TouchPhase.ENDED:
						triggerOFF(touchAction, 0, defaultChannel);
						break;
				}
			}
		}
		
		override public function destroy():void {
			touchTarget.addEventListener(TouchEvent.TOUCH, _handleTouch);
			super.destroy();
		}
		
	}

}