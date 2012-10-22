package com.citrusengine.view.starlingview {
	
	import starling.display.Sprite;

	import com.citrusengine.physics.APhysicsEngine;
	import com.citrusengine.view.CitrusView;
	import com.citrusengine.view.ISpriteView;

	import flash.display.MovieClip;

	/**
	 * StarlingView is based on  Adobe Stage3D and the Starling framework to render graphics. 
	 * It creates and manages graphics like the traditional Flash display list thanks to Starling :
	 * (addChild(), removeChild()) using Starling DisplayObjects (MovieClip, Image, Sprite, Quad etc).
	 */	
	public class StarlingView extends CitrusView {

		private var _viewRoot:Sprite;

		public function StarlingView(root:Sprite) {

			super(root, ISpriteView);

			_viewRoot = new Sprite();
			root.addChild(_viewRoot);
		}

		public function get viewRoot():Sprite {
			return _viewRoot;
		}
			
		override public function destroy():void {
			
			_viewRoot.dispose();
			
			super.destroy();
		}

		override public function update():void {
			
			super.update();

			// Update Camera
			if (cameraTarget) {
				var diffX:Number = (-cameraTarget.x + cameraOffset.x) - _viewRoot.x;
				var diffY:Number = (-cameraTarget.y + cameraOffset.y) - _viewRoot.y;
				var velocityX:Number = diffX * cameraEasing.x;
				var velocityY:Number = diffY * cameraEasing.y;
				_viewRoot.x += velocityX;
				_viewRoot.y += velocityY;

				// Constrain to camera bounds
				if (cameraBounds) {
					if (-_viewRoot.x <= cameraBounds.left || cameraBounds.width < cameraLensWidth)
						_viewRoot.x = -cameraBounds.left;
					else if (-_viewRoot.x + cameraLensWidth >= cameraBounds.right)
						_viewRoot.x = -cameraBounds.right + cameraLensWidth;

					if (-_viewRoot.y <= cameraBounds.top || cameraBounds.height < cameraLensHeight)
						_viewRoot.y = -cameraBounds.top;
					else if (-_viewRoot.y + cameraLensHeight >= cameraBounds.bottom)
						_viewRoot.y = -cameraBounds.bottom + cameraLensHeight;
				}
			}

			// Update art positions
			for each (var sprite:StarlingArt in _viewObjects) {
				if (sprite.group != sprite.citrusObject.group)
					updateGroupForSprite(sprite);

				sprite.update(this);
			}
		}

		override protected function createArt(citrusObject:Object):Object {
			
			var viewObject:ISpriteView = citrusObject as ISpriteView;
			
			if (citrusObject is APhysicsEngine)
				citrusObject.view = StarlingPhysicsDebugView;
				
			if (citrusObject.view == flash.display.MovieClip)
				citrusObject.view = starling.display.Sprite;
				
			var art:StarlingArt = new StarlingArt(viewObject);
			
			// Perform an initial update
			art.update(this);

			updateGroupForSprite(art);
			
			return art;
		}

		/**
		 * @inherit 
		 */
		override protected function destroyArt(citrusObject:Object):void {
			
			var spriteArt:StarlingArt = _viewObjects[citrusObject];
			spriteArt.destroy();
			spriteArt.parent.removeChild(spriteArt);
		}

		private function updateGroupForSprite(sprite:StarlingArt):void {
			// Create the container sprite (group) if it has not been created yet.
			while (sprite.group >= _viewRoot.numChildren)
				_viewRoot.addChild(new Sprite());

			// Add the sprite to the appropriate group
			Sprite(_viewRoot.getChildAt(sprite.group)).addChild(sprite);
		}
	}
}
