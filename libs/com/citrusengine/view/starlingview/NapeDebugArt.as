package com.citrusengine.view.starlingview {

	import nape.util.ShapeDebug;

	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;

	import com.citrusengine.physics.Nape;
	import com.citrusengine.view.IDebugView;

	/**
	 * This displays Nape's debug graphics. It does so properly through Citrus Engine's view manager. Nape by default
	 * sets visible to false, so you'll need to set the Nape object's visible property to true in order to see the debug graphics. 
	 */
	public class NapeDebugArt extends Sprite implements IDebugView {
		
		private var _nape:Nape;
		private var _debugDrawer:ShapeDebug;

		public function NapeDebugArt() {
			
			addEventListener(Event.ADDED, _handleAddedToParent);
		}

		private function _handleAddedToParent(evt:Event):void {
			
			removeEventListener(Event.ADDED, _handleAddedToParent);
			
			_nape = StarlingArt(parent).citrusObject as Nape;

			_debugDrawer = new ShapeDebug(Starling.current.stage.stageWidth, Starling.current.stage.stageHeight);
			Starling.current.nativeStage.addChild(_debugDrawer.display);
		}
		
		public function update():void {
			
			_debugDrawer.clear();
			_debugDrawer.draw(_nape.space);
			_debugDrawer.flush();
		}
		
		public function debugMode(mode:uint):void {
			
		}
	}
}
