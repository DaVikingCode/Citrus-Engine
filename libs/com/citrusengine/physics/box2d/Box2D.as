package com.citrusengine.physics.box2d {

	import Box2DAS.Common.V2;
	import Box2DAS.Common.b2Base;
	import Box2DAS.Dynamics.b2World;
	import com.citrusengine.physics.APhysicsEngine;
	import com.citrusengine.physics.PhysicsCollisionCategories;
	import com.citrusengine.view.ISpriteView;

	
	/**
	 * This is a simple wrapper class that allows you to add a Box2D Alchemy world to your game's state.
	 * Add an instance of this class to your State before you create any phyiscs bodies. It will need to 
	 * exist first, or your physics bodies will throw an error when they try to create themselves.
	 */	
	public class Box2D extends APhysicsEngine implements ISpriteView
	{	
		private var _scale:Number = 30;
		private var _world:b2World;
		private var _gravity:V2 = new V2(0, 15);
		
		/**
		 * Creates and initializes a Box2D world. 
		 */		
		public function Box2D(name:String, params:Object = null)
		{
			if (params && params.view == undefined)
				params.view = Box2DDebugArt;
			else if (params == null)
				params = {view:Box2DDebugArt};
			
			super(name, params);
		}
			
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize();
			
			_realDebugView = _view;
			
			_world = new b2World(_gravity);
			b2Base.initialize();
			
			//Set up collision categories
			PhysicsCollisionCategories.Add("GoodGuys");
			PhysicsCollisionCategories.Add("BadGuys");
			PhysicsCollisionCategories.Add("Level");
			PhysicsCollisionCategories.Add("Items");
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
			
			if (_world)
				_world.SetGravity(_gravity);
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			// 0.05 = 1 / 20
			_world.Step(0.05, 8, 8);
		}
	}
}