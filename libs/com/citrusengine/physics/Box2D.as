package com.citrusengine.physics {

	import Box2DAS.Common.V2;
	import Box2DAS.Common.b2Base;
	import Box2DAS.Dynamics.b2World;

	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.view.ISpriteView;
	import com.citrusengine.view.spriteview.Box2DDebugArt;
	
	/**
	 * This is a simple wrapper class that allows you to add a Box2D Alchemy world to your game's state.
	 * Add an instance of this class to your State before you create any phyiscs bodies. It will need to 
	 * exist first, or your physics bodies will throw an error when they try to create themselves.
	 */	
	public class Box2D extends CitrusObject implements ISpriteView
	{	
		private var _visible:Boolean = false;
		private var _scale:Number = 30;
		private var _world:b2World;
		private var _gravity:V2 = new V2(0, 15);
		private var _group:Number = 1;
		private var _view:* = Box2DDebugArt;
		
		public static function Make(name:String, visible:Boolean):Box2D
		{
			return new Box2D(name, { visible: visible } );
		}
		
		/**
		 * Creates and initializes a Box2D world. 
		 */		
		public function Box2D(name:String, params:Object = null)
		{
			super(name, params);
		}
			
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize();
			
			_world = new b2World(_gravity);
			b2Base.initialize();
			
			//Set up collision categories
			Box2DCollisionCategories.Add("GoodGuys");
			Box2DCollisionCategories.Add("BadGuys");
			Box2DCollisionCategories.Add("Level");
			Box2DCollisionCategories.Add("Items");
		}
		
		override public function destroy():void
		{
			_world.destroy();
			super.destroy();
		}
		
		/**
		 * Gets a reference to the actual Box2D world object. 
		 */		
		public function get world():b2World
		{
			return _world;
		}
		
		/**
		 * This is hard to grasp, but Box2D does not use pixels for its physics values. Cutely, it uses meters
		 * and forces us to convert those meter values to pixels by multiplying by 30. If you don't multiple Box2D
		 * values by 30, your objecs will look very small and will appear to move very slowly, if at all.
		 * This is a reference to the scale number by which you must multiply your values to properly display physics objects. 
		 */		
		public function get scale():Number
		{
			return _scale;
		}
		
		public function get gravity():V2 {
			return _gravity;
		}
		
		public function set gravity(value:V2):void {
			_gravity = value;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			// 0.05 = 1 / 20
			_world.Step(0.05, 8, 8);
		}
		
		public function get x():Number
		{
			return 0;
		}
		
		public function get y():Number
		{
			return 0;
		}
		
		public function get parallax():Number
		{
			return 1;
		}
		
		public function get rotation():Number
		{
			return 0;
		}
		
		public function get group():Number
		{
			return _group;
		}
		
		public function set group(value:Number):void
		{
			_group = value;
		}
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
		}
		
		public function get animation():String
		{
			return "";
		}
		
		public function get view():*
		{
			return _view;
		}
		
		public function set view(value:*):void
		{
			_view = value;
		}
		
		public function get inverted():Boolean
		{
			return false;
		}
		
		public function get offsetX():Number
		{
			return 0;
		}
		
		public function get offsetY():Number
		{
			return 0;
		}
		
		public function get registration():String
		{
			return "topLeft";
		}
	}
}