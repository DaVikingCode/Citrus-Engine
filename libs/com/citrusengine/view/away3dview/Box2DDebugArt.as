package com.citrusengine.view.away3dview {

	import Box2DAS.Dynamics.b2DebugDraw;

	import away3d.containers.ObjectContainer3D;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.State;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.view.IDebugView;

	/**
	 * @author Aymeric
	 */
	public class Box2DDebugArt extends ObjectContainer3D implements IDebugView {
		
		private var _ce:CitrusEngine;

		private var _box2D:Box2D;
		private var _debugDrawer:b2DebugDraw;
		
		public function Box2DDebugArt() {
			
			_ce = CitrusEngine.getInstance();
			
			if (parent is Away3DArt)
				_box2D = Away3DArt(parent).citrusObject as Box2D;
			else
				_box2D = _ce.state.getFirstObjectByType(Box2D) as Box2D;
			
			_debugDrawer = new b2DebugDraw();
			_debugDrawer.name = "debug view";
			(_ce.state as State).addChild(_debugDrawer);
			_debugDrawer.world = _box2D.world;
			_debugDrawer.scale = _box2D.scale;
		}
		
		public function update():void {
			_debugDrawer.Draw();
		}
	}
}
