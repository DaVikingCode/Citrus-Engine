package citrus.physics {

	import citrus.core.CitrusObject;
	import citrus.view.ICitrusArt;

	/**
	 * An abstract template used by every physics engine.
	 */
	public class APhysicsEngine extends CitrusObject {
		
		protected var _visible:Boolean = false;
		protected var _touchable:Boolean = false;
		protected var _group:uint = 1;
		protected var _view:*;
		protected var _realDebugView:*;

		public function APhysicsEngine(name:String, params:Object = null) {
			
			updateCallEnabled = true;
			
			super(name, params);
		}
		
		public function getBody():* {
			return null;
		}
		
		/**
		 * Shortcut to the debugView
		 * use to change the debug drawer's flags with debugView.debugMode()
		 * or access it directly through debugView.debugDrawer.
		 * 
		 * exists only after the physics engine has been added to the state.
		 * 
		 * Example : changing the debug views flags:
		 *
		 * Box2D :
		 * <code>
		 * var b2d:Box2D = new Box2D("b2d");
		 * b2d.gravity = b2Vec2.Make(0,0);
		 * b2d.visible = true;
		 * add(b2d);
		 * 
		 * b2d.debugView.debugMode(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
		 * //or
		 * (b2d.debugView.debugDrawer as b2DebugDraw).SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
		 * </code>
		 * 
		 * Nape:
		 * <code>
		 * nape = new Nape("nape");
		 * nape.visible = true;
		 * add(nape);
		 * 
		 * nape.debugView.debugMode(NapeDebugArt.draw_Bodies | NapeDebugArt.draw_BodyDetail | NapeDebugArt.draw_CollisionArbiters);
		 * //or
		 * var shapedebug:ShapeDebug = nape.debugView.debugDrawer as ShapeDebug;
		 * shapedebug.drawBodies = true;
		 * shapedebug.drawBodyDetail = true;
		 * shapedebug.drawCollisionArbiters = true;
		 * </code>
		 */
		public function get debugView():IDebugView {
			var debugArt:* = _ce.state.view.getArt(this);
			if(debugArt && debugArt.content)
				return debugArt.content.debugView as IDebugView;
			else
				return null;
		}
		
		public function get realDebugView():* {
			return _realDebugView;
		}
		
		public function get view():* {
			return _view;
		}
		
		public function set view(value:*):void {
			_view = value;
		}
		
		public function get x():Number {
			return 0;
		}

		public function get y():Number {
			return 0;
		}
		
		public function get z():Number {
			return 0;
		}
		
		public function get width():Number {
			return 0;
		}
		
		public function get height():Number {
			return 0;
		}
		
		public function get depth():Number {
			return 0;
		}
		
		public function get velocity():Array {
			return null;
		}

		public function get parallaxX():Number {
			return 1;
		}
		
		public function get parallaxY():Number {
			return 1;
		}

		public function get rotation():Number {
			return 0;
		}

		public function get group():uint {
			return _group;
		}

		public function set group(value:uint):void {
			_group = value;
		}

		public function get visible():Boolean {
			return _visible;
		}

		public function set visible(value:Boolean):void {
			_visible = value;
		}
		
		public function get touchable():Boolean {
			return _touchable;
		}

		public function set touchable(value:Boolean):void {
			_touchable = value;
		}
		
		public function get animation():String {
			return "";
		}

		public function get inverted():Boolean {
			return false;
		}

		public function get offsetX():Number {
			return 0;
		}

		public function get offsetY():Number {
			return 0;
		}

		public function get registration():String {
			return "topLeft";
		}
		
		public function handleArtReady(citrusArt:ICitrusArt):void {
		}
		
		public function handleArtChanged(citrusArt:ICitrusArt):void {
		}
	}
}
