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
			(_debugView as Sprite).name = "debug view";
			addEventListener(Event.ADDED_TO_STAGE, _addedToStage);
		}

		private function _addedToStage(event:Event):void {
			
			removeEventListener(Event.ADDED_TO_STAGE, _addedToStage);
			//addChild(_debugView as Sprite);
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
		
		public function destroy(e:Event):void
		{
			removeEventListener(Event.REMOVED, destroy);
			//removeChild(_debugView as Sprite);
			_physicsEngine = null;
			_debugView = null;
		}
		
	}
}
