package games.live4sales.ui {

	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	import org.osflash.signals.Signal;

	/**
	 * @author Aymeric
	 */
	public class Icon extends Image {
		
		public var onStartDrag:Signal;
		public var onStopDrag:Signal;

		private var _dragging:Boolean = false;

		private var _posX:uint, _posY:uint;

		public function Icon(texture:Texture) {
			
			super(texture);
			
			onStartDrag = new Signal();
			onStopDrag = new Signal(String, uint, uint);
			
			addEventListener(TouchEvent.TOUCH, _iconTouched);
		}
		
		public function destroy():void {
			
			removeEventListener(TouchEvent.TOUCH, _iconTouched);
			
			onStartDrag.removeAll();
			onStopDrag.removeAll();
		}

		private function _iconTouched(tEvt:TouchEvent):void {

			var touchBegan:Touch = tEvt.getTouch(this, TouchPhase.BEGAN);
			var touchMoved:Touch = tEvt.getTouch(this, TouchPhase.MOVED);
			var touchEnded:Touch = tEvt.getTouch(this, TouchPhase.ENDED);

			if (touchBegan) {
				
				_posX = this.x;
				_posY = this.y;
				
				_dragging = true;
				
				onStartDrag.dispatch();

			} else if (touchMoved && _dragging) {

				this.x = touchMoved.globalX - this.width * 0.5;
				this.y = touchMoved.globalY - this.height * 0.5;

			} else if (touchEnded && _dragging) {
				
				_dragging = false;
				
				this.x = _posX;
				this.y = _posY;
				
				onStopDrag.dispatch(name, uint(touchEnded.globalX), uint(touchEnded.globalY));
			}
		}
	}
}
