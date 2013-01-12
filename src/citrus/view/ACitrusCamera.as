package citrus.view {

	import citrus.core.CitrusEngine;
	import citrus.math.MathVector;
	import flash.geom.Point;

	import flash.geom.Rectangle;

	/**
	 * Citrus's camera.
	 */
	public class ACitrusCamera {

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

			var ce:CitrusEngine = CitrusEngine.getInstance();

			cameraLensWidth = ce.stage.stageWidth;
			cameraLensHeight = ce.stage.stageHeight;
		}
		
		/**
		 * Update the camera.
		 */
		public function update():void {
		}
		
		public function set target(o:Object):void {	
			_target = o;
		}
		
		public function get target():Object {	
			return _target;
		}
		
		public function set manualPosition(p:Point):void {
			_manualPosition = p;
		}
		
		public function get manualPosition():Point {	
			return _manualPosition;
		}
	}
}
