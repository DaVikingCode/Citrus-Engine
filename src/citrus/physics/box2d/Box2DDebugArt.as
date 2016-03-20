package citrus.physics.box2d {

	import Box2D.Dynamics.b2DebugDraw;
	import citrus.core.CitrusEngine;
	import citrus.physics.IDebugView;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	/**
	 * This displays Box2D's debug graphics. It does so properly through Citrus Engine's view manager. Box2D by default
	 * sets visible to false with an alpha of 0.5, so you'll need to set the Box2D object's visible property to true in order to see the debug graphics. 
	 */
	public class Box2DDebugArt implements IDebugView
	{
		private var _box2D:Box2D;
		private var _debugDrawer:b2DebugDraw;
		private var _sprite:Sprite;
		private var _ce:CitrusEngine;
		
		public function Box2DDebugArt()
		{
			_ce = CitrusEngine.getInstance();
			
			_box2D = _ce.state.getFirstObjectByType(Box2D) as Box2D;
			
			_debugDrawer = new b2DebugDraw();
			
			_sprite = new Sprite();
			_sprite.name = "debug view";
			
			_debugDrawer.SetSprite(_sprite);
			_debugDrawer.SetDrawScale(_box2D.scale);
			_debugDrawer.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
			
			_box2D.world.SetDebugDraw(_debugDrawer);
			
			_sprite.alpha = 0.5;
		}
		
		public function initialize():void
		{
			_ce.stage.addChild(_sprite);
		}
		
		public function update():void
		{
			if (_box2D.visible)
				_box2D.world.DrawDebugData();
		}
		
		public function destroy():void
		{
			_ce.stage.removeChild(_sprite);
			_debugDrawer = null;
			_box2D = null;
		}
		
		public function debugMode(flags:uint):void {
			_debugDrawer.SetFlags(flags);
		}
		
		public function get debugDrawer():* {
			return _debugDrawer;
		}
		
		public function set transformMatrix(m:Matrix):void
		{
			_sprite.transform.matrix = m;
		}
		
		public function get transformMatrix():Matrix
		{
			return _sprite.transform.matrix;
		}
		
		public function get visibility():Boolean
		{
			return _sprite.visible;
		}
		
		public function set visibility(val:Boolean):void
		{
			_sprite.visible = val;
		}
		
	}
}