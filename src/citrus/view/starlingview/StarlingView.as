package citrus.view.starlingview {

	import citrus.physics.APhysicsEngine;
	import citrus.view.ACitrusView;
	import citrus.view.ISpriteView;
	import citrus.view.spriteview.SpriteDebugArt;

	import starling.display.Sprite;

	import flash.display.MovieClip;

	/**
	 * StarlingView is based on Adobe Stage3D and the <a href="http://gamua.com/starling/">Starling</a> framework to render graphics. 
	 * It creates and manages graphics like the traditional Flash display list (but on the GPU!!) thanks to Starling :
	 * (addChild(), removeChild()) using Starling DisplayObjects (MovieClip, Image, Sprite, Quad etc).
	 */	
	public class StarlingView extends ACitrusView {

		private var _viewRoot:Sprite;

		public function StarlingView(root:Sprite) {

			super(root, ISpriteView);

			_viewRoot = new Sprite();
			root.addChild(_viewRoot);
			
			camera = new StarlingCamera(_viewRoot);
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
			
			camera.update();

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
				
			if (citrusObject.view == SpriteDebugArt)
				citrusObject.view = StarlingSpriteDebugArt;
				
			if (citrusObject.view == flash.display.MovieClip)
				citrusObject.view = starling.display.Sprite;
				
			var art:StarlingArt = new StarlingArt(viewObject);
			
			// Perform an initial update
			art.update(this);

			updateGroupForSprite(art);
			
			return art;
		}
		
		override protected function destroyArt(citrusObject:Object):void {
			
			var starlingArt:StarlingArt = _viewObjects[citrusObject];
			starlingArt.destroy();
			starlingArt.parent.removeChild(starlingArt);
		}

		private function updateGroupForSprite(sprite:StarlingArt):void {
			
			if (sprite.citrusObject.group > _viewRoot.numChildren + 100)
				trace("the group property value of " + sprite.citrusObject + ":" + sprite.citrusObject.group + " is higher than +100 to the current max group value (" + _viewRoot.numChildren + ") and may perform a crash");
			
			// Create the container sprite (group) if it has not been created yet.
			while (sprite.citrusObject.group >= _viewRoot.numChildren)
				_viewRoot.addChild(new Sprite());
			
			// Add the sprite to the appropriate group
			Sprite(_viewRoot.getChildAt(sprite.citrusObject.group)).addChild(sprite);
			
			// The sprite.group will be updated in the update method like all its other values. This function is called after the updateGroupForSprite method.
		}
	}
}
