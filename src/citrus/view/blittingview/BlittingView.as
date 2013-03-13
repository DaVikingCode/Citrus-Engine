package citrus.view.blittingview 
{

	import citrus.core.CitrusEngine;
	import citrus.math.MathVector;
	import citrus.physics.APhysicsEngine;
	import citrus.physics.IDebugView;
	import citrus.physics.simple.SimpleCitrusSolver;
	import citrus.view.ACitrusView;
	import citrus.view.ISpriteView;
	import citrus.view.spriteview.SpriteDebugArt;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;

	/**
	 * Blitting is a higher-performance alternative to using the built-in display list in Adobe Flash for drawing objects on the Stage. 
	 * This technique involves copying the individual pixels of an existing image directly on to the screen—a bit like 
	 * painting all of your game's spaceships and monsters onto a canvas.
	 * 
	 * <p>Working manually with pixels is more complicated than using the display list, but the improvement in performance more than 
	 * makes up for the extra effort. For situations where there are many objects moving around the Stage, you must usually choose 
	 * either a smooth frame rate or a small memory footprint. With blitting you can have both.</p>
	 * 
	 * <p>The Citrus Engine supports blitting, to enable it you have to override the <code>state.createView</code> method and <code>return 
	 * new BlittingView(this)</code>. Also don't forget to call <code>BlittingView(view).updateCanvas();</code> to set up the blitting canvas. 
	 * Check the demo for an example.</p>
	 */	
	public class BlittingView extends ACitrusView
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
			
			var ce:CitrusEngine = CitrusEngine.getInstance();
			
			_canvas = new BitmapData(ce.stage.stageWidth, ce.stage.stageHeight, true, backgroundColor);
			_canvasBitmap = new Bitmap(_canvas);
			root.addChild(_canvasBitmap);
			
			_debugView = new Sprite();
			root.addChild(_debugView);
			
			camera = new BlittingCamera(_cameraPosition);
		}
		
		public function get cameraPosition():MathVector
		{
			return _cameraPosition;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			camera.update();			
			
			if (_debuggerPhysicsObject) {
				_debugView.visible = _debuggerPhysicsObject.visible;
				(_debugView.getChildAt(0) as IDebugView).update();
			}
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
			_canvas.fillRect(new Rectangle(0, 0, camera.cameraLensWidth, camera.cameraLensHeight), backgroundColor);
			var n:Number = _spriteOrder.length;
			for (var j:uint = 0; j < n; ++j)
			{
				updateArt(_spriteOrder[j].citrusObject, _spriteOrder[j]);
			}
			_canvas.unlock();
		}
		
		public function updateCanvas():void
		{
			_canvas = new BitmapData(camera.cameraLensWidth, camera.cameraLensHeight, true, backgroundColor);
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
			else if (citrusObject is APhysicsEngine && !_usePhysicsEngine && !_useSimpleCitrusSolver)
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