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
		
		override public function init():void {
			super.init();
			
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
				var diffZoom:Number = _zoom - _camProxy.scale;
				var velocityZoom:Number = diffZoom * zoomEasing;
				_camProxy.scale += velocityZoom;
			}
			
			var invRotTarget:Point;
			
			if (_target)
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
			
			invRotTarget = (_allowRotation) ? MathUtils.rotatePoint(new Point(_ghostTarget.x, _ghostTarget.y), -_camProxy.rotation) : new Point(_ghostTarget.x, _ghostTarget.y);
				
			_camProxy.x = -invRotTarget.x * _camProxy.scale;
			_camProxy.y = -invRotTarget.y * _camProxy.scale;
			
			_camProxy.offsetX = offset.x;
			_camProxy.offsetY = offset.y;
			
			_camProxy.x += _camProxy.offsetX;
			_camProxy.y += _camProxy.offsetY;
			
			resetAABBData();
			
			if (bounds && _restrictZoom)
			{
				var lwratio:Number = _aabbData.rect.width*_camProxy.scale / bounds.width;
				var lhratio:Number = _aabbData.rect.height*_camProxy.scale / bounds.height;
				
				if (_aabbData.rect.width > bounds.width)
					_camProxy.scale = _zoom = lwratio;
				else if (_aabbData.rect.height > bounds.height)
					_camProxy.scale = _zoom = lhratio;
				
			}
			
			var rotScaledOffset:Point;
			
			rotScaledOffset = (_allowRotation) ?
				MathUtils.rotatePoint( new Point(offset.x / _camProxy.scale, offset.y / _camProxy.scale), _camProxy.rotation) :
				new Point(offset.x / _camProxy.scale, offset.y / _camProxy.scale);
			
			// move aabb
			_aabbData.rect.x -= rotScaledOffset.x;
			_aabbData.rect.y -= rotScaledOffset.y;
			
			if ( bounds && !bounds.containsRect(_aabbData.rect) )
			{
				
				var newAABBPos:Point = new Point(_aabbData.rect.x,_aabbData.rect.y);
				
				//x
				if (_aabbData.rect.left <= bounds.left || _aabbData.rect.width >= bounds.width)
					newAABBPos.x = bounds.left;
				else if (_aabbData.rect.right >= bounds.right)
					newAABBPos.x = bounds.right - _aabbData.rect.width;
				
				//y
				if (_aabbData.rect.top <= bounds.top || _aabbData.rect.height >= bounds.height)
					newAABBPos.y = bounds.top;
				else if (_aabbData.rect.bottom >= bounds.bottom)
					newAABBPos.y = bounds.bottom - _aabbData.rect.height;
				
				var newGTPos:Point = new Point(newAABBPos.x, newAABBPos.y);
				
				newGTPos.x -= _aabbData.offsetX;
				newGTPos.y -= _aabbData.offsetY;
				
				newGTPos.x += rotScaledOffset.x;
				newGTPos.y += rotScaledOffset.y;
				
				var invGT:Point;
				invGT = (_allowRotation) ? MathUtils.rotatePoint(new Point(newGTPos.x, newGTPos.y), -_camProxy.rotation) : new Point(newGTPos.x, newGTPos.y);
				_camProxy.x = -invGT.x * _camProxy.scale + _camProxy.offsetX;
				_camProxy.y = -invGT.y * _camProxy.scale + _camProxy.offsetY;
				
			}
			
			_viewRoot.scaleX = _viewRoot.scaleY = _camProxy.scale;
			_viewRoot.rotation = _camProxy.rotation * 180/Math.PI;
			
			_viewRoot.x = _camProxy.x;
			_viewRoot.y = _camProxy.y;
			
			
			_camPos = pointFromLocal(new Point(offset.x, offset.y));

		}
		
		public function pointFromLocal(p:Point):Point
		{
			
			return MathUtils.rotatePoint(
			new Point(
			(p.x - _camProxy.x) /_camProxy.scale, 
			(p.y - _camProxy.y) /_camProxy.scale)
			, _camProxy.rotation);
			
			//return (_viewRoot as Sprite).globalToLocal(p);
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
