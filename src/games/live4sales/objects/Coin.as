package games.live4sales.objects {

	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	import org.osflash.signals.Signal;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * @author Aymeric
	 */
	public class Coin extends Image {
		
		public var onDestroyed:Signal;
		
		private var _coinDurationTimeoutID:Number = 0;

		public function Coin(texture:Texture) {
			
			super(texture);
			
			onDestroyed = new Signal(Coin, Boolean);
			
			addEventListener(TouchEvent.TOUCH, _touched);
			
			_coinDurationTimeoutID = setTimeout(_destroyCoin, 2500);
		}
		
		private function _touched(tEvt:TouchEvent):void {
			
			var touchBegan:Touch = tEvt.getTouch(this, TouchPhase.BEGAN);
			
			if (touchBegan) {
				_destroyCoin(true);
			}
		}
		
		private function _destroyCoin(touched:Boolean = false):void {
			
			onDestroyed.dispatch(this, touched);
			
			removeEventListener(TouchEvent.TOUCH, _touched);
			
			clearTimeout(_coinDurationTimeoutID);
			
			onDestroyed.removeAll();
		}
	}
}
