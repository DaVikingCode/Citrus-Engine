package citrus.view.blittingview
{
	
	import citrus.math.MathVector;
	import citrus.view.ACitrusCamera;
	import flash.geom.Point;
	
	/**
	 * The Camera for the BlittingView.
	 */
	public class BlittingCamera extends ACitrusCamera
	{
		
		public function BlittingCamera(viewRoot:Point)
		{
			super(viewRoot);
		}
		
		override public function update():void
		{
			
			super.update();
			
			offset.setTo(cameraLensWidth * center.x, cameraLensHeight * center.y);
			
			if (_target && followTarget)
			{
				if (_target.x <= camPos.x - (deadZone.width * .5) || _target.x >= camPos.x + (deadZone.width * .5))
					_targetPos.x = _target.x;
				
				if (_target.y <= camPos.y - (deadZone.height * .5) || _target.y >= camPos.y + (deadZone.height * .5))
					_targetPos.y = _target.y;
				
				_ghostTarget.x += (_targetPos.x - _ghostTarget.x) * easing.x;
				_ghostTarget.y += (_targetPos.y - _ghostTarget.y) * easing.y;
			}
			else if (_manualPosition)
			{
				_ghostTarget.x = _manualPosition.x;
				_ghostTarget.y = _manualPosition.y;
			}
			
			_camProxy.x = _ghostTarget.x;
			_camProxy.y = _ghostTarget.y;
			
			if (bounds)
			{
				
				if (camProxy.x - offset.x < bounds.left)
					_camProxy.x = bounds.left + offset.x;
				else if (_camProxy.x + (cameraLensWidth - offset.x) > bounds.right)
					_camProxy.x = bounds.right - (cameraLensWidth - offset.x);
				
				if (_camProxy.y - offset.y < bounds.top)
					_camProxy.y = bounds.top + offset.y;
				else if (_camProxy.y + (cameraLensHeight - offset.y) > bounds.bottom)
					_camProxy.y = bounds.bottom - (cameraLensHeight - offset.y);
			}
			
			_m.identity();
			_m.translate(-_camProxy.x,-_camProxy.y);
			_m.translate(offset.x, offset.y);
			_viewRoot.x = _camProxy.x - offset.x;
			_viewRoot.y = _camProxy.y - offset.y;
			
			pointFromLocal(offset.x, offset.y, _camPos);
		}
		
		public function pointFromLocal(x:Number,y:Number,resultPoint:Point = null):Point
		{
			_p.setTo(x, y);
			_p.x = _camProxy.x - offset.x;
			_p.y = _camProxy.y - offset.y;
			if (resultPoint)
				resultPoint.copyFrom(_p);
			return _p;
		}
	}
}
