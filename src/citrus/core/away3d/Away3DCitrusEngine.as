package citrus.core.away3d {

	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;

	import citrus.core.CitrusEngine;

	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * Extends this class if you create an Away3D based game. Don't forget to call <code>setUpAway3D</code> function.
	 * 
	 * <p>CitrusEngine can access to the Stage3D power thanks to the <a href="http://www.away3d.com/">Away3D Framework</a>.</p>
	 */
	public class Away3DCitrusEngine extends CitrusEngine {
		
		protected var _away3D:View3D;

		public function Away3DCitrusEngine() {
			
			super();
			
			stage.addEventListener(Event.RESIZE, _onResize);
		}

		override public function destroy():void {
			
			stage.removeEventListener(Event.RESIZE, _onResize);
			
			super.destroy();
		}
		
		/**
		 * You should call this function to create your Away3D view. Away3DState is added on the Away3D's scene.
		 * @param debugMode If true, display a AwayStats class instance.
		 * @param antiAliasing The antialiasing value allows you to set the anti-aliasing (0 - 16), generally a value of 4 is totally acceptable.
		 * @param scene3D You may already have a Scene3D to set up.
		 * @param stage3DProxy If you want to use Starling, or multiple Away3D instance you need to use a Stage3DProxy.
		 */
		public function setUpAway3D(debugMode:Boolean = false, antiAliasing:uint = 4, scene3D:Scene3D = null, stage3DProxy:Stage3DProxy = null):void {
			
			_away3D = new View3D(scene3D);
			_away3D.antiAlias = antiAliasing;
			
			if (stage3DProxy) {
				_away3D.stage3DProxy = stage3DProxy;
				_away3D.shareContext = true;
			}
			
			addChildAt(_away3D, _stateDisplayIndex);
			
			if (debugMode)
				addChild(new AwayStats(_away3D));
		}
		
		public function get away3D():View3D {
			return _away3D;
		}
		
		override protected function handleEnterFrame(e:Event):void {

			if (_newState) {
				
				if (_away3D.scene) {
					
					if (_state) {

						_state.destroy();
						_away3D.scene.removeChild(_state as Away3DState);
						
						// Remove Box2D or Nape debug view
						var debugView:DisplayObject = stage.getChildByName("debug view");
						if (debugView)
							stage.removeChild(debugView);
					}
					_state = _newState;
					_newState = null;
					
					_away3D.scene.addChild(_state as Away3DState);
					_state.initialize();
				}

			}
			
			if (_state && _playing)
				_away3D.render();
			
			super.handleEnterFrame(e);
		}
		
		protected function _onResize(evt:Event):void {
			
			_away3D.width = stage.stageWidth;
			_away3D.height = stage.stageHeight;
		}

	}
}
