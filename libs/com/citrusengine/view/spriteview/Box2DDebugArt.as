package com.citrusengine.view.spriteview
{
	import Box2DAS.Dynamics.b2DebugDraw;
	
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.view.spriteview.SpriteArt;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * This displays Box2D's debug graphics. It does so properly through Citrus Engine's view manager. Box2D by default
	 * sets visible to false, so you'll need to set the Box2D object's visible property to true in order to see the debug graphics. 
	 */	
	public class Box2DDebugArt extends MovieClip
	{
		private var _box2D:Box2D;
		private var _debugDrawer:b2DebugDraw;
		
		public function Box2DDebugArt()
		{
			addEventListener(Event.ADDED, handleAddedToParent);
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			addEventListener(Event.REMOVED, destroy);
		}
		
		private function handleAddedToParent(e:Event):void 
		{
			removeEventListener(Event.ADDED, handleAddedToParent);
			
			if (parent is SpriteArt)
				_box2D = SpriteArt(parent).citrusObject as Box2D;
			else
				_box2D = CitrusEngine.getInstance().state.getFirstObjectByType(Box2D) as Box2D;
			
			_debugDrawer = new b2DebugDraw();
			addChild(_debugDrawer);
			_debugDrawer.world = _box2D.world;
			_debugDrawer.scale = _box2D.scale;
		}
		
		private function destroy(e:Event):void
		{
			removeEventListener(Event.ADDED, handleAddedToParent);
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			removeEventListener(Event.REMOVED, destroy);
		}
		
		private function handleEnterFrame(e:Event):void
		{
			_debugDrawer.Draw();
		}
	}
}