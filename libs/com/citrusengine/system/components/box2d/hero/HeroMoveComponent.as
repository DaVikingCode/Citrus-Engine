package com.citrusengine.system.components.box2d.hero {

	import Box2DAS.Common.V2;

	import com.citrusengine.system.components.InputComponent;
	import com.citrusengine.system.components.box2d.MoveComponent;

	import org.osflash.signals.Signal;

	/**
	 * @author Aymeric
	 */
	public class HeroMoveComponent extends MoveComponent {
		
		//properties
		/**
		 * This is the rate at which the hero speeds up when you move him left and right. 
		 */
		public var acceleration:Number = 1;
		
		/**
		 * This is the fastest speed that the hero can move left or right. 
		 */
		public var maxVelocity:Number = 8;
		
		/**
		 * This is the initial velocity that the hero will move at when he jumps.
		 */
		public var jumpHeight:Number = 11;
		
		/**
		 * This is the amount of "float" that the hero has when the player holds the jump button while jumping. 
		 */
		public var jumpAcceleration:Number = 0.3;
		public var canDuck:Boolean = true;
		
		/**
		 * Dispatched whenever the hero jumps. 
		 */
		public var onJump:Signal;
		
		protected var _inputComponent:InputComponent;
		protected var _collisionComponent:HeroCollisionComponent;
		
		protected var _onGround:Boolean = false;
		protected var _controlsEnabled:Boolean = true;
		protected var _playerMovingHero:Boolean = false;
		protected var _ducking:Boolean = false;

		public function HeroMoveComponent(name:String, params:Object = null) {
			
			super(name, params);
			
			onJump = new Signal();
		}
			
		override public function initialize():void {
			
			super.initialize();
			
			_inputComponent = entity.components["input"];
			_collisionComponent = entity.components["collision"];
		}
			
		override public function destroy():void {
			
			onJump.removeAll();
			
			super.destroy();
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);

			if (controlsEnabled && _physicsComponent) {
				
				var moveKeyPressed:Boolean = false;
				
				_ducking = (_inputComponent.downKeyIsDown && _onGround && canDuck);
					
				if (_inputComponent.rightKeyIsDown && !_ducking) {
					_velocity = V2.add(_velocity, getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				if (_inputComponent.leftKeyIsDown && !_ducking) {					
					_velocity = V2.subtract(_velocity, getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				//If player just started moving the hero this tick.
				if (moveKeyPressed && !_playerMovingHero) {
					_playerMovingHero = true;
					(_physicsComponent as HeroPhysicsComponent).changeFixtureToZero(); //Take away friction so he can accelerate.
				}
				//Player just stopped moving the hero this tick.
				else if (!moveKeyPressed && _playerMovingHero) {
					_playerMovingHero = false;
					(_physicsComponent as HeroPhysicsComponent).changeFixtureToItsInitialValue(); //Add friction so that he stops running
				}
				
				if (_onGround && _inputComponent.spaceKeyJustPressed && !_ducking) {
					_velocity.y = -jumpHeight;
					onJump.dispatch();
				}
				
				if (_inputComponent.spaceKeyIsDown && !_onGround && _velocity.y < 0)
					_velocity.y -= jumpAcceleration;
				
				//Cap velocities
				if (_velocity.x > (maxVelocity))
					_velocity.x = maxVelocity;
				else if (_velocity.x < (-maxVelocity))
					_velocity.x = -maxVelocity;
				
				_physicsComponent.body.SetLinearVelocity(_velocity);
			}
		}
		
		protected function getSlopeBasedMoveAngle():V2 {
			return new V2(acceleration, 0).rotate(_collisionComponent.combinedGroundAngle);
		}
		
		/**
		 * Whether or not the player can move and jump with the hero. 
		 */	
		public function get controlsEnabled():Boolean
		{
			return _controlsEnabled;
		}
		
		public function set controlsEnabled(value:Boolean):void
		{
			_controlsEnabled = value;
			
			if (!_controlsEnabled)
				(_physicsComponent as HeroPhysicsComponent).changeFixtureToItsInitialValue();
		}
		
		/**
		 * Returns true if the hero is on the ground and can jump. 
		 */		
		public function get onGround():Boolean {
			return _onGround;
		}
		
		public function set onGround(value:Boolean):void {
			_onGround = value;
		}

		public function get ducking():Boolean {
			return _ducking;
		}
	}
}
