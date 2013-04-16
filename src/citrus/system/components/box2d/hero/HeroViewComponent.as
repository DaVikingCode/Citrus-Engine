package citrus.system.components.box2d.hero {

	import Box2D.Dynamics.b2Fixture;

	import citrus.system.components.ViewComponent;

	/**
	 * The Box2D Hero view component. It manages the hero's view based on its physics component and depending its movement.
	 */
	public class HeroViewComponent extends ViewComponent {
		
		public var groundContacts:Array = [];//Used to determine if he's on ground or not.
		
		protected var _physicsComponent:HeroPhysicsComponent;
		protected var _movementComponent:HeroMovementComponent;

		public function HeroViewComponent(name:String, params:Object = null) {
			
			super(name, params);
		}
			
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize();
			
			_physicsComponent = entity.lookupComponentByName("physics") as HeroPhysicsComponent;
			_movementComponent = entity.lookupComponentByName("move") as HeroMovementComponent;
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			var prevAnimation:String = _animation;
			
			if (_physicsComponent && _movementComponent) {
				
				if (_movementComponent.isHurt)
					_animation = "hurt";
				else if (!_movementComponent.onGround)
					_animation = "jump";
				else if (_movementComponent.ducking)
					_animation = "duck";
				else {
					
					var walkingSpeed:Number = getWalkingSpeed();
					
					if (walkingSpeed < -_movementComponent.acceleration) {
						_inverted = true;
						_animation = "walk";
					} else if (walkingSpeed > _movementComponent.acceleration) {
						_inverted = false;
						_animation = "walk";
					} else {
						_animation = "idle";
					}
				}				
			}
			
			if (prevAnimation != _animation)
				onAnimationChange.dispatch();
		}
		
		/**
		 * Returns the absolute walking speed, taking moving platforms into account.
		 * Isn't super performance-light, so use sparingly.
		 */
		public function getWalkingSpeed():Number {
			
			var groundVelocityX:Number = 0;
			for each (var groundContact:b2Fixture in groundContacts) {
				groundVelocityX += groundContact.GetBody().GetLinearVelocity().x;
			}
			
			return _physicsComponent.body.GetLinearVelocity().x - groundVelocityX;
		}
	}
}
