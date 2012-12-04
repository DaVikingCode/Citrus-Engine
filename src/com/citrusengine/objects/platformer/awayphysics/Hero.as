package com.citrusengine.objects.platformer.awayphysics {

	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.events.AWPEvent;

	import com.citrusengine.objects.AwayPhysicsObject;
	import com.citrusengine.physics.PhysicsCollisionCategories;

	import org.osflash.signals.Signal;

	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	/**
	 * @author Aymeric
	 */
	public class Hero extends AwayPhysicsObject {

		public var stepHeight:Number = 0.1;

		[Inspectable(defaultValue="0.1")]
		public var speed:Number = 0.1;

		[Inspectable(defaultValue="3")]
		public var speedRotation:Number = 3;
		
		/**
		 * Defines which input Channel to listen to.
		 */
		[Inspectable(defaultValue = "0")]
		public var inputChannel:uint = 0;

		// events
		/**
		 * Dispatched whenever the hero jumps. 
		 */
		public var onJump:Signal;

		/**
		 * Dispatched whenever the hero gives damage to an enemy. 
		 */
		public var onGiveDamage:Signal;

		/**
		 * Dispatched whenever the hero takes damage from an enemy. 
		 */
		public var onTakeDamage:Signal;

		/**
		 * Dispatched whenever the hero's animation changes. 
		 */
		public var onAnimationChange:Signal;

		protected var _character:AWPKinematicCharacterController;
		protected var _ghostObject:AWPGhostObject;
		protected var _walkDirection:Vector3D = new Vector3D();

		protected var _chRotation:Number = 0;

		public function Hero(name:String, params:Object = null) {

			super(name, params);

			onJump = new Signal();
			onGiveDamage = new Signal();
			onTakeDamage = new Signal();
			onAnimationChange = new Signal();
		}

		override public function destroy():void {

			onJump.removeAll();
			onGiveDamage.removeAll();
			onTakeDamage.removeAll();
			onAnimationChange.removeAll();

			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);

			_x = _ghostObject.x;
			_y = _ghostObject.y;
			_z = _ghostObject.z;

			var moveKeyPressed:Boolean = false;

			if (_ce.input.isDoing("right",inputChannel)) {
				_chRotation += speedRotation;
				character.ghostObject.rotation = new Vector3D(0, _chRotation, 0);
			}

			if (_ce.input.isDoing("left",inputChannel)) {
				_chRotation -= speedRotation;
				character.ghostObject.rotation = new Vector3D(0, _chRotation, 0);
			}

			if (_ce.input.isDoing("up",inputChannel)) {
				_walkDirection = _ghostObject.front;
				_walkDirection.scaleBy(speed);
				_character.setWalkDirection(_walkDirection);
				moveKeyPressed = true;
				// _ghostObject.position = _ghostObject.position.add(_ghostObject.worldTransform.rotationWithMatrix.transformVector(new Vector3D(0, 0, 10)));
			}

			if (_ce.input.isDoing("down",inputChannel)) {
				_walkDirection = _ghostObject.front;
				_walkDirection.scaleBy(-speed);
				_character.setWalkDirection(_walkDirection);
				moveKeyPressed = true;
			}

			if (_ce.input.isDoing("jump",inputChannel)) {
				_character.jump();
			}

			if (!moveKeyPressed) {
				_walkDirection.scaleBy(0);
				character.setWalkDirection(_walkDirection);
			}
		}

		override protected function defineBody():void {

			_ghostObject = new AWPGhostObject(_shape);
			_character = new AWPKinematicCharacterController(_ghostObject, stepHeight);
		}

		override protected function createBody():void {

			_character.warp(new Vector3D(_x, _y, _z));

			_awayPhysics.world.addCharacter(_character, PhysicsCollisionCategories.Get("GoodGuys"), PhysicsCollisionCategories.GetAll());
		}

		override protected function createConstraint():void {

			_ghostObject.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT;
			_ghostObject.addEventListener(AWPEvent.COLLISION_ADDED, characterCollisionAdded);
		}

		private function characterCollisionAdded(event:AWPEvent):void {
			
			if (!(event.collisionObject.collisionFlags & AWPCollisionFlags.CF_STATIC_OBJECT)) {
				
				var body:AWPRigidBody = AWPRigidBody(event.collisionObject);
				var force:Vector3D = event.manifoldPoint.normalWorldOnB.clone();
				force.scaleBy(-30);
				body.applyForce(force, event.manifoldPoint.localPointB);
			}
		}
			
		override public function getBody():* {
			return _ghostObject;
		}

		public function get character():AWPKinematicCharacterController {
			return _character;
		}

	}
}
