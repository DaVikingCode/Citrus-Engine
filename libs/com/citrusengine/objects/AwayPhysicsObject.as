package com.citrusengine.objects {

	import away3d.containers.ObjectContainer3D;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPCollisionShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.dynamics.AWPRigidBody;
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.physics.PhysicsCollisionCategories;
	import com.citrusengine.physics.awayphysics.AwayPhysics;
	import com.citrusengine.view.ISpriteView;
	import flash.geom.Vector3D;




	/**
	 * @author Aymeric
	 */
	public class AwayPhysicsObject extends APhysicsObject implements ISpriteView {
		
		protected var _awayPhysics:AwayPhysics;
		protected var _body:AWPRigidBody;
		protected var _shape:AWPCollisionShape;
		protected var _mass:Number = 1;
		
		protected var _width:Number = 30;
		protected var _height:Number = 30;
		protected var _depth:Number = 30;
		protected var _view:* = ObjectContainer3D;
		
		private var _offsetZ:Number = 0;

		public function AwayPhysicsObject(name:String, params:Object = null) {

			_ce = CitrusEngine.getInstance();
			_awayPhysics = _ce.state.getFirstObjectByType(AwayPhysics) as AwayPhysics;

			super(name, params);
		}

		override public function initialize(poolObjectParams:Object = null):void {

			super.initialize(poolObjectParams);

			if (!_awayPhysics) {
				throw new Error("Cannot create a AwayPhysicsObject when a AwayPhysics object has not been added to the state.");
				return;
			}

			// Override these to customize your AwayPhysics initialization. Things must be done in this order.
			createShape();
			defineBody();
			createBody();
			createConstraint();
		}

		override public function destroy():void {

			_body.dispose();
			
			super.destroy();
		}

		/**
		 * You should override this method to extend the functionality of your physics object. This is where you will 
		 * want to do any velocity/force logic. 
		 */
		override public function update(timeDelta:Number):void {
		}

		protected function createShape():void {
			
			if (_radius != 0)
				_shape = new AWPSphereShape(_radius);
			else
				_shape = new AWPBoxShape(_width, _height, _depth);
		}

		protected function defineBody():void {

			_body = new AWPRigidBody(_shape, null, _mass);
		}

		protected function createBody():void {
			
			_body.position = new Vector3D(_x, _y, _z);
			
			_awayPhysics.world.addRigidBodyWithGroup(_body, PhysicsCollisionCategories.Get("Level"), PhysicsCollisionCategories.GetAll());
		}
		
		protected function createConstraint():void {
		}

		public function get x():Number {

			if (_body)
				return _body.position.x;
			else
				return _x;
		}

		public function set x(value:Number):void {

			_x = value;

			if (_body) {
				var pos:Vector3D = _body.position;
				pos.x = _x;
				_body.position = pos;
			}
		}

		public function get y():Number {

			if (_body)
				return _body.position.y;
			else
				return _y;
		}

		public function set y(value:Number):void {

			_y = value;
			
			if (_body) {
				var pos:Vector3D = _body.position;
				pos.y = _y;
				_body.position = pos;
			}
		}

		public function get z():Number {

			if (_body)
				return _body.position.z;
			else
				return _z;
		}

		public function set z(value:Number):void {

			_z = value;

			if (_body) {
				var pos:Vector3D = _body.position;
				pos.z = _z;
				_body.position = pos;
			}
		}

		public function get rotation():Number {

			/*if (_body)
			return _body.rotation * 180 / Math.PI;
			else
			return _rotation * 180 / Math.PI;
				
			 */
			return 0;
		}

		public function set rotation(value:Number):void {
			
			/*_rotation = value * Math.PI / 180;
			
			if (_body)
			_body.rotate(new Vec2(_x, _y), _rotation);*/
		}

		public function get view():* {
			return _view;
		}

		[Inspectable(defaultValue="",format="File",type="String")]
		public function set view(value:*):void {
			_view = value;
		}
		
		public function get offsetZ():Number {
			return _offsetZ;
		}

		[Inspectable(defaultValue="0")]
		public function set offsetZ(value:Number):void {
			_offsetZ = value;
		}

		/**
		 * This can only be set in the constructor parameters. 
		 */
		public function get width():Number {
			return _width;
		}

		public function set width(value:Number):void {
			
			_width = value;

			if (_initialized) {
				trace("Warning: You cannot set " + this + " width after it has been created. Please set it in the constructor.");
			}
		}

		/**
		 * This can only be set in the constructor parameters. 
		 */
		public function get height():Number {
			return _height;
		}

		public function set height(value:Number):void {
			
			_height = value;

			if (_initialized) {
				trace("Warning: You cannot set " + this + " height after it has been created. Please set it in the constructor.");
			}
		}
		
		public function get depth():Number {
			return _depth;
		}

		public function set depth(value:Number):void {
			
			_depth = value;

			if (_initialized) {
				trace("Warning: You cannot set " + this + " depth after it has been created. Please set it in the constructor.");
			}
		}
		
		public function get mass():Number {
			return _mass;
		}
		
		public function set mass(value:Number):void {
			_mass = value;
		}

		/**
		 * This can only be set in the constructor parameters. 
		 */
		public function get radius():Number {
			return _radius;
		}

		/**
		 * The object has a radius or a width & height. It can't have both.
		 */
		[Inspectable(defaultValue="0")]
		public function set radius(value:Number):void {
			
			_radius = value;

			if (_initialized) {
				trace("Warning: You cannot set " + this + " radius after it has been created. Please set it in the constructor.");
			}
		}
		
		/**
		 * A direction reference to the AwayPhysics body associated with this object.
		 */
		public function get body():AWPRigidBody {
			return _body;
		}
		
		override public function getBody():* {
			return _body;
		}

	}
}
