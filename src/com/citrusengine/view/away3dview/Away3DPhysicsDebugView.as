package com.citrusengine.view.away3dview {

	import away3d.containers.ObjectContainer3D;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.State;
	import com.citrusengine.physics.APhysicsEngine;
	import com.citrusengine.physics.IDebugView;

	import flash.display.Sprite;
	
	/**
	 * A wrapper for Away3D to display the debug view of the different physics engine
	 */
	public class Away3DPhysicsDebugView extends ObjectContainer3D {
		
		private var _ce:CitrusEngine;
		
		private var _physicsEngine:APhysicsEngine;
		private var _debugView:IDebugView;
		
		public function Away3DPhysicsDebugView() {
			
			_ce = CitrusEngine.getInstance();
			
			_physicsEngine = _ce.state.getFirstObjectByType(APhysicsEngine) as APhysicsEngine;
			_debugView = new _physicsEngine.realDebugView();
			
			if ((_ce.state.view as Away3DView).mode != "3D") {
				(_ce.state as State).addChild(_debugView as Sprite);
				(_debugView as Sprite).name = "debug view";
			}
		}
		
		public function update():void {
			_debugView.update();
		}
		
		public function debugMode(mode:uint):void {
			_debugView.debugMode(mode);
		}
	}
}
