package citrus.physics.nape {

	import citrus.core.CitrusEngine;
	import citrus.physics.IDebugView;

	import nape.util.ShapeDebug;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * This displays Nape's debug graphics. It does so properly through Citrus Engine's view manager. Nape by default
	 * sets visible to false with an alpha of 0.8, so you'll need to set the Nape object's visible property to true in order to see the debug graphics. 
	 */
	public class NapeDebugArt extends Sprite implements IDebugView {
		
		private var _nape:Nape;
		private var _debugDrawer:ShapeDebug;

		public function NapeDebugArt() {
			
			addEventListener(Event.ADDED_TO_STAGE, _addedToStage);
		}
		
		private function _addedToStage(evt:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, _addedToStage);
			
			_nape = CitrusEngine.getInstance().state.getFirstObjectByType(Nape) as Nape;
			
			_debugDrawer = new ShapeDebug(stage.stageWidth, stage.stageHeight);
			addChild(_debugDrawer.display);
			
			_debugDrawer.display.alpha = 0.8;
		}
		
		public function update():void
		{
			if (_nape.visible) {
				
				_debugDrawer.clear();
				_debugDrawer.draw(_nape.space);
				_debugDrawer.flush();
			}
		}
		
		public function debugMode(mode:uint):void {
			
		}
	}
}
