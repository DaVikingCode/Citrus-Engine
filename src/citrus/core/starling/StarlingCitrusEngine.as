package citrus.core.starling {

	import citrus.core.CitrusEngine;
	import citrus.core.State;
	import citrus.utils.Context3DUtil;
	import citrus.utils.Mobile;

	import starling.core.Starling;
	import starling.events.Event;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;

	import flash.display3D.Context3DProfile;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	/**
	 * Extends this class if you create a Starling based game. Don't forget to call <code>setUpStarling</code> function.
	 * 
	 * <p>CitrusEngine can access to the Stage3D power thanks to the <a href="http://starling-framework.org/">Starling Framework</a>.</p>
	 */
	public class StarlingCitrusEngine extends CitrusEngine {
		
		public var scaleFactor:Number = 1;

		protected var _starling:Starling;
		
		protected var _assetSizes:Array = [1];
		protected var _baseWidth:int = -1;
		protected var _baseHeight:int = -1;
		protected var _viewportBaseRatioWidth:Number = 1;
		protected var _viewportBaseRatioHeight:Number = 1;
		protected var _viewportMode:String = ViewportMode.LEGACY;
		protected var _viewport:Rectangle;
		
		/**
		 * context3D profiles to test for in Ascending order (the more important first).
		 * reset this array to a single entry to force one specific profile.
		 */
		protected var _context3DProfiles:Array = [Context3DProfile.BASELINE_EXTENDED,Context3DProfile.BASELINE,Context3DProfile.BASELINE_CONSTRAINED];
		protected var _context3DProfileTestDelay:int = 100;
		
		public function StarlingCitrusEngine() {
			super();
		}

		override public function destroy():void {

			super.destroy();

			if (_state) {

				if (_starling) {

					_starling.stage.removeChild(_state as StarlingState);
					_starling.root.dispose();
					_starling.dispose();
				}
			}
		}

		/**
		 * You should call this function to create your Starling view. The RootClass is internal, it is never used elsewhere. 
		 * StarlingState is added on the starling stage : <code>_starling.stage.addChildAt(_state as StarlingState, _stateDisplayIndex);</code>
		 * @param debugMode If true, display a Stats class instance.
		 * @param antiAliasing The antialiasing value allows you to set the anti-aliasing (0 - 16), generally a value of 1 is totally acceptable.
		 * @param viewPort Starling's viewport, default is (0, 0, stage.stageWidth, stage.stageHeight, change to (0, 0, stage.fullScreenWidth, stage.fullScreenHeight) for mobile.
		 * @param profile The Context3DProfile that should be requested <a href="http://wiki.starling-framework.org/manual/constrained_stage3d_profile">More informations</a>. if set to "auto", then CitrusEngine will figure out the right one according to the scaleFactor value.
		 */
		public function setUpStarling(debugMode:Boolean = false, antiAliasing:uint = 1, viewPort:Rectangle = null, profile:String = "auto"):void {

			if (Mobile.isAndroid())
				Starling.handleLostContext = true;
				
			if (viewPort)
				_viewport = viewPort;
				
				
			var starlingInit:Function = function(profile:String):void
			{
				_starling = new Starling(RootClass, stage, null, null, "auto", profile);
				_starling.antiAliasing = antiAliasing;
				_starling.showStats = debugMode;
				_starling.addEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
			}
				
			if (profile == "auto")
			{
					
				var profiletests:Array = _context3DProfiles.slice();
				
				var testProfiles:Function = function(profile:String, success:Boolean):void
				{
					if (success)
					{
						if(debugMode)
							trace("[StarlingCitrusEngine] Context3DProfile -", profile, "is supported! setting up starling...");
						starlingInit(profile);
						return;
					}
					
					if(debugMode)
							trace("[StarlingCitrusEngine] Context3DProfile -", profile, "is not supported...");
					
					if (profiletests.length > 0)
					{
						if (_context3DProfileTestDelay == 0)
							Context3DUtil.supportsProfile(stage, profiletests.shift(), testProfiles);
						else
							setTimeout(Context3DUtil.supportsProfile,_context3DProfileTestDelay,stage, profiletests.shift(), testProfiles);
					}else if (profiletests.length == 0)
						throw new ArgumentError("[StarlingCitrusEngine] Failed to create any Context3D with a profile from this list : " + String(_context3DProfiles) + ". check the render mode?");
				}
				
				if(debugMode)
						trace("[StarlingCitrusEngine] Context3DProfile - testing :", profiletests, "with delay:"+_context3DProfileTestDelay+"ms ...");
				Context3DUtil.supportsProfile(stage, profiletests.shift(), testProfiles);
			
			}
			else
			{
				starlingInit(profile);
			}
			
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
			var scaleF:Number = Math.floor(starling.contentScaleFactor * 10) / 10;
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
			
			return _viewport;
		}
		
		override protected function resetScreenSize():void
		{
			super.resetScreenSize();
			
			if (!_starling)
				return;
			
			resetViewport();
			_starling.viewPort.copyFrom(_viewport);
		}

		/**
		 * Be sure that starling is initialized (especially on mobile).
		 */
		protected function _context3DCreated(evt:starling.events.Event):void {

			_starling.removeEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
			
			resetScreenSize();
			
			if (!_starling.isStarted)
				_starling.start();
				
			_starling.addEventListener(starling.events.Event.ROOT_CREATED, function():void
			{
				_starling.removeEventListener(starling.events.Event.ROOT_CREATED, arguments.callee);
				handleStarlingReady();
			});
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

		override protected function handleEnterFrame(e:flash.events.Event):void {

			if (_starling && _starling.isStarted && _starling.context) {

				if (_newState) {

					if (_state) {

						if (_state is StarlingState) {

							_state.destroy();
							_starling.stage.removeChild(_state as StarlingState, true);

						} else {

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
		}

		override protected function handleStageDeactivated(e:flash.events.Event):void {

			if (_playing && _starling)
				_starling.stop();

			super.handleStageDeactivated(e);
		}

		override protected function handleStageActivated(e:flash.events.Event):void {

			if (_starling && !_starling.isStarted)
				_starling.start();

			super.handleStageActivated(e);
		}
		
		public function get baseWidth():int
		{
			return _baseWidth;
		}
		
		public function get baseHeight():int
		{
			return _baseHeight;
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
