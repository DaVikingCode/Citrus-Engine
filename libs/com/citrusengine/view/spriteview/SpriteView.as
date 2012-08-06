package com.citrusengine.view.spriteview
{
	import com.citrusengine.view.CitrusView;
	import com.citrusengine.view.ISpriteView;
	import flash.display.Sprite;
	
	/**
	 * SpriteView is the first official implementation of a Citrus Engine "view". It creates and manages graphics using the traditional
	 * Flash display list (addChild(), removeChild()) using DisplayObjects (MovieClips, Bitmaps, etc).
	 * 
	 * <p>You might think, "Is there any other way to display graphics in Flash?", and the answer is yes. Many Flash game programmers
	 * prefer to use other rendering methods. The most common alternative is called "blitting", which is what Flixel uses. There are
	 * also 3D games on the way that will use Adobe Stage3D to render graphics.</p>
	 */	
	public class SpriteView extends CitrusView
	{
		private var _viewRoot:Sprite;
		
		public function SpriteView(root:Sprite)
		{
			super(root, ISpriteView);
			
			_viewRoot = new Sprite();
			root.addChild(_viewRoot);
		}
		
		public function get viewRoot():Sprite
		{
			return _viewRoot;
		}
		
		/**
		 * @inherit 
		 */		
		override public function update():void
		{
			super.update();
			
			//Update Camera
			if (cameraTarget)
			{
				var diffX:Number = (-cameraTarget.x + cameraOffset.x) - _viewRoot.x;
				var diffY:Number = (-cameraTarget.y + cameraOffset.y) - _viewRoot.y;
				var velocityX:Number = diffX * cameraEasing.x;
				var velocityY:Number = diffY * cameraEasing.y;
				_viewRoot.x += velocityX;
				_viewRoot.y += velocityY;
				
				//Constrain to camera bounds
				if (cameraBounds)
				{
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
			
			//Update art positions
			for each (var sprite:SpriteArt in _viewObjects)
			{
				if (sprite.group != sprite.citrusObject.group)
					updateGroupForSprite(sprite);
				
				sprite.update(this);
			}
		}
		
		/**
		 * @inherit 
		 */		
		override protected function createArt(citrusObject:Object):Object
		{
			var viewObject:ISpriteView = citrusObject as ISpriteView;
			
			var art:SpriteArt = new SpriteArt(viewObject);
			
			//Perform an initial update
			art.update(this);
			
			updateGroupForSprite(art);
			
			return art;
		}
		
		/**
		 * @inherit 
		 */		
		override protected function destroyArt(citrusObject:Object):void
		{
			var spriteArt:SpriteArt = _viewObjects[citrusObject];
			spriteArt.parent.removeChild(spriteArt);
		}
		
		private function updateGroupForSprite(sprite:SpriteArt):void
		{
			//Create the container sprite (group) if it has not been created yet.
			while (sprite.group >= _viewRoot.numChildren)
				_viewRoot.addChild(new Sprite());
			
			//Add the sprite to the appropriate group
			Sprite(_viewRoot.getChildAt(sprite.group)).addChild(sprite);
		}
	}
}