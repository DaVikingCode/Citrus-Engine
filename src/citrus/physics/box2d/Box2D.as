package citrus.physics.box2d {

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import citrus.physics.APhysicsEngine;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.view.ISpriteView;
	
	/**
	 * This is a simple wrapper class that allows you to add a Box2D world to your game's state.
	 * Add an instance of this class to your State before you create any physics bodies. It will need to 
	 * exist first, or your physics bodies will throw an error when they try to create themselves.
	 */	
	public class Box2D extends APhysicsEngine implements ISpriteView
	{	
		/**
		 * timeStep the amount of time to simulate, this should not vary.
		 */
		public var timeStep:Number = 1 / 20;
		
		/**
		 * velocityIterations for the velocity constraint solver.
		 */
		public var velocityIterations:uint = 8;
		
		/**
		 *positionIterations for the position constraint solver.
		 */
		public var positionIterations:uint = 8;
		
		private var _scale:Number = 30;
		private var _world:b2World;
		private var _gravity:b2Vec2 = new b2Vec2(0, 15);
		private var _contactListener:Box2DContactListener;
		
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
			
			_world = new b2World(_gravity, true);
			_contactListener = new Box2DContactListener();
			_world.SetContactListener(_contactListener);
			
			//Set up collision categories
			PhysicsCollisionCategories.Add("GoodGuys");
			PhysicsCollisionCategories.Add("BadGuys");
			PhysicsCollisionCategories.Add("Level");
			PhysicsCollisionCategories.Add("Items");
		}
		
		override public function destroy():void
		{	
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
		 * values by 30, your objects will look very small and will appear to move very slowly, if at all.
		 * This is a reference to the scale number by which you must multiply your values to properly display physics objects. 
		 */		
		public function get scale():Number
		{
			return _scale;
		}
		
		/**
		 * Change the gravity of the world.
		 */
		public function get gravity():b2Vec2 {
			return _gravity;
		}
		
		public function set gravity(value:b2Vec2):void {
			_gravity = value;
			
			if (_world)
				_world.SetGravity(_gravity);
		}
		
		/**
		 * This is where the time step of the physics world occurs.
		 */
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			_world.Step(timeStep, velocityIterations, positionIterations);
			_world.ClearForces();
		}
	}
}