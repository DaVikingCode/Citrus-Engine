package com.citrusengine.physics {

	import com.citrusengine.core.CitrusObject;

	/**
	 * An abstract template used by every physics engine.
	 */
	public class APhysicsEngine extends CitrusObject {
		
		protected var _visible:Boolean = false;
		protected var _group:Number = 1;

		public function APhysicsEngine(name:String, params:Object = null) {
			super(name, params);
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

		public function get parallax():Number {
			return 1;
		}

		public function get rotation():Number {
			return 0;
		}

		public function get group():Number {
			return _group;
		}

		public function set group(value:Number):void {
			_group = value;
		}

		public function get visible():Boolean {
			return _visible;
		}

		public function set visible(value:Boolean):void {
			_visible = value;
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
