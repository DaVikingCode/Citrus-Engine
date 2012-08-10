package com.citrusengine.view.blittingview 
{
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.physics.Nape;
	import com.citrusengine.physics.SimpleCitrusSolver;
	import com.citrusengine.view.CitrusView;
	import com.citrusengine.view.ISpriteView;
	import com.citrusengine.view.SpriteDebugArt;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	public class BlittingView extends CitrusView
	{
		public var backgroundColor:Number = 0xffffffff;
		
		private var _debugView:Sprite;
		private var _canvasBitmap:Bitmap;
		private var _canvas:BitmapData;
		private var _spriteOrder:Array = [];
		private var _spritesAdded:uint = 0;
		private var _cameraPosition:MathVector = new MathVector();
		
		private var _debuggerPhysicsObject:Object;
		private var _usePhysicsEngine:Boolean = false;
		private var _useSimpleCitrusSolver:Boolean = false;
		private var _tabSpriteDebugArt:Array = [[], []];
		
		public function BlittingView(root:Sprite) 
		{
			super(root, ISpriteView);
			
			_canvas = new BitmapData(cameraLensWidth, cameraLensHeight, true, backgroundColor);
			_canvasBitmap = new Bitmap(_canvas);
			root.addChild(_canvasBitmap);
			
			_debugView = new Sprite();
			root.addChild(_debugView);
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
			
			if (_debuggerPhysicsObject)
				_debugView.visible = _debuggerPhysicsObject.visible;
			_debugView.x = -_cameraPosition.x;
			_debugView.y = -_cameraPosition.y;
			
			if (_useSimpleCitrusSolver) {
				var tabLength:uint = _tabSpriteDebugArt[0].length;
				for (var i:uint = 0; i < tabLength; ++i) { 
					_tabSpriteDebugArt[0][i].x = _tabSpriteDebugArt[1][i].x;
					_tabSpriteDebugArt[0][i].y = _tabSpriteDebugArt[1][i].y;
				}
			}
			
			_canvas.lock();
			_canvas.fillRect(new Rectangle(0, 0, cameraLensWidth, cameraLensHeight), backgroundColor);
			var n:Number = _spriteOrder.length;
			for (var j:uint = 0; j < n; ++j)
			{
				updateArt(_spriteOrder[j].citrusObject, _spriteOrder[j]);
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
			else if ((citrusObject is Box2D || citrusObject is Nape) && !_usePhysicsEngine && !_useSimpleCitrusSolver)
			{
				_debugView.addChild(new citrusObject.view());
				_usePhysicsEngine = true;
				_debuggerPhysicsObject = citrusObject;	
			}
			
			if (CitrusEngine.getInstance().state.getFirstObjectByType(SimpleCitrusSolver) && !_usePhysicsEngine && !_useSimpleCitrusSolver) {
				_useSimpleCitrusSolver = true;
			}
			
			if (!blittingArt)
			{
				blittingArt = new BlittingArt();
				
				if (_useSimpleCitrusSolver) {
					var spriteDebugArt:SpriteDebugArt = new citrusObject.view();
					if (spriteDebugArt.hasOwnProperty("initialize")) {
						spriteDebugArt["initialize"](citrusObject);
						_debugView.addChild(spriteDebugArt);
						_tabSpriteDebugArt[0].push(spriteDebugArt);
						_tabSpriteDebugArt[1].push(citrusObject);
					}
				}
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
			
			if (_useSimpleCitrusSolver) {
				
				var tabLength:uint = _tabSpriteDebugArt[0].length;
				for (var i:uint = 0; i < tabLength; ++i) {
					
					if (_tabSpriteDebugArt[1][i] == citrusObject)
						break;
				}
				
				_debugView.removeChild(_tabSpriteDebugArt[0][i]);
				_tabSpriteDebugArt[0].splice(i, 1);
				_tabSpriteDebugArt[1].splice(i, 1);
			}
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