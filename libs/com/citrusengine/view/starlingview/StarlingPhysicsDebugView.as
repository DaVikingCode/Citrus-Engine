package com.citrusengine.view.starlingview {

	import starling.core.Starling;
	import starling.display.Sprite;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.physics.APhysicsEngine;
	import com.citrusengine.physics.IDebugView;

	import flash.display.Sprite;
	
	/**
	 * A wrapper for Starling to display the debug view of the different physics engine
	 */
	public class StarlingPhysicsDebugView extends starling.display.Sprite {
		
		private var _physicsEngine:APhysicsEngine;
		private var _debugView:IDebugView;
		
		public function StarlingPhysicsDebugView() {
			
			_physicsEngine = CitrusEngine.getInstance().state.getFirstObjectByType(APhysicsEngine) as APhysicsEngine;
			_debugView = new _physicsEngine.realDebugView();
			
			Starling.current.nativeStage.addChild(_debugView as flash.display.Sprite);
		}
		
		public function update():void {
			_debugView.update();
		}
	}
}
