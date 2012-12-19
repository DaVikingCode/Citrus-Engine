package citrus.view.away3dview {

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;

	import citrus.core.CitrusEngine;
	import citrus.physics.APhysicsEngine;
	import citrus.view.CitrusView;
	import citrus.view.ISpriteView;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Away3DView is based on Adobe Stage3D and the <a href="http://away3d.com/">Away3D</a> framework to render graphics. 
	 * You must use this view to create a 3D game. Note that you can create a 3D game with a 2D logic/physics. 
	 * To specify Away3DView, override the <code>state.createView</code> method and <code>return 
	 * new Away3DView(this)</code>. Check the demo for an example.
	 */
	public class Away3DView extends CitrusView {

		private var _ce:CitrusEngine;

		private var _mode:String;

		private var _viewRoot:View3D;
		private var _scene:Scene3D;

		private var _container:ObjectContainer3D;

		/**
		 * @param root the state class, most of the time <code>this</code>.
		 * @param mode defines 2D or 3D physics / logic usage, default is 3D.
		 * @param antiAlias defines the Away3D's antiAlias value, default is 4.
		 */
		public function Away3DView(root:Sprite, mode:String = "3D", antiAlias:uint = 4, stage3DProxy:Stage3DProxy = null) {

			super(root, ISpriteView);

			_ce = CitrusEngine.getInstance();

			_mode = mode;

			_scene = new Scene3D();
			_container = new ObjectContainer3D();
			_scene.addChild(_container);

			_viewRoot = new View3D(_scene);
			
			if (stage3DProxy) {
				_viewRoot.stage3DProxy = stage3DProxy;
				_viewRoot.shareContext = true;
			}
			
			_viewRoot.antiAlias = antiAlias;
			root.addChild(_viewRoot);

			_ce.stage.addEventListener(Event.RESIZE, _onResize);
		}

		override public function destroy():void {

			_ce.stage.removeEventListener(Event.RESIZE, _onResize);

			super.destroy();
		}

		public function get viewRoot():View3D {
			return _viewRoot;
		}

		public function get mode():String {
			return _mode;
		}
		
		/**
		 *With Away3D we don't use the viewRoot as the main container for our objects because we shouldn't move the View3D. 
		 *So we use an ObjectContainer3D to add all our objects in.
		 */
		public function get container():ObjectContainer3D {
			return _container;
		}

		override public function update():void {

			super.update();

			_viewRoot.render();

			// Update Camera
			if (cameraTarget) {
				var diffX:Number = (-cameraTarget.x + cameraOffset.x) - _container.position.x;
				var diffY:Number = (-cameraTarget.y + cameraOffset.y) - _container.position.y;
				var velocityX:Number = diffX * cameraEasing.x;
				var velocityY:Number = diffY * cameraEasing.y;

				_container.x += velocityX;
				_container.y -= velocityY;

				// Constrain to camera bounds
				if (cameraBounds) {

					if (-_container.x <= cameraBounds.left || cameraBounds.width < cameraLensWidth)
						_container.x = -cameraBounds.left;
					else if (-_container.x + cameraLensWidth >= cameraBounds.right)
						_container.x = -cameraBounds.right + cameraLensWidth;

					if (-_container.y <= cameraBounds.top || cameraBounds.height < cameraLensHeight)
						_container.y = -cameraBounds.top;
					else if (-_container.y + cameraLensHeight >= cameraBounds.bottom)
						_container.y = -cameraBounds.bottom + cameraLensHeight;
				}
			}

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
			while (sprite.group >= _container.numChildren)
				_container.addChild(new ObjectContainer3D());

			// Add the sprite to the appropriate group
			ObjectContainer3D(_container.getChildAt(sprite.group)).addChild(sprite);
		}

		private function _onResize(evt:Event):void {

			_viewRoot.width = _ce.stage.stageWidth;
			_viewRoot.height = _ce.stage.stageHeight;
		}
	}
}