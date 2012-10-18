package com.citrusengine.objects {

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;

	/**
	 * An abstract template used by every physics object.
	 */
	public class APhysicsObject extends CitrusObject {
		
		protected var _ce:CitrusEngine;
		protected var _body:*;

		protected var _inverted:Boolean = false;
		protected var _parallax:Number = 1;
		protected var _animation:String = "";
		protected var _visible:Boolean = true;
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _z:Number = 0;
		protected var _rotation:Number = 0;
		protected var _radius:Number = 0;

		private var _group:Number = 0;
		private var _offsetX:Number = 0;
		private var _offsetY:Number = 0;
		private var _registration:String = "center";

		public function APhysicsObject(name:String, params:Object = null) {
			super(name, params);
		}
		
		public function get body():* {
			return _body;
		}
		
		public function get inverted():Boolean {
			return _inverted;
		}

		public function get parallax():Number {
			return _parallax;
		}
		
		public function get animation():String {
			return _animation;
		}
		
		public function get visible():Boolean {
			return _visible;
		}

		public function set visible(value:Boolean):void {
			_visible = value;
		}

		[Inspectable(defaultValue="1")]
		public function set parallax(value:Number):void {
			_parallax = value;
		}

		public function get group():Number {
			return _group;
		}

		[Inspectable(defaultValue="0")]
		public function set group(value:Number):void {
			_group = value;
		}

		public function get offsetX():Number {
			return _offsetX;
		}

		[Inspectable(defaultValue="0")]
		public function set offsetX(value:Number):void {
			_offsetX = value;
		}

		public function get offsetY():Number {
			return _offsetY;
		}

		[Inspectable(defaultValue="0")]
		public function set offsetY(value:Number):void {
			_offsetY = value;
		}

		public function get registration():String {
			return _registration;
		}

		[Inspectable(defaultValue="center",enumeration="center,topLeft")]
		public function set registration(value:String):void {
			_registration = value;
		}
	}
}
