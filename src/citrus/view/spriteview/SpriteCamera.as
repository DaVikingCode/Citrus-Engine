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
			
			_aabbData = MathUtils.createAABBData(0, 0, cameraLensWidth / _camProxy.scale, cameraLensHeight / _camProxy.scale, _camProxy.rotation, _aabbData);
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
		
		/**
		 * @inheritDoc
		 */
		override public function zoomFit(width:Number,height:Number,storeInBaseZoom:Boolean = false):Number
		{
			if (_allowZoom)
			{
				var ratio:Number;
				if (cameraLensHeight / cameraLensWidth > height / width)
					ratio = cameraLensWidth / width;
				else
					ratio = cameraLensHeight / height;
				
				if (storeInBaseZoom)
				{
					baseZoom = ratio;
					_zoom = 1;
					return ratio;
				}
				else
					return _zoom = ratio;
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
		
		/**
		 * @inheritDoc
		 */
		override public function getZoom():Number
		{
			return _zoom;
		}
		
		/**
		 * @inheritDoc
		 */
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
				_aabbData.rect.setTo(_ghostTarget.x, _ghostTarget.y, cameraLensWidth, cameraLensHeight);
				return;
			}
			
			if (_allowZoom && !_allowRotation)
			{
				_aabbData.offsetX = _aabbData.offsetY = 0;
				_aabbData.rect.setTo(_ghostTarget.x, _ghostTarget.y, cameraLensWidth / _camProxy.scale, cameraLensHeight / _camProxy.scale);
				return;
			}
			
			if (_allowRotation && _allowZoom)
			{
				_aabbData = MathUtils.createAABBData(_ghostTarget.x , _ghostTarget.y, cameraLensWidth / _camProxy.scale, cameraLensHeight / _camProxy.scale, - _camProxy.rotation, _aabbData);
				return;
			}
		
			if (!_allowZoom && _allowRotation)
			{
				_aabbData = MathUtils.createAABBData(_ghostTarget.x , _ghostTarget.y, cameraLensWidth, cameraLensHeight, - _camProxy.rotation, _aabbData);
				return;
			}
		}

		override public function update():void {
			
			super.update();
			
			offset.setTo(cameraLensWidth * center.x, cameraLensHeight * center.y);
			
			if (_target && followTarget)
			{
				if (_target.x <= camPos.x - (deadZone.width * .5) / _camProxy.scale || _target.x >= camPos.x + (deadZone.width * .5) / _camProxy.scale )
					_targetPos.x = _target.x;			
				
				if (_target.y <= camPos.y - (deadZone.height * .5) / _camProxy.scale || _target.y >= camPos.y + (deadZone.height * .5) / _camProxy.scale)
					_targetPos.y = _target.y;				
					
				_ghostTarget.x += (_targetPos.x - _ghostTarget.x) * easing.x;
				_ghostTarget.y += (_targetPos.y - _ghostTarget.y) * easing.y;
				
			}
			else if (_manualPosition)
			{
				_ghostTarget.x = _manualPosition.x;
				_ghostTarget.y = _manualPosition.y;
			}
			
			if (_allowRotation)
				_camProxy.rotation += (_rotation - _camProxy.rotation) * rotationEasing;
			
			resetAABBData();
			
			if (_allowZoom)
			{

				_camProxy.scale += (mzoom - _camProxy.scale) * zoomEasing;
				
				if (bounds && (boundsMode == BOUNDS_MODE_AABB || boundsMode == BOUNDS_MODE_ADVANCED) )
				{
					var lwratio:Number = (_aabbData.rect.width*_camProxy.scale ) / bounds.width;
					var lhratio:Number = (_aabbData.rect.height*_camProxy.scale ) / bounds.height;
					
					if (_aabbData.rect.width >= bounds.width)
						_camProxy.scale = mzoom = lwratio;
					else if (_aabbData.rect.height >= bounds.height)
						_camProxy.scale = mzoom =  lhratio;
				}
				
			}
			
			_camProxy.x = ghostTarget.x;
			_camProxy.y = ghostTarget.y;
			
			MathUtils.rotatePoint(offset.x/_camProxy.scale, offset.y/_camProxy.scale, _camProxy.rotation, _b.rotoffset);
			
			if ( bounds )
			{
				if (boundsMode == BOUNDS_MODE_AABB)
				{

					_b.w2 = (_aabbData.rect.width - _b.rotoffset.x) + _aabbData.offsetX;
					_b.h2 = (_aabbData.rect.height - _b.rotoffset.y) + _aabbData.offsetY;
					
					_b.bl = bounds.left + ( MathUtils.abs(_aabbData.offsetX) + _b.rotoffset.x );
					_b.bt = bounds.top + ( MathUtils.abs(_aabbData.offsetY) + _b.rotoffset.y );
					_b.br = bounds.right - ( (_aabbData.offsetX+_aabbData.rect.width) - _b.rotoffset.x );
					_b.bb = bounds.bottom - ( (_aabbData.offsetY+_aabbData.rect.height) - _b.rotoffset.y);
					
					if (_camProxy.x < _b.bl)
						_camProxy.x = _b.bl;
					if (_camProxy.x > _b.br)
						_camProxy.x = _b.br;
					if (_camProxy.y < _b.bt)
						_camProxy.y = _b.bt;
					if (_camProxy.y > _b.bb)
						_camProxy.y = _b.bb;
						
				}else if (boundsMode == BOUNDS_MODE_OFFSET)
				{	
					if (_camProxy.x < bounds.left)
						_camProxy.x = bounds.left;
					if (_camProxy.x > bounds.right)
						_camProxy.x = bounds.right;
					if (_camProxy.y < bounds.top)
						_camProxy.y = bounds.top;
					if (_camProxy.y > bounds.bottom)
						_camProxy.y = bounds.bottom;
						
				}else if (boundsMode == BOUNDS_MODE_ADVANCED)
				{
					
					if (offset.x <= cameraLensWidth * 0.5) //left
					{
						if (offset.y <= cameraLensHeight * 0.5) //top
							_b.diag2 = MathUtils.DistanceBetweenTwoPoints(offset.x, cameraLensWidth, offset.y, cameraLensHeight);
						else
							_b.diag2 = MathUtils.DistanceBetweenTwoPoints(offset.x, cameraLensWidth, offset.y, 0);
					}else
					{
						if (offset.y <= cameraLensHeight * 0.5) //top
							_b.diag2 = MathUtils.DistanceBetweenTwoPoints(offset.x, 0, offset.y, cameraLensHeight);
						else
							_b.diag2 = offset.length;
					}
					
					_b.diag2 /= _camProxy.scale;
					
					if (_camProxy.x < bounds.left + _b.diag2)
						_camProxy.x = bounds.left + _b.diag2;
					if (_camProxy.x > bounds.right - _b.diag2)
						_camProxy.x = bounds.right - _b.diag2;
					if (_camProxy.y < bounds.top + _b.diag2)
						_camProxy.y = bounds.top + _b.diag2;
					if (_camProxy.y > bounds.bottom - _b.diag2)
						_camProxy.y = bounds.bottom - _b.diag2;
				}
			}
			
			if (parallaxMode == PARALLAX_MODE_TOPLEFT)
			{
				_m.identity();
				_m.rotate(_camProxy.rotation);
				_m.scale(1/_camProxy.scale, 1/_camProxy.scale);
				_camProxy.offset = _m.transformPoint(offset);
				_camProxy.offset.x *= -1;
				_camProxy.offset.y *= -1;
			}
			
			_aabbData.rect.x = _camProxy.x + _aabbData.offsetX - _b.rotoffset.x;
			_aabbData.rect.y = _camProxy.y + _aabbData.offsetY - _b.rotoffset.y;
			
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
			
			pointFromLocal(offset.x, offset.y, _camPos);
			
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
		
		/**
		 * @inheritDoc
		 */
		override public function get allowRotation():Boolean
		{
			return _allowRotation;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set allowZoom(value:Boolean):void
		{
			if (!value)
			{
				_zoom = 1;
				_camProxy.scale = 1;
			}
			_allowZoom = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set allowRotation(value:Boolean):void
		{
			if (!value)
			{
				_rotation = 0;
				_camProxy.rotation = 0;
			}
			_allowRotation = value;
		}
		
	}
}
