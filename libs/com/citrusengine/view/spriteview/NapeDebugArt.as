package com.citrusengine.view.spriteview {

	import com.citrusengine.physics.Nape;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import nape.util.ShapeDebug;

	/**
	 * This displays Nape's debug graphics. It does so properly through Citrus Engine's view manager. Nape by default
	 * sets visible to false, so you'll need to set the Nape object's visible property to true in order to see the debug graphics. 
	 */
	public class NapeDebugArt extends MovieClip {
		
		private var _nape:Nape;
		private var _debugDrawer:ShapeDebug;

		public function NapeDebugArt() {
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToParent);
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			addEventListener(Event.REMOVED, destroy);
		}
		
		private function handleAddedToParent(evt:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToParent);
			
			_nape = SpriteArt(parent).citrusObject as Nape;
			
			_debugDrawer = new ShapeDebug(stage.stageWidth, stage.stageHeight);
			addChild(_debugDrawer.display);
		}
		
		private function destroy(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToParent);
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			removeEventListener(Event.REMOVED, destroy);
		}
		
		private function handleEnterFrame(evt:Event):void
		{
			_debugDrawer.clear();
			_debugDrawer.draw(_nape.space);
			_debugDrawer.flush();
		}
	}
}
