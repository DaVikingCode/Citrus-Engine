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
	 *  /!\ STILL UNDER CONSTRUCTION
	 * 
	 * doesn't work with rotation yet, only zoom.
	 * 
	 * todos: 
	 * - fix zooming + easing unatural/ugly movement
	 * - introduce rotation correctly (using aabb for bound collision detection). (we're on the right path for that.)
	 * - functions for zooming and other cool functions for camera manipulation
	 */
	public class StarlingCamera extends ACitrusCamera {
		
		/**
		 * _cameraLens is the camera position relative to the target's coordinate system.
		 * camera Lens's rect will also be scaled according to the zoom factor.
		 * it holds the current zoom and rotation (seperately from _zoom and _rotation) for easing.
		 */
		protected var _cameraLens:Object = { rect:null,zoom:1,rotation:0 };
		
		protected var _zoomEasing:Number = 0.03;
		
		/**
		 * _aabb holds the axis aligned bounding box of the camera in rect
		 * and its relative position to it (with offsetX and offsetY)
		 */
		protected var _aabbData:Object = {};
		protected var _rotation:Number = 0;
		protected var _zoom:Number = 1;
		
		public function StarlingCamera (viewRoot:Sprite) {
			super(viewRoot);
			
			_cameraLens.rect = new Rectangle(0, 0, cameraLensWidth, cameraLensHeight);
			_aabbData = MathUtils.createAABBData(_cameraLens.rect.x, _cameraLens.rect.y, _cameraLens.rect.width/_cameraLens.zoom, _cameraLens.rect.height/_cameraLens.zoom, _cameraLens.rotation);
		}
		
		// cameraLens should be read only.
		public function get cameraLens():Object
		{
			return _cameraLens;
		}
		
		public function set rotation(val:Number):void
		{
			_rotation = val;
		}
		
		public function get rotation():Number
		{
			return _rotation;
		}
		
		//these are not useful at the moment
		public function set zoom(val:Number):void
		{
			_zoom = val;
		}
		
		public function get zoom():Number
		{
			return _zoom;
		}
		
		public function resetAABBData():void
		{
			_aabbData = MathUtils.createAABBData(_cameraLens.rect.x, _cameraLens.rect.y, _cameraLens.rect.width, _cameraLens.rect.height, _cameraLens.rotation);
		}
		
		override public function update():void {
			
			//ease zoom and rotation first. zoom is the last modifier we need
			
			var diffRot:Number = _rotation - _cameraLens.rotation;
			var velocityRot:Number = diffRot * (easing.x+easing.y)/2; //easing factor is temporary.
			_cameraLens.rotation += velocityRot;
			
			var diffZoom:Number = _zoom - _cameraLens.zoom;
			var velocityZoom:Number = diffZoom * _zoomEasing;
			_cameraLens.zoom += velocityZoom;
			
			/**
			 * create new _aabbData with new rotation value.
			 * we will move x and y later on.
			 */
			
			_aabbData = MathUtils.createAABBData(0, 0, _cameraLens.rect.width, _cameraLens.rect.height, _cameraLens.rotation);
		
			/**
			 * rotate offset.
			 * we want the target to be at this position(x axis is similar to y axis) :
			 * ( _aabbData.rect.x + _aabbData.offsetX + rotatedOffset.x ) / _cameraLens.zoom
			 * (which in case of offset being the center of the camera,
			 * would be the center of the camera projected to the state's coordinate.)
			 */
			
			var rotatedOffset:Point = rotatePoint(new Point(0,0), new Point(offset.x, offset.y), - _cameraLens.rotation);
			
			/**
			 * bounds collision check and limit zoom.
			 * notes:
			 * - Zoom : we will check against ratio between _aabbData.rect and bounds width.
			 * if _aabbData is too big for the bounds, then we use this ratio to "scale down" the actual zoom
			 * since camera size and its aabb are proportional.
			 * - bounds : again we will be checking a collision of the bounds with _aabbData.rect 
			 * since camera is possibly rotated.
			 */
			
			if (bounds) {
				var lwratio:Number = _aabbData.rect.width / bounds.width;
				var lhratio:Number = _aabbData.rect.height / bounds.height;
				
				if ( _aabbData.rect.width > bounds.width * _cameraLens.zoom)
					_cameraLens.zoom = lwratio;
				else if (_aabbData.rect.height > bounds.height * _cameraLens.zoom)
					_cameraLens.zoom = lhratio;
			}
			
			//follow target position.
			
			if (target)
			{
				var diffX:Number = (target.x * _cameraLens.zoom - rotatedOffset.x) - _cameraLens.rect.x - _aabbData.offsetX;
				var diffY:Number = (target.y * _cameraLens.zoom - rotatedOffset.y) - _cameraLens.rect.y - _aabbData.offsetY;
				var velocityX:Number = diffX * easing.x;
				var velocityY:Number = diffY * easing.y;
				
				_cameraLens.rect.x += velocityX;
				_cameraLens.rect.y += velocityY;
			}
			
			// move aabb rect with us;
			_aabbData.rect.x = _cameraLens.rect.x;
			_aabbData.rect.y = _cameraLens.rect.y
			
			if (bounds) {
				
				if ( _aabbData.rect.x <= bounds.left * _cameraLens.zoom || bounds.width * _cameraLens.zoom < _aabbData.rect.width)
					_cameraLens.rect.x = bounds.left * _cameraLens.zoom - _aabbData.offsetX ;
				else if ( _aabbData.rect.x >= bounds.right * _cameraLens.zoom - _aabbData.rect.width)
					_cameraLens.rect.x = bounds.right * _cameraLens.zoom - _cameraLens.rect.width + _aabbData.offsetX ;
					
				if ( _aabbData.rect.y <= bounds.top * _cameraLens.zoom || bounds.height < _aabbData.rect.height )
					_cameraLens.rect.y = bounds.top * _cameraLens.zoom - _aabbData.offsetY ;
				else if ( _aabbData.rect.y >= bounds.bottom * _cameraLens.zoom - _aabbData.rect.height)
					_cameraLens.rect.y = bounds.bottom * _cameraLens.zoom - _cameraLens.rect.height + _aabbData.offsetY ;
			}
			
			_viewRoot.x =  - _cameraLens.rect.x ;
			_viewRoot.y =  - _cameraLens.rect.y ;
			_viewRoot.scaleX = _viewRoot.scaleY = _cameraLens.zoom;
			_viewRoot.rotation = _cameraLens.rotation;
			
		}
		
		/**
		 * local helper to rotate offset and other points - will be removed
		 */
		private function rotatePoint(offset:Point, p:Point, a:Number):Point
		{
			var c:Number = Math.cos(a);
			var s:Number = Math.sin(a);
			return new Point(offset.x + p.x * c + p.y * s , offset.y + -p.x * s + p.y * c);
		}
		
		/**
		 * A little function to debug the camera behavior in a "mini map" sprite
		 * with the bounds and aabbox rendered around the rotated camera lens
		 * @param	sprite an empty flash sprite added to stage used for debug.
		 */
		private function renderDebugDraw(sprite:*):void
		{
			
			 //debug draw camera rect + bounds + aabb
				sprite.scaleX = sprite.scaleY = 200/bounds.width;
				sprite.x = sprite.y = 100;
				
				//clear
				sprite.graphics.clear();
				sprite.graphics.lineStyle(3, 0xFF0000);
				//bounds
				sprite.graphics.drawRect(0, 0, bounds.width *_cameraLens.zoom, bounds.height *_cameraLens.zoom);
				//aabb
				sprite.graphics.lineStyle(4, 0x00FF00);
				sprite.graphics.drawRect(
				_aabbData.rect.x,
				_aabbData.rect.y,
				_aabbData.rect.width,
				_aabbData.rect.height
				);
				
				sprite.graphics.lineStyle(2, 0xFFFF00);
				
				//rotated camera rect
				var a:Number = -_cameraLens.rotation;
				var c:Number = Math.cos(a);
				var s:Number = Math.sin(a);
				
				var w:Number = _cameraLens.rect.width ;
				var h:Number = _cameraLens.rect.height ;
				
				var xo:Number =  _cameraLens.rect.x - _aabbData.offsetX ;
				var yo:Number =  _cameraLens.rect.y - _aabbData.offsetY ;
				
				sprite.graphics.moveTo(xo, yo);
				sprite.graphics.lineTo(xo + (w) * c + (0) * s , yo + -(w) * s + (0) * c);
				sprite.graphics.lineTo(xo + (w) * c + (h) * s , yo + -(w) * s + (h) * c);
				sprite.graphics.lineTo(xo + (0) * c + (h) * s , yo + -(0) * s + (h) * c);
				sprite.graphics.lineTo(xo, yo);
				
				var rotatedOffset:Point = rotatePoint(new Point(0, 0), new Point(offset.x, offset.y), -_cameraLens.rotation);
				sprite.graphics.lineStyle(2, 0xFF00FF);
				sprite.graphics.moveTo(xo, yo);
				sprite.graphics.lineTo(xo + rotatedOffset.x, yo + rotatedOffset.y);
				
				sprite.graphics.lineStyle(0.1, 0x0000FF);
				sprite.graphics.moveTo(0, 0);
				sprite.graphics.lineTo(
				_cameraLens.rect.x - _aabbData.offsetX + rotatedOffset.x,
				_cameraLens.rect.y - _aabbData.offsetY + rotatedOffset.y
				);
		}
	}
}