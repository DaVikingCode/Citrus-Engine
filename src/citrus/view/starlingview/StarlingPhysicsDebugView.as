package citrus.view.starlingview {

	import citrus.core.CitrusEngine;
	import citrus.physics.APhysicsEngine;
	import citrus.physics.IDebugView;

	import starling.core.Starling;
	import starling.display.Sprite;

	import flash.display.Sprite;
	
	/**
	 * A wrapper for Starling to display the debug view of the different physics engine.
	 */
	public class StarlingPhysicsDebugView extends starling.display.Sprite {
		
		private var _physicsEngine:APhysicsEngine;
		private var _debugView:IDebugView;
		
		public function StarlingPhysicsDebugView() {
			
			_physicsEngine = CitrusEngine.getInstance().state.getFirstObjectByType(APhysicsEngine) as APhysicsEngine;
			_debugView = new _physicsEngine.realDebugView();
			
			(_debugView as flash.display.Sprite).name = "debug view";
			Starling.current.nativeStage.addChild(_debugView as flash.display.Sprite);
		}
		
		public function update():void {
			_debugView.update();
		}

		public function get debugView():flash.display.Sprite {
			return _debugView as flash.display.Sprite;
		}
	}
}
