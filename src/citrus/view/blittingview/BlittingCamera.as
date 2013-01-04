package citrus.view.blittingview {

	import citrus.math.MathVector;
	import citrus.view.ACitrusCamera;

	/**
	 * The Camera for the BlittingView.
	 */
	public class BlittingCamera extends ACitrusCamera {

		public function BlittingCamera(viewRoot:MathVector) {
			super(viewRoot);
		}

		override public function update():void {

			super.update();

			if (target) {

				var diffX:Number = (target.x - offset.x) - _viewRoot.x;
				var diffY:Number = (target.y - offset.y) - _viewRoot.y;
				var velocityX:Number = diffX * easing.x;
				var velocityY:Number = diffY * easing.y;

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
			}
		}
	}
}
