package citrus.view.spriteview {

	import citrus.core.CitrusEngine;
	import citrus.physics.APhysicsEngine;
	import citrus.physics.IDebugView;
	import flash.events.Event;
	import flash.display.Sprite;
	
	public class SpritePhysicsDebugView extends Sprite {
		
		private var _physicsEngine:APhysicsEngine;
		private var _debugView:IDebugView;
		
		public function SpritePhysicsDebugView() {
			
			_physicsEngine = CitrusEngine.getInstance().state.getFirstObjectByType(APhysicsEngine) as APhysicsEngine;
			_debugView = new _physicsEngine.realDebugView();
			(_debugView as Sprite).name = "debug view";
			stage.addChild(_debugView as Sprite);
			addEventListener(Event.REMOVED, destroy);
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
			stage.removeChild(_debugView as Sprite);
			_physicsEngine = null;
			_debugView = null;
		}
		
	}
}
