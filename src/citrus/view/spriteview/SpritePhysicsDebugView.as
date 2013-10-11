package citrus.view.spriteview {

	import citrus.core.CitrusEngine;
	import citrus.physics.APhysicsEngine;
	import citrus.physics.IDebugView;
	import flash.display.Sprite;
	import flash.events.Event;

	
	public class SpritePhysicsDebugView extends Sprite {
		
		private var _physicsEngine:APhysicsEngine;
		private var _debugView:IDebugView;
		
		public function SpritePhysicsDebugView() {
			
			_physicsEngine = CitrusEngine.getInstance().state.getFirstObjectByType(APhysicsEngine) as APhysicsEngine;
			_debugView = new _physicsEngine.realDebugView();
			addEventListener(Event.ADDED_TO_STAGE, _addedToStage);
		}

		private function _addedToStage(event:Event):void {
			
			removeEventListener(Event.ADDED_TO_STAGE, _addedToStage);
			_debugView.initialize();
			addEventListener(Event.REMOVED_FROM_STAGE, _removedFromStage);
		}
		
		private function _removedFromStage(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, _removedFromStage);
			_debugView.destroy();
			_physicsEngine = null;
			_debugView = null;
		}
		
		public function update():void {
			_debugView.update();
		}
		
		public function debugMode(flags:uint):void {
			_debugView.debugMode(flags);
		}

		public function get debugView():IDebugView {
			return _debugView;
		}
		
	}
}
