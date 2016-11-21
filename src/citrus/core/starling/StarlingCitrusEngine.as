package citrus.core.starling {
	import citrus.core.CitrusEngine;
	import citrus.core.IScene;
	import citrus.core.citrus_internal;

	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;

	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Rectangle;

	/**
	 * Extends this class if you create a Starling based game. Don't forget to call <code>setUpStarling</code> function.
	 * 
	 * <p>CitrusEngine can access to the Stage3D power thanks to the <a href="http://starling-framework.org/">Starling Framework</a>.</p>
	 */
	public class StarlingCitrusEngine extends CitrusEngine {
		
		use namespace citrus_internal;
		
		public var textureScaleFactor:Number = 1;

		protected var _debug:Boolean = false;
		
		protected var _starling:Starling;
		protected var _juggler:CitrusStarlingJuggler;
		
		protected var _assetSizes:Array = [1];
		protected var _baseWidth:int = -1;
		protected var _baseHeight:int = -1;
		protected var _viewportMode:String = ViewportMode.LEGACY;
		protected var _viewport:Rectangle = new Rectangle();
		protected var _suspendRenderingOnDeactivate:Boolean = false;
		
		private var _baseRectangle:Rectangle = new Rectangle();
		private var _screenRectangle:Rectangle = new Rectangle();
		
		private var _viewportBaseRatioWidth:Number = 1;
		private var _viewportBaseRatioHeight:Number = 1;
		
		private var _starlingRoot:DisplayObjectContainer;
		
		/**
		 * context3D profiles to test for in Ascending order (the more important first).
		 * reset this array to a single entry to force one specific profile. <a href="http://wiki.starling-framework.org/manual/constrained_stage3d_profile">More informations</a>.
		 */
		protected var _context3DProfiles:Array = ["standardExtended", "standard", "standardConstrained", "baselineExtended", "baseline", "baselineConstrained"];
		
		public function StarlingCitrusEngine() {
			super();
			
			_juggler = new CitrusStarlingJuggler();
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {

			super.destroy();
			
			_juggler.purge();

			if (_scene) {

				if (_starling) {
					_starling.stage.removeEventListener(starling.events.Event.RESIZE, handleStarlingStageResize);
					_starling.stage.removeChild(_scene as StarlingScene);
					_starling.root.dispose();
					_starling.dispose();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function handlePlayingChange(value:Boolean):void
		{
			super.handlePlayingChange(value);
			
			_juggler.paused = !value;
		}

		/**
		 * You should call this function to create your Starling view. The RootClass is internal, it is never used elsewhere. 
		 * StarlingScene is added on the starling stage : <code>_starling.stage.addChildAt(_scene as StarlingScene, _sceneDisplayIndex);</code>
		 * @param debugMode If true, display a Stats class instance.
		 * @param antiAliasing The antialiasing value allows you to set the anti-aliasing (0 - 4)
		 * @param viewPort Starling's viewport, default is (0, 0, stage.stageWidth, stage.stageHeight, change to (0, 0, stage.fullScreenWidth, stage.fullScreenHeight) for mobile.
		 * @param stage3D The reference to the Stage3D, useful for sharing a 3D context. <a href="http://wiki.starling-framework.org/tutorials/combining_starling_with_other_stage3d_frameworks">More informations</a>.
		 */
		public function setUpStarling(debugMode:Boolean = false, antiAliasing:uint = 0, viewPort:Rectangle = null, stage3D:Stage3D = null):void {
				
			if (viewPort)
				_viewport = viewPort;
				
			_debug = debugMode;
			_starling = new Starling(RootClass, stage, null, stage3D, "auto", _context3DProfiles);
			_starling.antiAliasing = antiAliasing;
			_starling.showStats = debugMode;
			_starling.skipUnchangedFrames = true;
			_starling.addEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
			_starling.stage.addEventListener(starling.events.Event.RESIZE, handleStarlingStageResize);
		}

		protected function handleStarlingStageResize(evt:starling.events.Event):void {
			resetScreenSize();
			onStageResize.dispatch(_screenWidth, _screenHeight);
		}
		
		/**
		 * returns the asset size closest to one of the available asset sizes you have (based on <code>Starling.contentScaleFactor</code>).
		 * If you design your app with a Starling's stage dimension equals to the Flash's stage dimension, you will have to overwrite 
		 * this function since the <code>Starling.contentScaleFactor</code> will be always equal to 1.
		 * @param	assetSizes Array of numbers listing all asset sizes you use
		 * @return
		 */
		protected function findTextureScaleFactor(assetSizes:Array):Number
		{
			var arr:Array = assetSizes;
			arr.sort(Array.NUMERIC);
			var scaleF:Number = Math.floor(starling.contentScaleFactor * 1000) / 1000;
			var closest:Number;
			var f:Number;
			for each (f in arr)
				if (!closest || Math.abs(f - scaleF) < Math.abs(closest - scaleF))
					closest = f;
			
			return closest;
		}
		
		protected function resetViewport():Rectangle
		{
			if (_baseHeight < 0)
				_baseHeight = _screenHeight;
			if (_baseWidth < 0)
				_baseWidth = _screenWidth;
				
			_viewport.setEmpty();
			
			_baseRectangle.setTo(0, 0, _baseWidth, _baseHeight);
			_screenRectangle.setTo(0, 0, _screenWidth, _screenHeight);
			
			
			switch(_viewportMode)
			{
				case ViewportMode.LETTERBOX:
					
					RectangleUtil.fit(_baseRectangle, _screenRectangle, ScaleMode.SHOW_ALL,false,_viewport);
					
					_viewport.x = _screenWidth * .5 - _viewport.width * .5;
					_viewport.y = _screenHeight * .5 - _viewport.height * .5;
					
					_starling.stage.stageWidth = _baseWidth;
					_starling.stage.stageHeight = _baseHeight;
					
					break;
					
				case ViewportMode.FULLSCREEN:
				case ViewportMode.FILL:
					
					RectangleUtil.fit(_baseRectangle, _screenRectangle,_viewportMode == ViewportMode.FULLSCREEN ? ScaleMode.SHOW_ALL : ScaleMode.NO_BORDER,false,_viewport);
				
					_viewportBaseRatioWidth = _viewport.width / _baseRectangle.width;
					_viewportBaseRatioHeight = _viewport.height / _baseRectangle.height;
					_viewport.copyFrom(_screenRectangle);
					
					_viewport.x = _screenWidth * .5 - _viewport.width * .5;
					_viewport.y = _screenHeight * .5 - _viewport.height * .5;
					
					_starling.stage.stageWidth = _screenRectangle.width / _viewportBaseRatioWidth;
					_starling.stage.stageHeight = _screenRectangle.height / _viewportBaseRatioHeight;
					
					break;
				
				case ViewportMode.NO_SCALE:
					_viewport = _baseRectangle;
					
					_viewport.x = _screenWidth * .5 - _viewport.width * .5;
					_viewport.y = _screenHeight * .5 - _viewport.height * .5;
					
					_starling.stage.stageWidth = _baseWidth;
					_starling.stage.stageHeight = _baseHeight;
					
					_viewport = _screenRectangle.intersection(_viewport);
					
					break;
				case ViewportMode.LEGACY:
						_viewport = _screenRectangle;
						
						_starling.stage.stageWidth = _screenRectangle.width;
						_starling.stage.stageHeight = _screenRectangle.height;
						
					break;
				case ViewportMode.MANUAL:
					if(!_viewport)
						_viewport = _starling.viewPort.clone();
					break;
			}
			
			_starling.viewPort.copyFrom(_viewport);
			
			textureScaleFactor = findTextureScaleFactor(_assetSizes);
			
			transformMatrix.identity();
			transformMatrix.scale(_starling.contentScaleFactor,_starling.contentScaleFactor);
			transformMatrix.translate(_viewport.x,_viewport.y);
			
			return _viewport;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function resetScreenSize():void
		{
			super.resetScreenSize();
			
			if (!_starling)
				return;
			
			resetViewport(); 
			
			setupStats();
		}
		
		public function setupStats(hAlign:String = "left",vAlign:String = "top",scale:Number = 1):void
		{
			if(_starling && _starling.showStats)
					_starling.showStatsAt(hAlign, vAlign,scale/_starling.contentScaleFactor);
		}

		/**
		 * Be sure that starling is initialized (especially on mobile).
		 */
		protected function _context3DCreated(evt:starling.events.Event):void {

			_starling.removeEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
			
			if (!_starling.isStarted)
				_starling.start();
				
			_starling.addEventListener(starling.events.Event.ROOT_CREATED, _starlingRootCreated);
		}
		
		protected function _starlingRootCreated(evt:starling.events.Event):void {
			
			_starling.removeEventListener(starling.events.Event.ROOT_CREATED, _starlingRootCreated);
				
			stage.removeEventListener(flash.events.Event.RESIZE, handleStageResize);
			
			_starlingRoot = _starling.root as DisplayObjectContainer;
			
			resetScreenSize();
			handleStarlingReady();
			setupStats();
		}
		
		/**
		 * This function is called when context3D is ready and the starling root is created.
		 * the idea is to use this function for asset loading through the starling AssetManager and create the first scene.
		 */
		public function handleStarlingReady():void {	
		}

		public function get starling() : Starling {
			return _starling;
		}

		override citrus_internal function addSceneOver(value : IScene) : void {
			if (_starling && _starling.stage)
				_starlingRoot.addChild(value as StarlingScene);
		}

		override citrus_internal function addSceneUnder(value : IScene) : void {
			if (_starling && _starling.stage)
				_starlingRoot.addChildAt(value as StarlingScene, _sceneDisplayIndex);
		}

		override citrus_internal function removeScene(value : IScene) : void {
			if (_starling && _starling.stage)
				_starlingRoot.removeChild(value as StarlingScene, true);
		}

		/**
		 * @inheritDoc
		 */
		override protected function handleEnterFrame(e : flash.events.Event) : void {
			if (_juggler)
				_juggler.advanceTime(_timeDelta);

			super.handleEnterFrame(e);
		}
		
		/**
		 * @inheritDoc
		 * We stop Starling. Be careful, if you use AdMob you will need to override this function and set Starling stop to <code>true</code>!
		 * If you encounter issues with AdMob, you may override <code>handleStageDeactivated</code> and <code>handleStageActivated</code> and use <code>NativeApplication.nativeApplication</code> instead.
		 */
		override protected function handleStageDeactivated(e:flash.events.Event):void {

			if (_playing && _starling)
				_starling.stop(_suspendRenderingOnDeactivate);

			super.handleStageDeactivated(e);
		}
		
		/**
		 * @inheritDoc
		 * We start Starling.
		 */
		override protected function handleStageActivated(e:flash.events.Event):void {

			if (_starling && !_starling.isStarted)
				_starling.start();

			super.handleStageActivated(e);
		}
		
		public function get baseWidth() : int {
			return _baseWidth;
		}

		public function set baseWidth(value : int) : void {
			_baseWidth = value;
			resetScreenSize();
		}

		public function get baseHeight() : int {
			return _baseHeight;
		}

		public function set baseHeight(value : int) : void {
			_baseHeight = value;
			resetScreenSize();
		}

		public function get viewportMode() : String {
			return _viewportMode;
		}

		public function set viewportMode(value : String) : void {
			_viewportMode = value;
			resetScreenSize();		
			onStageResize.dispatch(_screenWidth, _screenHeight);
		}
		
		public function get juggler():CitrusStarlingJuggler
		{
			return _juggler;
		}

	}
}



import starling.display.Sprite;


/**
 * RootClass is the root of Starling, it is never destroyed and only accessed through <code>_starling.stage</code>.
 */
internal class RootClass extends Sprite {

	public function RootClass() {
	}
}
