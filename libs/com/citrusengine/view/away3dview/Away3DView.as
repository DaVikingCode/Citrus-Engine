package com.citrusengine.view.away3dview {

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.view.CitrusView;
	import com.citrusengine.view.ISpriteView;
	import com.citrusengine.view.spriteview.Box2DDebugArt;
	import com.citrusengine.view.spriteview.NapeDebugArt;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Away3DView is based on  Adobe Stage3D and the Away3D framework to render graphics. 
	 */
	public class Away3DView extends CitrusView {

		private var _ce:CitrusEngine;

		private var _mode:String;

		private var _viewRoot:View3D;
		private var _scene:Scene3D;

		private var _container:ObjectContainer3D;

		/**
		 * The mode defines 2D or 3D physics / logics usage.
		 */
		public function Away3DView(root:Sprite, mode:String) {

			super(root, ISpriteView);

			_ce = CitrusEngine.getInstance();

			_mode = mode;

			_scene = new Scene3D();
			_container = new ObjectContainer3D();
			_scene.addChild(_container);

			_viewRoot = new View3D(_scene);
			_viewRoot.antiAlias = 4;
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

		public function get container():ObjectContainer3D {
			return _container;
		}

		/**
		 * @inherit 
		 */
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

		/**
		 * @inherit 
		 */
		override protected function createArt(citrusObject:Object):Object {

			var viewObject:ISpriteView = citrusObject as ISpriteView;

			// Changing to appropriate Box2DDebugArt
			if (citrusObject.view == com.citrusengine.view.spriteview.Box2DDebugArt)
				citrusObject.view = com.citrusengine.view.away3dview.Box2DDebugArt;

			// Changing to appropriate NapeDebugArt
			if (citrusObject.view == com.citrusengine.view.spriteview.NapeDebugArt)
				citrusObject.view = com.citrusengine.view.away3dview.NapeDebugArt;

			if (citrusObject.view == MovieClip)
				citrusObject.view = ObjectContainer3D;

			var art:Away3DArt = new Away3DArt(viewObject);

			// Perform an initial update
			art.update(this);

			updateGroupForSprite(art);

			return art;
		}

		/**
		 * @inherit 
		 */
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