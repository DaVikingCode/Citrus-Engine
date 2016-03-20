package citrus.physics.nape {

	import citrus.physics.APhysicsEngine;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.view.ISpriteView;

	import nape.geom.Vec2;
	import nape.space.Space;

	/**
	 * This is a simple wrapper class that allows you to add a Nape space to your game's state.
	 * Add an instance of this class to your State before you create any physics bodies. It will need to 
	 * exist first, or your physics bodies will throw an error when they try to create themselves.
	 */
	public class Nape extends APhysicsEngine implements ISpriteView {
		
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
		
		private var _space:Space;
		private var _gravity:Vec2 = new Vec2(0, 450);
		private var _contactListener:NapeContactListener;
		
		/**
		 * Creates and initializes a Nape space. 
		 */
		public function Nape(name:String, params:Object = null) {
			
			if (params && params.view == undefined)
				params.view = NapeDebugArt;
			else if (params == null)
				params = {view:NapeDebugArt};
			
			super(name, params);
		}
			
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize();
			
			_realDebugView = _view;
			
			_space = new Space(_gravity);
			_contactListener = new NapeContactListener(_space);
			
			//Set up collision categories
			PhysicsCollisionCategories.Add("GoodGuys");
			PhysicsCollisionCategories.Add("BadGuys");
			PhysicsCollisionCategories.Add("Level");
			PhysicsCollisionCategories.Add("Items");
		}

		override public function destroy():void {
			
			_contactListener.destroy();
			_contactListener = null;
			_space.clear();
			_space = null;
			_gravity.dispose();
			super.destroy();
		}

		/**
		 * Gets a reference to the actual Nape space object. 
		 */
		public function get space():Space {
			return _space;
		}
		
		/**
		 * Change the gravity of the space.
		 */
		public function get gravity():Vec2 {
			return _gravity;
		}
		
		public function set gravity(value:Vec2):void {
			_gravity = value;
			
			if (_space)
				_space.gravity = _gravity;
		}
		
		/**
		 * Return a ContactListener class where some InteractionListeners are already defined.
		 */
		public function get contactListener():NapeContactListener {
			return _contactListener;
		}

		/**
		 * This is where the time step of the physics world occurs.
		 */
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			_space.step(timeStep, velocityIterations, positionIterations);
		}
	}
}
