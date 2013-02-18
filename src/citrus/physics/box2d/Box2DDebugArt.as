package citrus.physics.box2d {

	import Box2D.Dynamics.b2DebugDraw;

	import citrus.core.CitrusEngine;
	import citrus.physics.IDebugView;

	import flash.display.Sprite;
	
	/**
	 * This displays Box2D's debug graphics. It does so properly through Citrus Engine's view manager. Box2D by default
	 * sets visible to false with an alpha of 0.5, so you'll need to set the Box2D object's visible property to true in order to see the debug graphics. 
	 */	
	public class Box2DDebugArt extends Sprite implements IDebugView
	{
		private var _box2D:Box2D;
		private var _debugDrawer:b2DebugDraw;
		
		public function Box2DDebugArt()
		{
			_box2D = CitrusEngine.getInstance().state.getFirstObjectByType(Box2D) as Box2D;
			
			_debugDrawer = new b2DebugDraw();
			
			_debugDrawer.SetSprite(this);
			_debugDrawer.SetDrawScale(_box2D.scale);
			_debugDrawer.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
			
			_box2D.world.SetDebugDraw(_debugDrawer);
			
			this.alpha = 0.5;
		}
		
		public function update():void
		{
			if (_box2D.visible)
				_box2D.world.DrawDebugData();
		}
		
		public function debugMode(flags:uint):void {
			_debugDrawer.SetFlags(flags);
		}
	}
}