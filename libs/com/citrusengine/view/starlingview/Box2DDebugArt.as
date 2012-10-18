package com.citrusengine.view.starlingview {

	import Box2DAS.Dynamics.b2DebugDraw;

	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;

	import com.citrusengine.physics.Box2D;
	import com.citrusengine.view.IDebugView;

	/**
	 * This displays Box2D's debug graphics. It does so properly through Citrus Engine's view manager. Box2D by default
	 * sets visible to false, so you'll need to set the Box2D object's visible property to true in order to see the debug graphics. 
	 */
	public class Box2DDebugArt extends Sprite implements IDebugView {

		private var _box2D:Box2D;
		private var _debugDrawer:b2DebugDraw;

		public function Box2DDebugArt() {
			
			addEventListener(Event.ADDED, _handleAddedToParent);
		}

		private function _handleAddedToParent(evt:Event):void {
			
			removeEventListener(Event.ADDED, _handleAddedToParent);
			
			_box2D = StarlingArt(parent).citrusObject as Box2D;

			_debugDrawer = new b2DebugDraw();
			Starling.current.nativeStage.addChild(_debugDrawer);
			_debugDrawer.world = _box2D.world;
			_debugDrawer.scale = _box2D.scale;
		}
		
		public function update():void {
			
			_debugDrawer.Draw();
		}
		
		public function debugMode(mode:uint):void {
			
		}
	}
}