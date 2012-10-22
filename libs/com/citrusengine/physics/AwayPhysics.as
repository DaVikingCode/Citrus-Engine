package com.citrusengine.physics {

	import awayphysics.dynamics.AWPDynamicsWorld;

	import com.citrusengine.view.ISpriteView;
	import com.citrusengine.view.away3dview.AwayPhysicsDebugArt;

	import flash.geom.Vector3D;

	/**
	 * @author Aymeric
	 */
	public class AwayPhysics extends APhysicsEngine implements ISpriteView {
		
		private var _world:AWPDynamicsWorld;
		private var _gravity:Vector3D = new Vector3D(0, -10, 0);

		public function AwayPhysics(name:String, params:Object = null) {
			
			if (params && params.view == undefined)
				params.view = AwayPhysicsDebugArt;
			else if (params == null)
				params = {view:AwayPhysicsDebugArt};
			
			super(name, params);
		}
		
		override public function initialize(poolObjectParams:Object = null):void {
			
			_world = new AWPDynamicsWorld();
			_world.initWithDbvtBroadphase();
			_world.collisionCallbackOn = true;
			
			//Set up collision categories
			PhysicsCollisionCategories.Add("GoodGuys");
			PhysicsCollisionCategories.Add("BadGuys");
			PhysicsCollisionCategories.Add("Level");
			PhysicsCollisionCategories.Add("Items");
		}

		override public function destroy():void {
			
			_world.cleanWorld(true);
			_world.dispose();
			
			super.destroy();
		}
		
		/**
		 * Gets a reference to the actual AwayPhysics world object. 
		 */
		public function get world():AWPDynamicsWorld {
			return _world;
		}
		
		public function get gravity():Vector3D {
			return _gravity;
		}
		
		public function set gravity(value:Vector3D):void {
			_gravity = value;
			
			if (_world)
				_world.gravity = _gravity;
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			// 0.01667 = 1 / 60
			_world.step(0.01667, 1, 0.01667);
		}
	}
}
