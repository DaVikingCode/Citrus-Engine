package citrus.view.starlingview {

	import citrus.view.ACitrusCamera;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import citrus.math.MathUtils;
	
	import starling.display.Sprite;

	/**
	 * The Camera for the StarlingView.
	 * 
	 * notes from gsynuh : Currently a work in progress camera prototype with zooming and rotation.
	 * 
	 * I left some commented out code for myself and/or others. this is strictly not to be considered as working and not the final
	 * formatted code.
	 * 
	 * If you happen to solve a problem - zooming and/or rotation, please remove my unecessary code.
	 * 
	 * Anyway this should be a "stable" beta version for the zoom feature.
	 * tested only with an offset at center of screen, and a lot of different zoom factors.
	 * 
	 * usable this way : (view.camera as StarlingCamera).zoom = 2;
	 * to change the "target zoom" to 2, and the camera will ease into a zoom of 2.
	 * the camera should stay within bounds and the debug view should follow as well (see StarlingArt).
	 * 
	 * zooming looks ugly as pivotX is not moved around (so it zooms "around" (0,0) , not the offset, and even though we end up seeing target
	 * where we need to ultimately, this results in weird movements when the easing is done (as zoom actually changes the distance)
	 * 
	 * one tested solution was to move pivotX/pivotY of viewRoot to be always at (0,0)
	 * and so keep the viewRoot's x and y at offset.x offset.y ... so that zooming will be centered
	 * and will not affect easing. but we should assume the pivot system doesn't exist to easily port this camera to spriteview
	 * 
	 * todos: 
	 * - fix zooming + easing unatural/ugly movement
	 * - introduce rotation correctly (using aabb for bound collision detection).
	 * - optimize calls to createAABB by calling it only when orientation has changed.
	 */
	public class StarlingCamera extends ACitrusCamera {
		
		/**
		 * _cameraLens is the camera position relative to the target's coordinate system.
		 * camera Lens's rect will also be scaled according to the zoom factor.
		 * it holds the current zoom and rotation (seperately from _zoom and _rotation) for easing.
		 */
		protected var _cameraLens:Object = { rect:null,zoom:2,rotation:0 };
		
		protected var _zoomEasing:Number = 0.03;
		
		/**
		 * _aabb hold the axis aligned bounding box of the camera if necessary (in starling, and sprite...)
		 * should move this out of ACitrusCamera
		 */
		protected var _aabb:Rectangle;
		protected var _rotation:Number = 0;
		protected var _zoom:Number = 0.2;
		
		public function StarlingCamera (viewRoot:Sprite) {
			super(viewRoot);
			
			_cameraLens.rect = new Rectangle(0, 0, cameraLensWidth, cameraLensHeight);
			_aabb = MathUtils.createAABB(_cameraLens.rect.x, _cameraLens.rect.y, _cameraLens.rect.width, _cameraLens.rect.height, _rotation);
		}
		
		/**
		 * may need some getters and setters to generate _aabb only when needed.
		 */
		
		// cameraLens should be read only.
		public function get cameraLens():Object
		{
			return _cameraLens;
		}
		
		/*public function set rotation(val:Number):void
		{
			_rotation = val;
		}
		
		public function get rotation():Number
		{
			return _rotation;
		}*/
		
		//these are not useful at the moment
		public function set zoom(val:Number):void
		{
			_zoom = val;
		}
		
		public function get zoom():Number
		{
			return _zoom;
		}
		
		public function resetAABB():void
		{
			_aabb = MathUtils.createAABB(_cameraLens.rect.x, _cameraLens.rect.y, _cameraLens.rect.width/_cameraLens.zoom, _cameraLens.rect.height/_cameraLens.zoom, _rotation);
		}
		
		override public function update():void {

			super.update();
			
			if (!_cameraLens.rect)
				_cameraLens.rect = new Rectangle(0, 0, cameraLensWidth, cameraLensHeight);
				
				
			if (target) {
				
				var diffX:Number = (target.x*_cameraLens.zoom - offset.x) - _cameraLens.rect.x;
				var diffY:Number = (target.y*_cameraLens.zoom - offset.y) - _cameraLens.rect.y;
				var velocityX:Number = diffX * easing.x;
				var velocityY:Number = diffY * easing.y;
				
				_cameraLens.rect.x += velocityX;
				_cameraLens.rect.y += velocityY;
				
				var diffZoom:Number = _zoom - _cameraLens.zoom;
				var velocityZoom:Number = diffZoom * _zoomEasing;
				_cameraLens.zoom += velocityZoom;
				
				/*var diffRot:Number = _rotation - _cameraLens.rotation;
				var velocityRot:Number = diffRot * (easing.x+easing.y)/2;
				_cameraLens.rotation += velocityRot;*/
						
				if (bounds) {
					
					var lwratio:Number = _cameraLens.rect.width / bounds.width;
					var lhratio:Number = _cameraLens.rect.height / bounds.height;
					
					// prevent too much zooming out, if "lens" goes out of bounds, set a new zoom.
					if ( _cameraLens.rect.width > bounds.width *_cameraLens.zoom)
						_cameraLens.zoom = lwratio;
					else if (_cameraLens.rect.height > bounds.height *_cameraLens.zoom)
						_cameraLens.zoom = lhratio;
					
					//when rotated, check position and dimensions of _aabb, not actual cameraLens.rect
					//resetAABB();
					
					if (_cameraLens.rect.x <= bounds.left * _cameraLens.zoom || bounds.width * _cameraLens.zoom < _cameraLens.rect.width)
						_cameraLens.rect.x = bounds.left / _cameraLens.zoom;
					else if ( _cameraLens.rect.x >= bounds.right * _cameraLens.zoom - _cameraLens.rect.width)
						_cameraLens.rect.x = bounds.right * _cameraLens.zoom - _cameraLens.rect.width;
					
					if (_cameraLens.rect.y <= bounds.top * _cameraLens.zoom || bounds.height * _cameraLens.zoom < _cameraLens.rect.height)
						_cameraLens.rect.y = bounds.top / _cameraLens.zoom;
					else if ( _cameraLens.rect.y >= bounds.bottom * _cameraLens.zoom - _cameraLens.rect.height)
						_cameraLens.rect.y = bounds.bottom * _cameraLens.zoom - _cameraLens.rect.height;
				}
				
				//instead of recreating aabb when position changes, recreate it only when rotation changes - and move aabb around.
				_aabb.x = _cameraLens.rect.x;
				_aabb.y = _cameraLens.rect.y;
				
				_viewRoot.x =  -_cameraLens.rect.x ;
				_viewRoot.y =  -_cameraLens.rect.y ;
				
				_viewRoot.scaleX = _viewRoot.scaleY = _cameraLens.zoom;
				
			}

		}
	}
}
