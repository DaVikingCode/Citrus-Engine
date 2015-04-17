package citrus.core.starling {

	import citrus.core.CitrusEngine;
	import citrus.core.State;

	import starling.core.Starling;
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
		
		public var scaleFactor:Number = 1;

		protected var _starling:Starling;
		protected var _juggler:CitrusStarlingJuggler;
		
		protected var _assetSizes:Array = [1];
		protected var _baseWidth:int = -1;
		protected var _baseHeight:int = -1;
		protected var _viewportMode:String = ViewportMode.LEGACY;
		protected var _viewport:Rectangle;
		
		private var _viewportBaseRatioWidth:Number = 1;
		private var _viewportBaseRatioHeight:Number = 1;
		
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

			if (_state) {

				if (_starling) {
					_starling.stage.removeEventListener(starling.events.Event.RESIZE, handleStarlingStageResize);
					_starling.stage.removeChild(_state as StarlingState);
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
		 * StarlingState is added on the starling stage : <code>_starling.stage.addChildAt(_state as StarlingState, _stateDisplayIndex);</code>
		 * @param debugMode If true, display a Stats class instance.
		 * @param antiAliasing The antialiasing value allows you to set the anti-aliasing (0 - 16), generally a value of 1 is totally acceptable.
		 * @param viewPort Starling's viewport, default is (0, 0, stage.stageWidth, stage.stageHeight, change to (0, 0, stage.fullScreenWidth, stage.fullScreenHeight) for mobile.
		 * @param stage3D The reference to the Stage3D, useful for sharing a 3D context. <a href="http://wiki.starling-framework.org/tutorials/combining_starling_with_other_stage3d_frameworks">More informations</a>.
		 */
		public function setUpStarling(debugMode:Boolean = false, antiAliasing:uint = 1, viewPort:Rectangle = null, stage3D:Stage3D = null):void {

			Starling.handleLostContext = true;
				
			if (viewPort)
				_viewport = viewPort;
				
			_starling = new Starling(RootClass, stage, null, stage3D, "auto", _context3DProfiles);
			_starling.antiAliasing = antiAliasing;
			_starling.showStats = debugMode;
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
		protected function findScaleFactor(assetSizes:Array):Number
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
				
			var baseRect:Rectangle = new Rectangle(0, 0, _baseWidth, _baseHeight);
			var screenRect:Rectangle = new Rectangle(0, 0, _screenWidth, _screenHeight);
			
			switch(_viewportMode)
			{
				case ViewportMode.LETTERBOX:
					_viewport = RectangleUtil.fit(baseRect, screenRect, ScaleMode.SHOW_ALL);
					_viewport.x = _screenWidth * .5 - _viewport.width * .5;
					_viewport.y = _screenHeight * .5 - _viewport.height * .5;
					if (_starling)
					{
						_starling.stage.stageWidth = _baseWidth;
						_starling.stage.stageHeight = _baseHeight;
					}
					
					break;
				case ViewportMode.FULLSCREEN:
					_viewport = RectangleUtil.fit(baseRect, screenRect, ScaleMode.SHOW_ALL);
					_viewportBaseRatioWidth = _viewport.width / baseRect.width;
					_viewportBaseRatioHeight = _viewport.height / baseRect.height;
					_viewport.copyFrom(screenRect);
					
					_viewport.x = 0;
					_viewport.y = 0;
					
					if (_starling)
					{
						_starling.stage.stageWidth = screenRect.width / _viewportBaseRatioWidth;
						_starling.stage.stageHeight = screenRect.height / _viewportBaseRatioHeight;
					}
					
					break;
				case ViewportMode.NO_SCALE:
					_viewport = baseRect;
					_viewport.x = _screenWidth * .5 - _viewport.width * .5;
					_viewport.y = _screenHeight * .5 - _viewport.height * .5;
					
					if (_starling)
					{
						_starling.stage.stageWidth = _baseWidth;
						_starling.stage.stageHeight = _baseHeight;
					}
					
					break;
				case ViewportMode.LEGACY:
						_viewport = screenRect;
						if (_starling)
						{
							_starling.stage.stageWidth = screenRect.width;
							_starling.stage.stageHeight = screenRect.height;
						}
				case ViewportMode.MANUAL:
					if(!_viewport)
						_viewport = _starling.viewPort.clone();
					break;
			}
			
			scaleFactor = findScaleFactor(_assetSizes);
			
			if (_starling)
			{
				transformMatrix.identity();
				transformMatrix.scale(_starling.contentScaleFactor,_starling.contentScaleFactor);
				transformMatrix.translate(_viewport.x,_viewport.y);
			}
			
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
			_starling.viewPort.copyFrom(_viewport);
			
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
			
			resetScreenSize();
			
			if (!_starling.isStarted)
				_starling.start();
				
			_starling.addEventListener(starling.events.Event.ROOT_CREATED, _starlingRootCreated);
		}
		
		protected function _starlingRootCreated(evt:starling.events.Event):void {
			
			_starling.removeEventListener(starling.events.Event.ROOT_CREATED, _starlingRootCreated);
				
			stage.removeEventListener(flash.events.Event.RESIZE, handleStageResize);
			
			handleStarlingReady();
			setupStats();
		}
		
		/**
		 * This function is called when context3D is ready and the starling root is created.
		 * the idea is to use this function for asset loading through the starling AssetManager and create the first state.
		 */
		public function handleStarlingReady():void {	
		}

		public function get starling():Starling {
			return _starling;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function handleEnterFrame(e:flash.events.Event):void {

			if (_starling && _starling.isStarted && _starling.context) {

				if (_newState) {

					if (_state) {

						if (_state is StarlingState) {

							_state.destroy();
							_starling.stage.removeChild(_state as StarlingState, true);

						} else if(_newState is StarlingState) {

							_state.destroy();
							removeChild(_state as State);
						}

					}

					if (_newState is StarlingState) {

						_state = _newState;
						_newState = null;

						if (_futureState)
							_futureState = null;
						else {
							_starling.stage.addChildAt(_state as StarlingState, _stateDisplayIndex);
							_state.initialize();
						}
					}
				}

				if (_stateTransitionning && _stateTransitionning is StarlingState) {

					_futureState = _stateTransitionning;
					_stateTransitionning = null;

					starling.stage.addChildAt(_futureState as StarlingState, _stateDisplayIndex);
					_futureState.initialize();
				}

			}

			super.handleEnterFrame(e);
			
			if(_juggler)
				_juggler.advanceTime(_timeDelta);
			
		}
		
		/**
		 * @inheritDoc
		 * We stop Starling. Be careful, if you use AdMob you will need to override this function and set Starling stop to <code>true</code>!
		 * If you encounter issues with AdMob, you may override <code>handleStageDeactivated</code> and <code>handleStageActivated</code> and use <code>NativeApplication.nativeApplication</code> instead.
		 */
		override protected function handleStageDeactivated(e:flash.events.Event):void {

			if (_playing && _starling)
				_starling.stop();

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
		
		public function get baseWidth():int
		{
			return _baseWidth;
		}
		
		public function set baseWidth(value:int):void {
			
			_baseWidth = value;
			
			resetViewport();
		}
		
		public function get baseHeight():int
		{
			return _baseHeight;
		}
		
		public function set baseHeight(value:int):void {
			
			_baseHeight = value;
			
			resetViewport();
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
