package com.citrusengine.physics.nape {

	import nape.geom.Vec2;
	import nape.space.Space;

	import com.citrusengine.physics.APhysicsEngine;
	import com.citrusengine.physics.PhysicsCollisionCategories;
	import com.citrusengine.view.ISpriteView;

	/**
	 * This is a simple wrapper class that allows you to add a Nape space to your game's state.
	 * Add an instance of this class to your State before you create any phyiscs bodies. It will need to 
	 * exist first, or your physics bodies will throw an error when they try to create themselves.
	 */
	public class Nape extends APhysicsEngine implements ISpriteView {
		
		private var _space:Space;
		private var _gravity:Vec2 = new Vec2(0, 150);
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
			_space.clear();
			
			super.destroy();
		}

		/**
		 * Gets a reference to the actual Nape space object. 
		 */
		public function get space():Space {
			return _space;
		}
		
		public function get gravity():Vec2 {
			return _gravity;
		}
		
		public function set gravity(value:Vec2):void {
			_gravity = value;
			
			if (_space)
				_space.gravity = _gravity;
		}
		
		public function get contactListener():NapeContactListener {
			return _contactListener;
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			// 0.05 = 1 / 20
			_space.step(0.05, 8, 8);
		}
	}
}
