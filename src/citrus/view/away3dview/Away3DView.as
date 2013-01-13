package citrus.view.away3dview {

	import away3d.containers.ObjectContainer3D;

	import citrus.physics.APhysicsEngine;
	import citrus.view.ACitrusView;
	import citrus.view.ISpriteView;

	import flash.display.MovieClip;
	
	/**
	 * Away3DView is based on Adobe Stage3D and the <a href="http://away3d.com/">Away3D</a> framework to render graphics. 
	 * You must use this view to create a 3D game. Note that you can create a 3D game with a 2D logic/physics.
	 * It is automatically set up when you extend Away3DState.
	 */
	public class Away3DView extends ACitrusView {

		private var _viewRoot:ObjectContainer3D;

		private var _mode:String;
		
		/**
		 * @param root The state class, most of the time <code>this</code> which is your game state.
		 * @param mode A string which determines if arts are used in 2D mode or 3D.
		 */
		public function Away3DView(root:ObjectContainer3D, mode:String = "3D") {

			super(root, ISpriteView);

			_mode = mode;
			
			_viewRoot = new ObjectContainer3D();
			root.addChild(_viewRoot);
			
			// TODO: change camera depending the mode.
			camera = new Away3DCamera2D(_viewRoot);
		}

		override public function destroy():void {

			_viewRoot.dispose();

			super.destroy();
		}

		public function get viewRoot():ObjectContainer3D {
			return _viewRoot;
		}

		public function get mode():String {
			return _mode;
		}

		override public function update():void {

			super.update();
			
			camera.update();

			// Update art positions
			for each (var sprite:Away3DArt in _viewObjects) {

				if (sprite.group != sprite.citrusObject.group)
					updateGroupForSprite(sprite);

				sprite.update(this);
			}
		}
		
		override protected function createArt(citrusObject:Object):Object {

			var viewObject:ISpriteView = citrusObject as ISpriteView;
			
			if (citrusObject is APhysicsEngine)
				citrusObject.view = Away3DPhysicsDebugView;

			if (citrusObject.view == MovieClip)
				citrusObject.view = ObjectContainer3D;

			var art:Away3DArt = new Away3DArt(viewObject);

			// Perform an initial update
			art.update(this);

			updateGroupForSprite(art);

			return art;
		}
		
		override protected function destroyArt(citrusObject:Object):void {

			var spriteArt:Away3DArt = _viewObjects[citrusObject];
			spriteArt.parent.removeChild(spriteArt);
		}

		private function updateGroupForSprite(sprite:Away3DArt):void {

			// Create the container sprite (group) if it has not been created yet.
			while (sprite.citrusObject.group >= _viewRoot.numChildren)
				_viewRoot.addChild(new ObjectContainer3D());

			// Add the sprite to the appropriate group
			ObjectContainer3D(_viewRoot.getChildAt(sprite.citrusObject.group)).addChild(sprite);
			
			// The sprite.group will be updated in the update method like all its other values. This function is called after the updateGroupForSprite method.
		}
	}
}