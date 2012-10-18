package com.citrusengine.view.spriteview {

	import nape.util.ShapeDebug;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.physics.Nape;
	import com.citrusengine.view.IDebugView;

	import flash.display.MovieClip;
	import flash.events.Event;

	/**
	 * This displays Nape's debug graphics. It does so properly through Citrus Engine's view manager. Nape by default
	 * sets visible to false, so you'll need to set the Nape object's visible property to true in order to see the debug graphics. 
	 */
	public class NapeDebugArt extends MovieClip implements IDebugView {
		
		private var _nape:Nape;
		private var _debugDrawer:ShapeDebug;

		public function NapeDebugArt() {
			
			addEventListener(Event.ADDED_TO_STAGE, _handleAddedToParent);
		}
		
		private function _handleAddedToParent(evt:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, _handleAddedToParent);
			
			if (parent is SpriteArt)
				_nape = SpriteArt(parent).citrusObject as Nape;
			else
				_nape = CitrusEngine.getInstance().state.getFirstObjectByType(Nape) as Nape;
			
			_debugDrawer = new ShapeDebug(stage.stageWidth, stage.stageHeight);
			addChild(_debugDrawer.display);
		}
		
		public function update():void
		{
			_debugDrawer.clear();
			_debugDrawer.draw(_nape.space);
			_debugDrawer.flush();
		}
		
		public function debugMode(mode:uint):void {
			
		}
	}
}
