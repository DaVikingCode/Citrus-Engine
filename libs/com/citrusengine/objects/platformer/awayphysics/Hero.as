package com.citrusengine.objects.platformer.awayphysics {

	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;

	import com.citrusengine.objects.AwayPhysicsObject;
	import com.citrusengine.physics.PhysicsCollisionCategories;

	import org.osflash.signals.Signal;

	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	/**
	 * @author Aymeric
	 */
	public class Hero extends AwayPhysicsObject implements IPlatformer {

		public var stepHeight:Number = 0.1;
		
		[Inspectable(defaultValue="0.1")]
		public var speed:Number = 0.1;
		
		[Inspectable(defaultValue="3")]
		public var speedRotation:Number = 3;

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
			
			_x = _character.ghostObject.x;
			_y = _character.ghostObject.y;
			_z = _character.ghostObject.z;
			
			//_body.rotation = _character.ghostObject.rotation;
			
			var moveKeyPressed:Boolean = false;
			
			if (_ce.input.isDown(Keyboard.RIGHT)) {
				_chRotation += speedRotation;
				character.ghostObject.rotation = new Vector3D(0, _chRotation, 0);
			}

			if (_ce.input.isDown(Keyboard.LEFT)) {
				_chRotation -= speedRotation;
				character.ghostObject.rotation = new Vector3D(0, _chRotation, 0);
			}

			if (_ce.input.isDown(Keyboard.UP)) {
				_walkDirection = _character.ghostObject.front;
				_walkDirection.scaleBy(speed);
				_character.setWalkDirection(_walkDirection);
				moveKeyPressed = true;
			}
			
			if (_ce.input.isDown(Keyboard.DOWN)) {
				_walkDirection = _character.ghostObject.front;
				_walkDirection.scaleBy(-speed);
				_character.setWalkDirection(_walkDirection);
				moveKeyPressed = true;
			}
			
			if (_ce.input.isDown(Keyboard.SPACE)) {
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

		public function get character():AWPKinematicCharacterController {
			return _character;
		}

		public function get ghostObject():AWPGhostObject {
			return _ghostObject;
		}

	}
}
