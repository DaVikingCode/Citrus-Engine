package citrus.core {

	import starling.core.Starling;
	import starling.events.Event;

	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;

	/**
	 * Extends this class if you create a Starling based game. Don't forget to call <code>setUpStarling</code> function.
	 * 
	 * <p>CitrusEngine can access to the Stage3D power thanks to the <a href="http://starling-framework.org/">Starling Framework</a>.</p>
	 */
	public class StarlingCitrusEngine extends CitrusEngine {

		protected var _starling:Starling;

		public function StarlingCitrusEngine() {
			super();
		}

		override public function destroy():void {

			super.destroy();

			if (_state) {

				if (_starling) {

					_starling.stage.removeChild(_state as StarlingState);
					
					// Remove Box2D or Nape debug view
					var debugView:DisplayObject = _starling.nativeStage.getChildByName("debug view");
					if (debugView)
						 _starling.nativeStage.removeChild(debugView);		

					_starling.dispose();
				}
			}
		}

		/**
		 * You should call this function to create your Starling view. The RootClass is internal, it is never used elsewhere. 
		 * StarlingState is added on the starling stage : <code>_starling.stage.addChildAt(_state as StarlingState, _stateDisplayIndex);</code>
		 * @param debugMode : If true, display a Stats class instance.
		 * @param antiAliasing : The antialiasing value allows you to set the anti-aliasing (0 - 16), generally a value of 1 is totally acceptable.
		 * @param flashStage : If you don't use this class as your root class you need to give a reference to your actual stage.
		 * @param viewPort : Starling's viewport, default is (0, 0, stage.stageWidth, stage.stageHeight, change to (0, 0, stage.fullScreenWidth, stage.fullScreenHeight) for mobile.
		 */
		public function setUpStarling(debugMode:Boolean = false, antiAliasing:uint = 1, flashStage:Stage = null, viewPort:Rectangle = null):void {
			
			if (!flashStage)
				flashStage = stage;

			if (!viewPort)
				viewPort = new Rectangle(0, 0, flashStage.stageWidth, flashStage.stageHeight);

			_starling = new Starling(RootClass, flashStage, viewPort, null, "auto", "baseline");

			_starling.antiAliasing = antiAliasing;
			_starling.showStats = debugMode;

			_starling.addEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
		}

		/**
		 * Be sure that starling is initialized (especially on mobile).
		 */ 
		protected function _context3DCreated(evt:starling.events.Event):void {

			_starling.removeEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
			
			if (!_starling.isStarted)
				_starling.start();
		}

		public function get starling():Starling {
			return _starling;
		}

		override protected function handleEnterFrame(e:flash.events.Event):void {

			if (_newState) {
				
				if (_starling.isStarted && _starling.context) {
					
					if (_state) {

						_state.destroy();
						_starling.stage.removeChild(_state as StarlingState);
						
						// Remove Box2D or Nape debug view
						var debugView:DisplayObject = _starling.nativeStage.getChildByName("debug view");
						if (debugView)
							 _starling.nativeStage.removeChild(debugView);
					}
					_state = _newState;
					_newState = null;

					_starling.stage.addChildAt(_state as StarlingState, _stateDisplayIndex);
					_state.initialize();
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
