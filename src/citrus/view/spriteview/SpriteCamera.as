package citrus.view.spriteview {

	import citrus.view.ACitrusCamera;

	import flash.display.Sprite;

	/**
	 * The Camera for the SpriteView.
	 */
	public class SpriteCamera extends ACitrusCamera {

		public function SpriteCamera(viewRoot:Sprite) {
			super(viewRoot);
		}

		override public function update():void {

			super.update();

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
