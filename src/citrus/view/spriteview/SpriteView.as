package citrus.view.spriteview {

	import citrus.view.ACitrusView;
	import citrus.view.ISpriteView;

	import flash.display.Sprite;

	/**
	 * SpriteView is the first official implementation of a Citrus Engine "view". It creates and manages graphics using the traditional
	 * Flash display list (addChild(), removeChild()) using DisplayObjects (MovieClips, Bitmaps, etc).
	 * 
	 * <p>You might think, "Is there any other way to display graphics in Flash?", and the answer is yes. Many Flash game programmers
	 * prefer to use other rendering methods. The most common alternative is called "blitting", which is what Flixel uses. There are
	 * also Stage3D to render graphics 2D graphics via <a href="http://gamua.com/starling/">Starling</a> or 3D graphics thanks to <a href="http://away3d.com/">Away3D</a>.</p>
	 */	
	public class SpriteView extends ACitrusView
	{
		private var _viewRoot:Sprite;
		
		public function SpriteView(root:Sprite)
		{
			super(root, ISpriteView);
			
			_viewRoot = new Sprite();
			root.addChild(_viewRoot);
			
			camera = new SpriteCamera(_viewRoot);
		}
		
		public function get viewRoot():Sprite
		{
			return _viewRoot;
		}
			
		override public function update():void
		{
			super.update();
			
			camera.update();
			
			//Update art positions
			for each (var sprite:SpriteArt in _viewObjects)
			{
				if (sprite.group != sprite.citrusObject.group)
					updateGroupForSprite(sprite);
				
				sprite.update(this);
			}
		}
			
		override protected function createArt(citrusObject:Object):Object
		{
			var viewObject:ISpriteView = citrusObject as ISpriteView;
			
			var art:SpriteArt = new SpriteArt(viewObject);
			
			//Perform an initial update
			art.update(this);
			
			updateGroupForSprite(art);
			
			return art;
		}
				
		override protected function destroyArt(citrusObject:Object):void
		{
			var spriteArt:SpriteArt = _viewObjects[citrusObject];
			spriteArt.destroy();
			spriteArt.parent.removeChild(spriteArt);
		}
		
		private function updateGroupForSprite(sprite:SpriteArt):void
		{
			//Create the container sprite (group) if it has not been created yet.
			while (sprite.citrusObject.group >= _viewRoot.numChildren)
				_viewRoot.addChild(new Sprite());
			
			//Add the sprite to the appropriate group
			Sprite(_viewRoot.getChildAt(sprite.citrusObject.group)).addChild(sprite);
			
			// The sprite.group will be updated in the update method like all its other values. This function is called after the updateGroupForSprite method.
		}
	}
}