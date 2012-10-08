package com.citrusengine.physics {

	import awayphysics.dynamics.AWPDynamicsWorld;

	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.view.ISpriteView;
	import com.citrusengine.view.away3dview.AwayPhysicsDebugArt;

	import flash.geom.Vector3D;

	/**
	 * @author Aymeric
	 */
	public class AwayPhysics extends CitrusObject implements ISpriteView {
		
		private var _visible:Boolean = false;
		private var _world:AWPDynamicsWorld;
		private var _gravity:Vector3D = new Vector3D(0, -10, 0);
		private var _group:Number = 1;
		private var _view:* = AwayPhysicsDebugArt;

		public function AwayPhysics(name:String, params:Object = null) {
			
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
		
		public function get x():Number {
			return 0;
		}

		public function get y():Number {
			return 0;
		}
		
		public function get z():Number {
			return 0;
		}
		
		public function get width():Number {
			return 0;
		}
		
		public function get height():Number {
			return 0;
		}
		
		public function get depth():Number {
			return 0;
		}

		public function get parallax():Number {
			return 1;
		}

		public function get rotation():Number {
			return 0;
		}

		public function get group():Number {
			return _group;
		}

		public function set group(value:Number):void {
			_group = value;
		}

		public function get visible():Boolean {
			return _visible;
		}

		public function set visible(value:Boolean):void {
			_visible = value;
		}

		public function get animation():String {
			return "";
		}

		public function get view():* {
			return _view;
		}

		public function set view(value:*):void {
			_view = value;
		}

		public function get inverted():Boolean {
			return false;
		}

		public function get offsetX():Number {
			return 0;
		}

		public function get offsetY():Number {
			return 0;
		}

		public function get registration():String {
			return "topLeft";
		}

	}
}
