package citrus.physics {

	import citrus.core.CitrusObject;

	/**
	 * An abstract template used by every physics engine.
	 */
	public class APhysicsEngine extends CitrusObject {
		
		protected var _visible:Boolean = false;
		protected var _touchable:Boolean = false;
		protected var _group:uint = 1;
		protected var _view:*;
		protected var _realDebugView:*;

		public function APhysicsEngine(name:String, params:Object = null) {
			
			updateCallEnabled = true;
			
			super(name, params);
		}
		
		public function getBody():* {
			return null;
		}
		
		public function get realDebugView():* {
			return _realDebugView;
		}
		
		public function get view():* {
			return _view;
		}
		
		public function set view(value:*):void {
			_view = value;
		}
		
		public function get x():Number {
			return 0;
		}

		public function get y():Number {
			return 0;
		}
		
		public function get z():Number {
			return 0;
		}
		
		public function get width():Number {
			return 0;
		}
		
		public function get height():Number {
			return 0;
		}
		
		public function get depth():Number {
			return 0;
		}
		
		public function get velocity():Array {
			return null;
		}

		public function get parallaxX():Number {
			return 1;
		}
		
		public function get parallaxY():Number {
			return 1;
		}

		public function get rotation():Number {
			return 0;
		}

		public function get group():uint {
			return _group;
		}

		public function set group(value:uint):void {
			_group = value;
		}

		public function get visible():Boolean {
			return _visible;
		}

		public function set visible(value:Boolean):void {
			_visible = value;
		}
		
		public function get touchable():Boolean {
			return _touchable;
		}

		public function set touchable(value:Boolean):void {
			_touchable = value;
		}
		
		public function get animation():String {
			return "";
		}

		public function get inverted():Boolean {
			return false;
		}

		public function get offsetX():Number {
			return 0;
		}

		public function get offsetY():Number {
			return 0;
		}

		public function get registration():String {
			return "topLeft";
		}
	}
}
