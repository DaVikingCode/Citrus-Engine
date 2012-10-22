package com.citrusengine.physics.box2d {

	import Box2DAS.Dynamics.b2DebugDraw;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.physics.IDebugView;

	import flash.display.Sprite;
	
	/**
	 * This displays Box2D's debug graphics. It does so properly through Citrus Engine's view manager. Box2D by default
	 * sets visible to false, so you'll need to set the Box2D object's visible property to true in order to see the debug graphics. 
	 */	
	public class Box2DDebugArt extends Sprite implements IDebugView
	{
		private var _box2D:Box2D;
		private var _debugDrawer:b2DebugDraw;
		
		public function Box2DDebugArt()
		{
			_box2D = CitrusEngine.getInstance().state.getFirstObjectByType(Box2D) as Box2D;
			
			_debugDrawer = new b2DebugDraw();
			addChild(_debugDrawer);
			_debugDrawer.world = _box2D.world;
			_debugDrawer.scale = _box2D.scale;
		}
		
		public function update():void
		{
			_debugDrawer.Draw();
		}
		
		public function debugMode(mode:uint):void {
			
		}
	}
}