package citrus.view.away3dview {

	import away3d.containers.ObjectContainer3D;

	import citrus.view.ACitrusCamera;

	/**
	 * The Camera for the Away3DView in 2D mode.
	 */
	public class Away3DCamera2D extends ACitrusCamera {

		public function Away3DCamera2D(viewRoot:ObjectContainer3D) {
			super(viewRoot);
		}

		override public function update():void {

			super.update();
			
			offset.setTo(cameraLensWidth * center.x, cameraLensHeight * center.y);

			if (target) {

				var diffX:Number = (-_target.x + offset.x) - _viewRoot.x;
				var diffY:Number = (-_target.y + offset.y) - _viewRoot.y;
				var velocityX:Number = diffX * easing.x;
				var velocityY:Number = diffY * easing.y;

				_viewRoot.x += velocityX;
				_viewRoot.y += velocityY;

				// Constrain to camera bounds
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
