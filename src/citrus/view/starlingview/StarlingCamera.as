package citrus.view.starlingview {

	import citrus.math.MathUtils;
	import citrus.view.ACitrusCamera;

	import starling.display.Sprite;

	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	
	/**
	 * The Camera for the StarlingView.
	 */
	public class StarlingCamera extends ACitrusCamera
	{
		
		public function StarlingCamera(viewRoot:starling.display.Sprite)
		{
			super(viewRoot);
		}
		
		override protected function initialize():void {
			super.initialize();// setup camera lens normally

			_aabbData = MathUtils.createAABBData(0, 0, cameraLensWidth / _camProxy.scale, cameraLensHeight / _camProxy.scale, _camProxy.rotation);
			_m = (_viewRoot as starling.display.Sprite).transformationMatrix;
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
				throw(new Error(this+" is not allowed to zoom. please set allowZoom to true."));
		}
		
		override public function zoomFit(width:Number,height:Number):Number
		{
			if (_allowZoom)
			{
				var ratio:Number;
				if (cameraLensHeight / cameraLensWidth > height / width)
					ratio = cameraLensWidth / width;
				else
					ratio = cameraLensHeight / height;
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
				throw(new Error(this+" is not allowed to rotate. please set allowRotation to true."));
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
				throw(new Error(this+" is not allowed to rotate. please set allowRotation to true."));
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
				throw(new Error(this+" is not allowed to zoom. please set allowZoom to true."));
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
		
		override public function update():void
		{
			super.update();
			
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
			
			if (_allowRotation)
			{
				var diffRot:Number = _rotation - _camProxy.rotation;
				var velocityRot:Number = diffRot * rotationEasing;
				_camProxy.rotation += velocityRot;
			}
			
			resetAABBData();
			
			if (_allowZoom)
			{

				var diffZoom:Number = mzoom - _camProxy.scale;
				var velocityZoom:Number = diffZoom * zoomEasing;
				_camProxy.scale += velocityZoom;
				
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
			
			if ( bounds )
			{
				if (boundsMode == BOUNDS_MODE_AABB)
				{

					MathUtils.rotatePoint(offset.x/_camProxy.scale, offset.y/_camProxy.scale, _camProxy.rotation, _b.rotoffset);
					
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
					/**
					 * Find the furthest camera corner from the offset point, and use the distance from offset to that corner
					 * as the radius of the circle that will be restricted within the bounds.
					 */
					
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
			
			(_viewRoot as starling.display.Sprite).transformationMatrix = _m;
		}
		
		/**
		 * @param	sprite a flash display sprite to render to.
		 * @deprecated this is now obsolete and doesn't reflect exactly how the camera works as the system changed.
		 */
		public function renderDebug(sprite:flash.display.Sprite):void
		{
			
			var xo:Number, yo:Number, w:Number, h:Number;
			
			//create AABB of camera
			var AABB:Object = MathUtils.createAABBData(
			
			_ghostTarget.x ,
			_ghostTarget.y ,
			
			cameraLensWidth / _camProxy.scale,
			cameraLensHeight / _camProxy.scale,
			- _camProxy.rotation);
			
			sprite.graphics.clear();
			
			if (bounds)
			{
			//draw bounds
			sprite.graphics.lineStyle(1, 0xFF0000);
			sprite.graphics.drawRect(
			bounds.left,
			bounds.top,
			bounds.width,
			bounds.height);
			}
			
			//draw targets
			sprite.graphics.lineStyle(20, 0xFF0000);
			if (_target)
				sprite.graphics.drawCircle(_target.x, _target.y, 10);
			sprite.graphics.drawCircle(_ghostTarget.x, _ghostTarget.y, 10);
			
			//rotate and scale offset.
			var rotScaledOffset:Point = MathUtils.rotatePoint(
			offset.x / _camProxy.scale, offset.y / _camProxy.scale,
			_camProxy.rotation);
			
			//offset aabb rect according to rotated and scaled camera offset
			AABB.rect.x -= rotScaledOffset.x;
			AABB.rect.y -= rotScaledOffset.y;
			
			//draw aabb
			sprite.graphics.lineStyle(1, 0xFFFF00);
			sprite.graphics.drawRect(AABB.rect.x, AABB.rect.y, AABB.rect.width, AABB.rect.height);
			
			var c:Number = Math.cos(_camProxy.rotation);
			var s:Number = Math.sin(_camProxy.rotation);
			
			//draw rotated camera rect
			
			xo =  AABB.rect.x - AABB.offsetX;
			yo =  AABB.rect.y - AABB.offsetY;
			 
			w = cameraLensWidth / _camProxy.scale;
			h = cameraLensHeight / _camProxy.scale;
			
			sprite.graphics.lineStyle(1, 0x00F0FF);
			sprite.graphics.beginFill(0x000000, 0.2);
			sprite.graphics.moveTo(xo,
			yo);
			sprite.graphics.lineTo(
			xo + (w) * c + (0) * s ,
			yo + -(w) * s + (0) * c );
			sprite.graphics.lineTo(
			xo + (w) * c + (h) * s ,
			yo + -(w) * s + (h) * c );
			sprite.graphics.lineTo(
			xo + (0) * c + (h) * s ,
			yo + -(0) * s + (h) * c );
			sprite.graphics.lineTo(xo ,
			yo);
			sprite.graphics.endFill();
			
			if (bounds && !bounds.containsRect(AABB.rect))
			{
				//aabb is out of bounds, draw where it should be if constrained
				
				var newAABBPos:Point = new Point(AABB.rect.x,AABB.rect.y);
				
				//x
				if (AABB.rect.left <= bounds.left)
					newAABBPos.x = bounds.left;
				else if (AABB.rect.right >= bounds.right)
					newAABBPos.x = bounds.right - AABB.rect.width;
				
				//y
				if (AABB.rect.top <= bounds.top)
					newAABBPos.y = bounds.top;
				else if (AABB.rect.bottom >= bounds.bottom)
					newAABBPos.y = bounds.bottom - AABB.rect.height;
				
				sprite.graphics.lineStyle(1, 0xFFFFFF , 0.5);
				sprite.graphics.drawRect(newAABBPos.x, newAABBPos.y, AABB.rect.width, AABB.rect.height);
				
				//then using the new aabb position... draw the camera.
				
				xo =  newAABBPos.x - AABB.offsetX;
				yo =  newAABBPos.y - AABB.offsetY;
				 
				w = cameraLensWidth / _camProxy.scale;
				h = cameraLensHeight / _camProxy.scale;
				
				sprite.graphics.lineStyle(1, 0xFFFFFF, 0.5);
				sprite.graphics.beginFill(0xFFFFFF, 0.1);
				sprite.graphics.moveTo(xo,
				yo);
				sprite.graphics.lineTo(
				xo + (w) * c + (0) * s ,
				yo + -(w) * s + (0) * c );
				sprite.graphics.lineTo(
				xo + (w) * c + (h) * s ,
				yo + -(w) * s + (h) * c );
				sprite.graphics.lineTo(
				xo + (0) * c + (h) * s ,
				yo + -(0) * s + (h) * c );
				sprite.graphics.lineTo(xo ,
				yo);
				sprite.graphics.endFill();
				
				//and so the new position of the camera :
				
				var newGTPos:Point = new Point(newAABBPos.x, newAABBPos.y);
				
				sprite.graphics.lineStyle(20, 0xFFFFFF);
				sprite.graphics.drawCircle(newGTPos.x, newGTPos.y, 10);
				
				newGTPos.x -= AABB.offsetX;
				newGTPos.y -= AABB.offsetY;
				
				sprite.graphics.drawCircle(newGTPos.x, newGTPos.y, 10);
				
				//and we already have the rotated and scaled offset so lets add it.
				
				newGTPos.x += rotScaledOffset.x;
				newGTPos.y += rotScaledOffset.y;
				
				sprite.graphics.drawCircle(newGTPos.x, newGTPos.y, 10);
			
			}
			
		}
		
		/**
		 *  equivalent of  globalToLocal.
		 */
		public function pointFromLocal(x:Number,y:Number,resultPoint:Point = null):Point
		{
			_p.setTo(x, y);
			return (_viewRoot as starling.display.Sprite).globalToLocal(_p,resultPoint);
		}
		
		/**
		 *  equivalent of localToGlobal
		 */
		public function pointToLocal(p:Point):Point
		{
			return (_viewRoot as starling.display.Sprite).localToGlobal(p);
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
		
	}
}
