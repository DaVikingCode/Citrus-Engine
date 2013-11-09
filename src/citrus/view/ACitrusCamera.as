package citrus.view {

	import citrus.core.CitrusEngine;

	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;


	/**
	 * Citrus's camera.
	 */
	public class ACitrusCamera {
		
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
		 * base zoom - this is the overall zoom factor of the camera
		 */
		public var baseZoom:Number = 1;
		
		/**
		 * _aabb holds the axis aligned bounding box of the camera in rect
		 * and its relative position to it (with offsetX and offsetY)
		 */
		protected var _aabbData:Object = {offsetX:0, offsetY:0, rect:new Rectangle() };
		
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
		protected var _camProxy:Object = { x: 0, y: 0, offset:new Point(), scale: 1, rotation: 0 };
		
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
		 * decides wether the camera will be updated by citrus engine.
		 * If you use the camera only for multi resolution purposes or for 'non moving' states,
		 * you may disable the camera to save some performances. In such cases, you may still call
		 * reset() in the state's initialize() so that the camera will set itself up at the right position/zoom/rotation.
		 */
		public var enabled:Boolean = true;

		/**
		 * The distance from the top-left corner of the screen that the camera should offset the target. 
		 */
		public var offset:Point = new Point();

		/**
		 * A value between 0 and 1 that specifies the speed at which the camera catches up to the target.
		 * 0 makes the camera not follow the target at all and 1 makes the camera follow the target exactly. 
		 */
		public var easing:Point = new Point(0.25, 0.05);

		/**
		 * A rectangle specifying the minimum and maximum area that the camera is allowed to follow the target in. 
		 */
		public var bounds:Rectangle;

		/**
		 * The width of the visible game screen. This will usually be the same as your stage width unless your game has a border.
		 */
		public var cameraLensWidth:Number;
		
		public var followTarget:Boolean = true;

		/**
		 * The height of the visible game screen. This will usually be the same as your stage width unless your game has a border.
		 */
		public var cameraLensHeight:Number;
		
		/**
		 * helper matrix for transformation
		 */
		protected var _m:Matrix = new Matrix();
		
		/**
		 * helper point
		 */
		protected var _p:Point = new Point();
		
		/**
		 * helper rectangle
		 */
		protected var _r:Rectangle = new Rectangle();
		
		/**
		 * camera rectangle
		 */
		protected var _rect:Rectangle = new Rectangle();
		
		/**
		 * helper object for bounds checking
		 */
		protected var _b:Object = { w2:0, h2:0, diag2:0, rotoffset:new Point(), br:0, bl:0, bt:0, bb:0 };
		
		/**
		 * this mode will force the camera (and its 'content') to be contained within the bounds.
		 * zoom will be restricted - and recalculated if required.
		 * this restriction is based on the camera's AABB rectangle,you will never see anything out of the bounds.
		 * actually makes the camera 'hit' the bounds, the camera will be displaced to prevent it.
		 */
		public static const BOUNDS_MODE_AABB:String = "BOUNDS_MODE_AABB"; 
		
		/**
		 * this mode will force the offset point of the camera to stay within the bounds (whatever the zoom and rotation are)
		 * things can be seen outside of the bounds, but there's no zoom recalculation or camera displacement when rotating and colliding with the bounds 
		 * unlike the other mode.
		 */
		public static const BOUNDS_MODE_OFFSET:String = "BOUNDS_MODE_OFFSET"; 
		
		/**
		 * This mode is a mix of the two other modes :
		 * The camera offset point is now contained inside inner bounds  which allows to never see anything outside of the level
		 * like the AABB mode, but unlike the AABB mode, when rotating, the camera doesn't collide with borders as the inner bounds
		 * sides are distant from their correspoding bounds sides from the camera's half diagonal length :
		 * this means the camera can freely rotate in a circle, and that circle cannot go out of the defined bounds.
		 * this also means the corners of the bounded area will never be seen.
		 */
		public static const BOUNDS_MODE_ADVANCED:String = "BOUNDS_MODE_ADVANCED"; 
		
		/**
		 * how camera movement should be allowed within the defined bounds.
		 * defaults to ACitrusCamera.BOUNDS_MODE_AABB
		 */
		public var boundsMode:String = BOUNDS_MODE_AABB;
		
		/**
		 * the parallaxed objects are based on (0,0) of the level.
		 * this is how parallax has been applied since the beginning of CE.
		 */
		public static const PARALLAX_MODE_TOPLEFT:String = "PARALLAX_MODE_TOPLEFT";
		
		/**
		 * parallaxed objects are 'displaced' according to their parallax value from the center of the camera,
		 * giving a perspective/fake depth effect where the vanishing point is the center of the camera.
		 */
		public static const PARALLAX_MODE_DEPTH:String = "PARALLAX_MODE_DEPTH";
		
		/**
		 * defines the way parallax is applied to objects position.
		 * the default is PARALLAX_MODE_TOPLEFT.
		 */
		public var parallaxMode:String = PARALLAX_MODE_TOPLEFT;
		
		protected var _ce:CitrusEngine;

		public function ACitrusCamera(viewRoot:*) {

			_viewRoot = viewRoot;
			initialize();
		}
		
		/**
		 * Override this function to change the way camera lens dimensions are calculated 
		 * or to set other inital properties for the camera type.
		 */
		protected function initialize():void {
			
			_ce = CitrusEngine.getInstance();
			cameraLensWidth = _ce.screenWidth;
			cameraLensHeight = _ce.screenHeight;	
		}
		
		/**
		 * This is a non-critical helper function that allows you to quickly set all the available camera properties in one place. 
		 * @param target The thing that the camera should follow.
		 * @param offset The distance from the upper-left corner that you want the camera to be offset from the target.
		 * @param bounds The rectangular bounds that the camera should not extend beyond.
		 * @param easing The x and y percentage of distance that the camera will travel toward the target per tick. Lower numbers are slower. The number should not go beyond 1.
		 * @param cameraLens The width and height of the visible game screen. Default is the same as your stage width and height.
		 * @return this The Instance of the ACitrusCamera.
		 */		
		public function setUp(target:Object = null, offset:Point = null, bounds:Rectangle = null, easing:Point = null, cameraLens:Point = null):ACitrusCamera
		{
			if (target)
			{
				this.target = target;
				_ghostTarget.x = target.x;
				_ghostTarget.y = target.y;
			}
			if (offset)
				this.offset = offset;
			if (bounds)
				this.bounds = bounds;	
			if (easing)
				this.easing = easing;
			if (cameraLens) {
				cameraLensWidth = cameraLens.x;
				cameraLensHeight = cameraLens.y;
			}
				
			return this;
		}
		
		/**
		 * sets camera transformation with no easing
		 * by setting all easing values to 1 temporarily and updating camera once.
		 * can be called at the beginning of a state to prevent camera effects then.
		 */
		public function reset():void
		{
			var tmp1:Point = easing.clone();
			var tmp2:Number = rotationEasing;
			var tmp3:Number = zoomEasing;
			
			rotationEasing = 1;
			zoomEasing = 1;
			easing.setTo(1, 1);
			
			update();
			
			easing.copyFrom(tmp1);
			rotationEasing = tmp2;
			zoomEasing = tmp3;
		}
		
		public function zoom(factor:Number):void {
			throw(new Error("Warning: " + this + " cannot zoom."));
		}
		
		/**
		 * fits a defined area within the camera lens dimensions.
		 * Similar to fitting a rectangle inside another rectangle by multiplying its size,
		 * therefore keeping its aspect ratio. the factor used to fit is returned 
		 * and set as the current target zoom factor.
		 * 
		 * if storeInBaseZoom is set to true, then the calculated ratio is stored in the camera's baseZoom
		 * and from now, all zoom will be relative to that ratio (baseZoom is 1 by default and multiplied
		 * to every zoom operations you do using the camera methods) - this helps create relative zoom effects
		 * while keeping a base zoom when zooming at 1 where the camera would still fit the area you decided :
		 * specially usefull for multi resolution handling.
		 * @param width width of the area to fit inside the camera lens dimensions.
		 * @param height height of the area to fit inside the camera lens dimensions.
		 * @param storeInBaseZoom , whether to store the ratio into baseZoom or not.
		 * @return calculated zoom ratio
		 */
		public function zoomFit(width:Number, height:Number, storeInBaseZoom:Boolean = false):Number {
			throw(new Error("Warning: " + this + " cannot zoomFit."));
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
		
		/**
		 * zoom with base factor
		 */
		protected function get mzoom():Number {
			return _zoom * baseZoom;
		}
		
		protected function set mzoom(val:Number):void {
			_zoom = val / baseZoom;
		}
		
		/**
		 * This is the transform matrix the camera applies to the state viewroot.
		 * it is also applied to the physics debug view.
		 */
		public function get transformMatrix():Matrix
		{
			return _m;
		}
		
		/**
		 * Check is the given coordinates in State space are contained within the camera.
		 * 
		 * set the area argument to define a different area of the screen, for example if you want to check
		 * further left/right/up/down than the camera's default rectangle which is : (0,0,cameraLensWidth,cameraLensHeight)
		 */
		public function contains(xa:Number,ya:Number,area:Rectangle = null):Boolean
		{
			_p.setTo(xa, ya);
			
			if(!area)
				_rect.setTo(0, 0, cameraLensWidth, cameraLensHeight);
			else
				_rect.copyFrom(area);
			
			_p.copyFrom(_m.transformPoint(_p));
			
			return _rect.contains(_p.x, _p.y);
		}
		
		/**
		 * Check is the given rectangle in state space is fully contained within the camera.
		 * will return false even if partially visible, collision with borders included.
		 * 
		 * set the area argument to define a different area of the screen, for example if you want to check
		 * further left/right/up/down than the camera's default rectangle which is : (0,0,cameraLensWidth,cameraLensHeight)
		 */
		public function containsRect(rectangle:Rectangle, area:Rectangle = null):Boolean
		{
			_p.setTo(rectangle.x + rectangle.width * .5, rectangle.y + rectangle.height * .5);
			
			if(!area)
				_rect.setTo(0, 0, cameraLensWidth, cameraLensHeight);
			else
				_rect.copyFrom(area);
			
			_p.copyFrom(_m.transformPoint(_p));
			_r.setTo(_p.x - rectangle.width * .5, _p.y - rectangle.height * .5, rectangle.width, rectangle.height);
			return _rect.containsRect(_r);
		}
		
		/**
		 * Check is the given rectangle in state space intersects with the camera rectangle.
		 * (if its partially visible, true will be returned.
		 * 
		 * set the area argument to define a different area of the screen, for example if you want to check
		 * further left/right/up/down than the camera's default rectangle which is : (0,0,cameraLensWidth,cameraLensHeight)
		 */
		public function intersectsRect(rectangle:Rectangle, area:Rectangle = null):Boolean
		{
			_p.setTo(rectangle.x + rectangle.width * .5, rectangle.y + rectangle.height * .5);
			
			if(!area)
				_rect.setTo(0, 0, cameraLensWidth, cameraLensHeight);
			else
				_rect.copyFrom(area);
			
			_p.copyFrom(_m.transformPoint(_p));
			_r.setTo(_p.x - rectangle.width * .5, _p.y - rectangle.height * .5, rectangle.width, rectangle.height);
			return _rect.intersects(_r);
		}
		
		/**
		 * returns the camera's axis aligned bounding rectangle in State space.
		 */
		public function getRect():Rectangle
		{
			return _aabbData.rect;
		}
		
	}
}
