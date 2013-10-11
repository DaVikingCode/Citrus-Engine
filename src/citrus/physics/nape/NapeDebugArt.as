package citrus.physics.nape {

	import citrus.core.CitrusEngine;
	import citrus.physics.IDebugView;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import nape.util.ShapeDebug;

	/**
	 * This displays Nape's debug graphics. It does so properly through Citrus Engine's view manager. Nape by default
	 * sets visible to false with an alpha of 0.8, so you'll need to set the Nape object's visible property to true in order to see the debug graphics. 
	 */
	public class NapeDebugArt extends Sprite implements IDebugView {
		
		private var _nape:Nape;
		private var _debugDrawer:ShapeDebug;
		private var _ce:CitrusEngine;

		public function NapeDebugArt() {
			
			_ce = CitrusEngine.getInstance();
			
			_nape = _ce.state.getFirstObjectByType(Nape) as Nape;
			_debugDrawer = new ShapeDebug(_ce.screenWidth, _ce.screenHeight);
			
			_ce.stage.addChild(_debugDrawer.display);
			_debugDrawer.display.alpha = 0.8;
			
			addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		public function update():void
		{
			if (_nape.visible) {
				
				_debugDrawer.clear();
				_debugDrawer.draw(_nape.space);
				_debugDrawer.flush();
			}
		}
		
		public function destroy(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			_ce.stage.removeChild(_debugDrawer.display);
		}
		
		public function debugMode(flags:uint):void {
		}
		
		/**
		 * nape's ShapeDebug instance.
		 * use it to set the properties of the debug drawer such as drawConstraints, drawCollisionArbiters etc...
		 * ShapeDebug properties : http://napephys.com/docs/types/nape/util/ShapeDebug.html#member_var_detail
		 */
		public function get debugDrawer():ShapeDebug {
			return _debugDrawer;
		}
		
		public function get transformMatrix():Matrix
		{
			return _debugDrawer.transform.toMatrix();
		}
		
		public function set transformMatrix(m:Matrix):void
		{
			//flash Matrix is Mat23 with b and c swapped
			_debugDrawer.transform.setAs(m.a, m.c, m.b, m.d, m.tx, m.ty);
		}
		
		public function get visibility():Boolean
		{
			return _debugDrawer.display.visible;
		}
		
		public function set visibility(val:Boolean):void
		{
			_debugDrawer.display.visible = val;
		}
	}
}
