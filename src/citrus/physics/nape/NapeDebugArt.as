package citrus.physics.nape {

	import citrus.core.CitrusEngine;
	import citrus.datastructures.BitFlag;
	import citrus.physics.IDebugView;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import nape.util.ShapeDebug;

	/**
	 * This displays Nape's debug graphics. It does so properly through Citrus Engine's view manager. Nape by default
	 * sets visible to false with an alpha of 0.8, so you'll need to set the Nape object's visible property to true in order to see the debug graphics. 
	 */
	public class NapeDebugArt implements IDebugView {
		
		private var _nape:Nape;
		private var _debugDrawer:ShapeDebug;
		private var _ce:CitrusEngine;
		
		/**
		 * NapDebugArt flags.
		 * after modifying them, call applyFlags() to set the ShapeDebug's boolean values.
		 */
		public var flags:BitFlag;
		
		public static const draw_Bodies:uint = 1 << 0;
		public static const draw_BodyDetail:uint = 1 << 1;
		public static const draw_CollisionArbiters:uint = 1 << 2;
		public static const draw_Constraints:uint = 1 << 3;
		public static const draw_FluidArbiters:uint = 1 << 4;
		public static const draw_SensorArbiters:uint = 1 << 5;
		public static const draw_ShapeAngleIndicators:uint = 1 << 6;
		public static const draw_ShapeDetail:uint = 1 << 7;

		public function NapeDebugArt() {
			
			_ce = CitrusEngine.getInstance();
			
			flags = new BitFlag(NapeDebugArt);
			
			_nape = _ce.state.getFirstObjectByType(Nape) as Nape;
			
			_debugDrawer = new ShapeDebug(_ce.screenWidth, _ce.screenHeight);
			
			_debugDrawer.display.name = "debug view";
			_debugDrawer.display.alpha = 0.8;
			
			readFlags();
			
			_ce.onStageResize.add(resize);
		}
		
		protected function applyFlags():void
		{
			_debugDrawer.drawBodies = flags.hasFlag(draw_Bodies);
			_debugDrawer.drawBodyDetail = flags.hasFlag(draw_BodyDetail);
			_debugDrawer.drawCollisionArbiters = flags.hasFlag(draw_BodyDetail);
			_debugDrawer.drawConstraints = flags.hasFlag(draw_Constraints);
			_debugDrawer.drawFluidArbiters = flags.hasFlag(draw_FluidArbiters);
			_debugDrawer.drawSensorArbiters = flags.hasFlag(draw_SensorArbiters);
			_debugDrawer.drawShapeAngleIndicators = flags.hasFlag(draw_ShapeAngleIndicators);
			_debugDrawer.drawShapeDetail = flags.hasFlag(draw_ShapeDetail);
		}
		
		protected function readFlags():void
		{
			flags.removeAllFlags();
			if(_debugDrawer.drawBodies) flags.addFlag(draw_Bodies);
			if(_debugDrawer.drawBodyDetail) flags.addFlag(draw_BodyDetail);
			if(_debugDrawer.drawCollisionArbiters) flags.addFlag(draw_BodyDetail);
			if(_debugDrawer.drawConstraints) flags.addFlag(draw_Constraints);
			if(_debugDrawer.drawFluidArbiters) flags.addFlag(draw_FluidArbiters);
			if(_debugDrawer.drawSensorArbiters) flags.addFlag(draw_SensorArbiters);
			if(_debugDrawer.drawShapeAngleIndicators) flags.addFlag(draw_ShapeAngleIndicators);
			if(_debugDrawer.drawShapeDetail) flags.addFlag(draw_ShapeDetail);
		}
		
		public function initialize():void
		{
			_ce.stage.addChild(_debugDrawer.display);
		}
		
		public function resize(w:Number, h:Number):void
		{
			if (!_nape.visible)
				return;
				
			readFlags();
			_ce.stage.removeChild(_debugDrawer.display);
			_debugDrawer.flush();
			_debugDrawer = new ShapeDebug(_ce.screenWidth, _ce.screenHeight);
			_debugDrawer.display.name = "debug view";
			_debugDrawer.display.alpha = 0.8;
			applyFlags();
			_ce.stage.addChild(_debugDrawer.display);
		}
		
		public function update():void
		{
			if (_nape.visible) {
				
				_debugDrawer.clear();
				_debugDrawer.draw(_nape.space);
				_debugDrawer.flush();
			}
		}
		
		public function destroy():void
		{
			flags.destroy();
			_ce.onStageResize.remove(resize);
			_ce.stage.removeChild(_debugDrawer.display);
		}
		
		public function debugMode(flags:uint):void {
			this.flags.setFlags(flags);
			applyFlags();
		}
		
		public function get debugDrawer():* {
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
