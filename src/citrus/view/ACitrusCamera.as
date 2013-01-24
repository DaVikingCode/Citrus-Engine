package citrus.view {

	import citrus.core.CitrusEngine;
	import citrus.math.MathVector;
	import flash.geom.Point;

	import flash.geom.Rectangle;

	/**
	 * Citrus's camera.
	 */
	public class ACitrusCamera {
		
		/**
		 * should we restrict zoom to bounds?
		 */
		protected var _restrictZoom:Boolean = false;
		
		/**
		 * Is the camera allowed to Zoom?
		 */
		protected var _allowZoom:Boolean = false;
		
		/**
		 * Is the camera allowed to Rotate?
		 */
		protected var _allowRotation:Boolean = false;
		
		/**
		 * the ease factor for zoom
		 */
		public var zoomEasing:Number = 0.05;
		
		/**
		 * the ease factor for rotation
		 */
		public var rotationEasing:Number = 0.05;

		protected var _viewRoot:*;

		// Camera properties
		/**
		 * The thing that the camera will follow if a manual position is not set.
		 */
		protected var _target:Object;
		
		/**
		 * The camera position to be set manually if target is not set.
		 */
		protected var _manualPosition:Point;

		/**
		 * The distance from the top-left corner of the screen that the camera should offset the target. 
		 */
		public var offset:MathVector = new MathVector();

		/**
		 * A value between 0 and 1 that specifies the speed at which the camera catches up to the target.
		 * 0 makes the camera not follow the target at all and 1 makes the camera follow the target exactly. 
		 */
		public var easing:MathVector = new MathVector(0.25, 0.05);

		/**
		 * A rectangle specifying the minimum and maximum area that the camera is allowed to follow the target in. 
		 */
		public var bounds:Rectangle;

		/**
		 * The width of the visible game screen. This will usually be the same as your stage width unless your game has a border.
		 */
		public var cameraLensWidth:Number;

		/**
		 * The height of the visible game screen. This will usually be the same as your stage width unless your game has a border.
		 */
		public var cameraLensHeight:Number;

		public function ACitrusCamera(viewRoot:*) {

			_viewRoot = viewRoot;
			init();
		}
		
		/**
		 * Override this function to change the way camera lens dimensions are calculated 
		 * or to set other inital properties for the camera type.
		 */
		public function init():void {
			
			var ce:CitrusEngine = CitrusEngine.getInstance();
			cameraLensWidth = ce.stage.stageWidth;
			cameraLensHeight = ce.stage.stageHeight;	
		}
		
		/**
		 * Update the camera.
		 */
		public function update():void {
		}
		
		/*
		 * Getters and setters
		 */
		
		public function set target(o:Object):void {	
			_manualPosition = null;
			_target = o;
		}
		
		public function get target():Object {	
			return _target;
		}
		
		public function set manualPosition(p:Point):void {
			_target = null;
			_manualPosition = p;
		}
		
		public function get manualPosition():Point {	
			return _manualPosition;
		}
		
		public function set restrictZoom(value:Boolean):void {
			throw(new Error(this + " cannot zoom."));
		}
		
		public function get restrictZoom():Boolean {
			throw(new Error(this + " cannot zoom."));
		}
		
		public function set allowRotation(value:Boolean):void {
			throw(new Error(this + " cannot rotate."));
		}
		
		public function set allowZoom(value:Boolean):void {
			throw(new Error(this + " cannot zoom."));
		}
		
		public function get allowZoom():Boolean {
			throw(new Error(this + " cannot zoom."));
		}
		
		public function get allowRotation():Boolean {
			throw(new Error(this + " cannot rotate."));
		}
		
	}
}
