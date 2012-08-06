package com.citrusengine.view.blittingview 
{
	import com.citrusengine.math.MathVector;
	import com.citrusengine.view.CitrusView;
	import com.citrusengine.view.ISpriteView;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	public class BlittingView extends CitrusView
	{
		public var backgroundColor:Number = 0xffffffff;
		
		private var _canvasBitmap:Bitmap;
		private var _canvas:BitmapData;
		private var _spriteOrder:Array = [];
		private var _spritesAdded:uint = 0;
		private var _cameraPosition:MathVector = new MathVector();
		
		public function BlittingView(root:Sprite) 
		{
			super(root, ISpriteView);
			
			_canvas = new BitmapData(cameraLensWidth, cameraLensHeight, true, backgroundColor);
			_canvasBitmap = new Bitmap(_canvas);
			root.addChild(_canvasBitmap);
		}
		
		public function get cameraPosition():MathVector
		{
			return _cameraPosition;
		}
		
		override public function update():void
		{
			super.update();
			
			//Update Camera
			if (cameraTarget)
			{
				//Update camera position
				var diffX:Number = (cameraTarget.x - cameraOffset.x) - _cameraPosition.x;
				var diffY:Number = (cameraTarget.y - cameraOffset.x) - _cameraPosition.y;
				var velocityX:Number = diffX * cameraEasing.x;
				var velocityY:Number = diffY * cameraEasing.y;
				_cameraPosition.x += velocityX;
				_cameraPosition.y += velocityY;
				
				//Constrain to camera bounds
				if (cameraBounds)
				{
					if (_cameraPosition.x <= cameraBounds.left || cameraBounds.width < cameraLensWidth)
						_cameraPosition.x = cameraBounds.left;
					else if (_cameraPosition.x + cameraLensWidth >= cameraBounds.right)
						_cameraPosition.x = cameraBounds.right - cameraLensWidth;
					
					if (_cameraPosition.y <= cameraBounds.top || cameraBounds.height < cameraLensHeight)
						_cameraPosition.y = cameraBounds.top;
					else if (_cameraPosition.y + cameraLensHeight >= cameraBounds.bottom)
						_cameraPosition.y = cameraBounds.bottom - cameraLensHeight;
				}
			}
			_canvas.lock();
			_canvas.fillRect(new Rectangle(0, 0, cameraLensWidth, cameraLensHeight), backgroundColor);
			var n:Number = _spriteOrder.length;
			for (var i:int = 0; i < n; i++)
			{
				updateArt(_spriteOrder[i].citrusObject, _spriteOrder[i]);
			}
			_canvas.unlock();
		}
		
		public function updateCanvas():void
		{
			_canvas = new BitmapData(cameraLensWidth, cameraLensHeight, true, backgroundColor);
			_canvasBitmap.bitmapData = _canvas;
		}
		
		override protected function createArt(citrusObject:Object):Object
		{
			var viewObject:ISpriteView = citrusObject as ISpriteView;
			
			var blittingArt:BlittingArt;
			if (viewObject.view is BlittingArt)
			{
				blittingArt = viewObject.view as BlittingArt;
			}
			else if (viewObject.view is String)
			{
				var artClass:Class = getDefinitionByName(viewObject.view as String) as Class;
				blittingArt = new artClass() as BlittingArt;
			}
			
			if (!blittingArt)
			{
				trace("Warning: the 'view' property of " + viewObject + " must be a BlittingArt object since you are using the BlittingView");
				blittingArt = new BlittingArt();
			}
			blittingArt.addIndex = _spritesAdded++;
			blittingArt.group = viewObject.group;
			blittingArt.initialize(citrusObject);
			blittingArt.registration = viewObject.registration;
			blittingArt.offset = new MathVector(viewObject.offsetX, viewObject.offsetY);
			
			_spriteOrder.push(blittingArt);
			updateGroupSorting();
			
			return blittingArt;
		}
		
		override protected function destroyArt(citrusObject:Object):void
		{
			var art:BlittingArt = _viewObjects[citrusObject];
			_spriteOrder.splice(_spriteOrder.indexOf(art), 1);
		}
		
		override protected function updateArt(citrusObject:Object, art:Object):void
		{
			var bart:BlittingArt = art as BlittingArt;
			var object:ISpriteView = citrusObject as ISpriteView;
			
			//shortcut
			var ca:AnimationSequence = bart.currAnimation;
			
			if (!ca || !object.visible)
				return;
			
			bart.play(object.animation);
			
			var position:Point = new Point();
			position.x = (object.x - _cameraPosition.x) * object.parallax;
			position.y = (object.y - _cameraPosition.y) * object.parallax;
			
			//handle registration
			if (bart.registration == "center")
			{
				position.x -= ca.frameWidth * 0.5;
				position.y -= ca.frameHeight * 0.5;
			}
			
			//handle a group change
			if (bart.group != object.group)
			{
				bart.group = object.group;
				updateGroupSorting();
			}
			
			//cut out the sprite sheet frame rectangle
			var rect:Rectangle = new Rectangle();
			if (object.inverted && ca.invertedBitmapData)
				rect.x = ca.bitmapData.width - ca.frameWidth - ((ca.currFrame % ca.numColumns) * ca.frameWidth) - bart.offset.x;
			else
				rect.x = (ca.currFrame % ca.numColumns) * ca.frameWidth + bart.offset.x;
			
			rect.y = int(ca.currFrame / ca.numColumns) * ca.frameHeight + bart.offset.y;
			rect.width = ca.frameWidth;
			rect.height = ca.frameHeight;
			
			//draw
			_canvas.copyPixels((object.inverted && ca.invertedBitmapData) ? ca.invertedBitmapData : ca.bitmapData, rect, position, null, null, true);
			
			//increment the frame
			ca.currFrame++;
			if (ca.currFrame >= ca.numFrames)
			{
				if (ca.loop)
					ca.currFrame = 0;
				else
					ca.currFrame = ca.numFrames - 1;
			}
		}
		
		private function updateGroupSorting():void
		{
			_spriteOrder.sortOn(["group", "addIndex"], Array.NUMERIC);
		}
	}
}