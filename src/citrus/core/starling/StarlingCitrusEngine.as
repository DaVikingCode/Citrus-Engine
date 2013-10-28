package citrus.core.starling {

	import citrus.core.CitrusEngine;
	import citrus.core.State;
	import citrus.utils.Mobile;

	import starling.core.Starling;
	import starling.events.Event;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;

	import flash.display3D.Context3DProfile;
	import flash.events.Event;
	import flash.geom.Rectangle;

	/**
	 * Extends this class if you create a Starling based game. Don't forget to call <code>setUpStarling</code> function.
	 * 
	 * <p>CitrusEngine can access to the Stage3D power thanks to the <a href="http://starling-framework.org/">Starling Framework</a>.</p>
	 */
	public class StarlingCitrusEngine extends CitrusEngine {
		
		public var scaleFactor:Number = 0;

		protected var _starling:Starling;
		
		protected var _baseWidth:int = -1;
		protected var _baseHeight:int = -1;
		protected var _viewportBaseRatioWidth:Number = 1;
		protected var _viewportBaseRatioHeight:Number = 1;
		protected var _viewportMode:String = ViewportMode.LEGACY;
		protected var _viewport:Rectangle;

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

			_starling = new Starling(RootClass, stage, null, null, "auto", profile == "auto" ? (scaleFactor >= 4 ? Context3DProfile.BASELINE_EXTENDED : Context3DProfile.BASELINE) :  profile);
			
			_starling.antiAliasing = antiAliasing;
			_starling.showStats = debugMode;

			_starling.addEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
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
					_viewport.x = screenWidth * .5 - _viewport.width * .5;
					_viewport.y = screenHeight * .5 - _viewport.height * .5;
					
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
					_viewport.x = screenWidth * .5 - _viewport.width * .5;
					_viewport.y = screenHeight * .5 - _viewport.height * .5;
					
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
				
			return _viewport;
		}
		
		override protected function handleStageResize(e:flash.events.Event = null):void
		{
			super.handleStageResize(e);
			
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
			
			resetViewport();
			_starling.viewPort.copyFrom(_viewport);
			
			if (!_starling.isStarted)
				_starling.start();
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
