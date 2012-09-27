package com.citrusengine.view.away3dview {

	import away3d.containers.ObjectContainer3D;

	import nape.util.ShapeDebug;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.State;
	import com.citrusengine.physics.Nape;

	/**
	 * @author Aymeric 
	 */
	public class NapeDebugArt extends ObjectContainer3D {
		
		private var _ce:CitrusEngine;
		
		private var _nape:Nape;
		private var _debugDrawer:ShapeDebug;

		public function NapeDebugArt() {
			
			_ce = CitrusEngine.getInstance();
			
			if (parent is Away3DArt)
				_nape = Away3DArt(parent).citrusObject as Nape;
			else
				_nape = _ce.state.getFirstObjectByType(Nape) as Nape;
			
			_debugDrawer = new ShapeDebug(_ce.stage.stageWidth, _ce.stage.stageHeight);
			_debugDrawer.display.name = "Nape debug view";
			(_ce.state as State).addChild(_debugDrawer.display);
		}
		
		public function update():void {
			
			_debugDrawer.clear();
			_debugDrawer.draw(_nape.space);
			_debugDrawer.flush();
		}
	}
}
