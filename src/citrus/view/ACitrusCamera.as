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
		 * the targeted rotation value.
		 */
		protected var _rotation:Number = 0;
		
		/**
		 * the targeted zoom value.
		 */
		protected var _zoom:Number = 1;
		
		/**
		 * _aabb holds the axis aligned bounding box of the camera in rect
		 * and its relative position to it (with offsetX and offsetY)
		 */
		protected var _aabbData:Object = { };
		
		/**
		 * ghostTarget is the eased position of target.
		 */
		protected var _ghostTarget:Point = new Point();
		
		/**
		 * targetPos is used for calculating ghostTarget.
		 * (not sure if really necessary)
		 */
		protected var _targetPos:Point = new Point();
		
		/**
		 * the _camProxy object is used as a container to hold the data to be applied to the _viewroot.
		 * it can be accessible publicly so that debugView can be correctly displaced, rotated and scaled as _viewroot will be.
		 */
		protected var _camProxy:Object = { x: 0, y: 0, offsetX: 0, offsetY: 0, scale: 1, rotation: 0 };
		
		/**
		 * projected camera position + offset. (used internally)
		 */
		protected var _camPos:Point = new Point();
		
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
		 * This is a non-critical helper function that allows you to quickly set all the available camera properties in one place. 
		 * @param target The thing that the camera should follow.
		 * @param offset The distance from the upper-left corner that you want the camera to be offset from the target.
		 * @param bounds The rectangular bounds that the camera should not extend beyond.
		 * @param easing The x and y percentage of distance that the camera will travel toward the target per tick. Lower numbers are slower. The number should not go beyond 1.
		 */		
		public function setUp(target:Object = null, offset:MathVector = null, bounds:Rectangle = null, easing:MathVector = null):void
		{
			if (target)
				this.target = target;
			if (offset)
				this.offset = offset;
			if (bounds)
				this.bounds = bounds;
			if (easing)
				this.easing = easing;
		}
		
		public function zoom(factor:Number):void {
			throw(new Error("Warning: " + this + " cannot zoom."));
		}
		
		public function rotate(angle:Number):void {
			throw(new Error("Warning: " + this + " cannot rotate."));
		}
		
		public function setRotation(angle:Number):void {
			throw(new Error("Warning: " + this + " cannot rotate."));
		}
		
		public function setZoom(factor:Number):void {
			throw(new Error("Warning: " + this + " cannot zoom."));
		}
		
		public function getZoom():Number {
			throw(new Error("Warning: " + this + " cannot zoom."));
		}
		
		public function getRotation():Number {
			throw(new Error("Warning: " + this + " cannot rotate."));
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
		
		public function get camPos():Point {
			return _camPos;
		}
		
		public function set manualPosition(p:Point):void {
			_target = null;
			_manualPosition = p;
		}
		
		public function get manualPosition():Point {	
			return _manualPosition;
		}
		
		public function set restrictZoom(value:Boolean):void {
			throw(new Error("Warning: " + this + " cannot zoom."));
		}
		
		public function get restrictZoom():Boolean {
			throw(new Error("Warning: " + this + " cannot zoom."));
		}
		
		public function set allowRotation(value:Boolean):void {
			throw(new Error("Warning: " + this + " cannot rotate."));
		}
		
		public function set allowZoom(value:Boolean):void {
			throw(new Error("Warning: " + this + " cannot zoom."));
		}
		
		public function get allowZoom():Boolean {
			throw(new Error("Warning: " + this + " cannot zoom."));
		}
		
		public function get allowRotation():Boolean {
			throw(new Error("Warning: " + this + " cannot rotate."));
		}
		
		/**
		 * camProxy is read only.
		 * contains the data to be applied to container layers (_viewRoot and debug views).
		 */
		public function get camProxy():Object {
			return _camProxy;
		}
		
		/**
		 * read-only to get the eased position of the target, which is the actual point the camera
		 * is looking at ( - the offset )
		 */
		public function get ghostTarget():Point {
			return _ghostTarget;
		}
		
	}
}
