package citrus.view {

	import citrus.core.CitrusEngine;
	import citrus.math.MathVector;

	import flash.geom.Rectangle;

	/**
	 * Citrus's camera.
	 */
	public class CitrusCamera {

		private var _viewRoot:*;

		// Camera properties
		/**
		 * The thing that the camera will follow. 
		 */
		public var target:Object;

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

		public function CitrusCamera(viewRoot:*) {

			_viewRoot = viewRoot;

			var ce:CitrusEngine = CitrusEngine.getInstance();

			cameraLensWidth = ce.stage.stageWidth;
			cameraLensHeight = ce.stage.stageHeight;
		}
		
		/**
		 * Update the camera.
		 * @param mode Defines the camera render mode, it may differs between blitting, 3D and classic modes.
		 */
		public function update(mode:String = ""):void {
			
			if (target) {
				
				var diffX:Number, diffY:Number, velocityX:Number, velocityY:Number;
				
				if (mode == "blitting") {
					
						diffX = (target.x - offset.x) - _viewRoot.x;
						diffY = (target.y - offset.y) - _viewRoot.y;
						velocityX = diffX * easing.x;
						velocityY = diffY * easing.y;
						
						_viewRoot.x += velocityX;
						_viewRoot.y += velocityY;
					
					if (bounds) {
						
						if (_viewRoot.x <= bounds.left || bounds.width < cameraLensWidth)
							_viewRoot.x = bounds.left;
						else if (_viewRoot.x + cameraLensWidth >= bounds.right)
							_viewRoot.x = bounds.right - cameraLensWidth;
	
						if (_viewRoot.y <= bounds.top || bounds.height < cameraLensHeight)
							_viewRoot.y = bounds.top;
						else if (_viewRoot.y + cameraLensHeight >= bounds.bottom)
							_viewRoot.y = bounds.bottom - cameraLensHeight;
					}
					
				} else {
					//SpriteView, StarlingView and Away3DView
					
					diffX = (-target.x + offset.x) - _viewRoot.x;
					diffY = (-target.y + offset.y) - _viewRoot.y;
					velocityX = diffX * easing.x;
					velocityY = diffY * easing.y;
					
					_viewRoot.x += velocityX;
					_viewRoot.y += velocityY;
					
					if (bounds) {
						
						if (-_viewRoot.x <= bounds.left || bounds.width < cameraLensWidth)
							_viewRoot.x = -bounds.left;
						else if (-_viewRoot.x + cameraLensWidth >= bounds.right)
							_viewRoot.x = -bounds.right + cameraLensWidth;
						
						if (-_viewRoot.y <= bounds.top || bounds.height < cameraLensHeight)
							_viewRoot.y = -bounds.top;
						else if (-_viewRoot.y + cameraLensHeight >= bounds.bottom)
							_viewRoot.y = -bounds.bottom + cameraLensHeight;
					}
				}
				
				
			}
		}
	}
}
