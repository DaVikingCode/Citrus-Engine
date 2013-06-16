package citrus.view.spriteview {

	import citrus.math.MathUtils;
	import citrus.view.ACitrusCamera;

	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * The Camera for the SpriteView.
	 */
	public class SpriteCamera extends ACitrusCamera {

		public function SpriteCamera(viewRoot:Sprite) {
			super(viewRoot);
		}
		
		override protected function initialize():void {
			super.initialize();
			
			_aabbData = MathUtils.createAABBData(0, 0, cameraLensWidth / _camProxy.scale, cameraLensHeight / _camProxy.scale, _camProxy.rotation);
		}
		
		/**
		 * multiplies the targeted zoom value by factor.
		 * @param	factor
		 */
		override public function zoom(factor:Number):void
		{
			if (_allowZoom)
				_zoom *= factor;
			else
				throw(new Error(this+"is not allowed to zoom. please set allowZoom to true."));
		}
		
		override public function zoomFit(width:Number,height:Number):void
		{
			if (_allowZoom)
			{
				var ratio:Number;
				if (cameraLensHeight / cameraLensWidth > height / width)
					ratio = cameraLensWidth / width;
				else
					ratio = cameraLensHeight / height;
				_zoom = ratio;
			}
			else
				throw(new Error(this+" is not allowed to zoom. please set allowZoom to true."));
		}
		
		/**
		 * rotates the camera by the angle.
		 * adds angle to targeted rotation value.
		 * @param	angle in radians.
		 */
		override public function rotate(angle:Number):void
		{
			if (_allowRotation)
				_rotation += angle;
			else
				throw(new Error(this+"is not allowed to rotate. please set allowRotation to true."));
		}
		
		/**
		 * sets the targeted rotation value to angle.
		 * @param	angle in radians.
		 */
		override public function setRotation(angle:Number):void
		{
			if (_allowRotation)
				_rotation = angle;
			else
				throw(new Error(this+"is not allowed to rotate. please set allowRotation to true."));
		}
		
		/**
		 * sets the targeted zoom value to factor.
		 * @param	factor
		 */
		override public function setZoom(factor:Number):void
		{
			if (_allowZoom)
				_zoom = factor;
			else
				throw(new Error(this+"is not allowed to zoom. please set allowZoom to true."));
		}
		
		override public function getZoom():Number
		{
			return _zoom;
		}
		
		override public function getRotation():Number
		{
			return _rotation;
		}
		
		/**
		 * Recreates the AABB of the camera.
		 * will use Math.Utils.createAABBData when allowRotation = true.
		 */
		public function resetAABBData():void
		{
			if (!_allowZoom && !_allowRotation)
			{
				_aabbData.offsetX = _aabbData.offsetY = 0;
				_aabbData.rect = new Rectangle(_ghostTarget.x, _ghostTarget.y, cameraLensWidth, cameraLensHeight);
				return;
			}
			
			if (_allowZoom && !_allowRotation)
			{
				_aabbData.offsetX = _aabbData.offsetY = 0;
				_aabbData.rect = new Rectangle(_ghostTarget.x, _ghostTarget.y, cameraLensWidth / _camProxy.scale, cameraLensHeight / _camProxy.scale);
				return;
			}
			
			if (_allowRotation && _allowZoom)
			{
				_aabbData = MathUtils.createAABBData(_ghostTarget.x , _ghostTarget.y, cameraLensWidth / _camProxy.scale, cameraLensHeight / _camProxy.scale, - _camProxy.rotation);
				return;
			}
		
			if (!_allowZoom && _allowRotation)
			{
				_aabbData = MathUtils.createAABBData(_ghostTarget.x , _ghostTarget.y, cameraLensWidth, cameraLensHeight, - _camProxy.rotation);
				return;
			}
		}

		override public function update():void {
			
			super.update();
			
			if (_allowRotation)
			{
				var diffRot:Number = _rotation - _camProxy.rotation;
				var velocityRot:Number = diffRot * rotationEasing;
				_camProxy.rotation += velocityRot;
			}
			
			if (_allowZoom)
			{

				var diffZoom:Number = mzoom - _camProxy.scale;
				var velocityZoom:Number = diffZoom * zoomEasing;
				_camProxy.scale += velocityZoom;
				
				if (bounds && _restrictZoom)
				{
					var lwratio:Number = (_aabbData.rect.width*_camProxy.scale ) / bounds.width;
					var lhratio:Number = (_aabbData.rect.height*_camProxy.scale ) / bounds.height;
					
					if (_aabbData.rect.width >= bounds.width)
						_camProxy.scale = mzoom = lwratio;
					else if (_aabbData.rect.height >= bounds.height)
						_camProxy.scale = mzoom =  lhratio;
				}
				
			}
			
			if (_target && followTarget)
			{
				_targetPos.x = _target.x;
				_targetPos.y = _target.y;
				
				var diffX:Number = _targetPos.x - _ghostTarget.x;
				var diffY:Number = _targetPos.y - _ghostTarget.y;
				var velocityX:Number = diffX * easing.x;
				var velocityY:Number = diffY * easing.y;
				
				_ghostTarget.x += velocityX;
				_ghostTarget.y += velocityY;
				
			}
			else if (_manualPosition)
			{
				_ghostTarget.x = _manualPosition.x;
				_ghostTarget.y = _manualPosition.y;
			}
			
			resetAABBData();
			
			_aabbData.rect.x = ghostTarget.x ;
			_aabbData.rect.y = ghostTarget.y ;
			
			_camProxy.x = _aabbData.rect.x;
			_camProxy.y = _aabbData.rect.y;
			
			if ( bounds )
			{
				if (_camProxy.x - offset.x/_camProxy.scale < bounds.left)
					_camProxy.x = bounds.left + offset.x/_camProxy.scale;
					
				if (_camProxy.x + offset.x/_camProxy.scale > bounds.right)
					_camProxy.x = bounds.right - offset.x/_camProxy.scale;
					
				if (_camProxy.y - offset.y/_camProxy.scale < bounds.top)
					_camProxy.y = bounds.top + offset.y/_camProxy.scale;
					
				if (_camProxy.y + offset.y/_camProxy.scale > bounds.bottom)
					_camProxy.y = bounds.bottom - offset.y/_camProxy.scale;
			}
			
			//reset matrix
			_m.identity();
			//fake pivot
			_m.translate( -_camProxy.x, -_camProxy.y);
			//rotation
			_m.rotate(_camProxy.rotation);
			//zoom
			_m.scale(_camProxy.scale, _camProxy.scale);
			//offset
			_m.translate(offset.x, offset.y);
			
			_camPos = _m.transformPoint(_p);
			
			(_viewRoot as Sprite).transform.matrix = _m;

		}
		
		public function pointFromLocal(x:Number,y:Number,resultPoint:Point = null):Point
		{
			_p.setTo(x, y);
			if(resultPoint)
				resultPoint.copyFrom((_viewRoot as Sprite).globalToLocal(_p));
			else
				return (_viewRoot as Sprite).globalToLocal(_p);
			return null;
		}
		
		/**
		 *  equivalent of localToGlobal
		 */
		public function pointToLocal(p:Point):Point
		{
			return (_viewRoot as Sprite).localToGlobal(p);
		}
		
		override public function get allowZoom():Boolean
		{
			return _allowZoom;
		}
		
		override public function get allowRotation():Boolean
		{
			return _allowRotation;
		}
		
		override public function set allowZoom(value:Boolean):void
		{
			if (!value)
			{
				_zoom = 1;
				_camProxy.scale = 1;
			}
			_allowZoom = value;
		}
		
		override public function set allowRotation(value:Boolean):void
		{
			if (!value)
			{
				_rotation = 0;
				_camProxy.rotation = 0;
			}
			_allowRotation = value;
		}
		
		override public function set restrictZoom(value:Boolean):void
		{
			_restrictZoom = value;
		}
		
		override public function get restrictZoom():Boolean
		{
			return _restrictZoom;
		}
	}
}
