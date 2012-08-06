package com.citrusengine.system.components.box2d.hero {

	import Box2DAS.Dynamics.b2Fixture;

	import com.citrusengine.system.components.ViewComponent;

	/**
	 * @author Aymeric
	 */
	public class HeroViewComponent extends ViewComponent {
		
		public var groundContacts:Array = [];//Used to determine if he's on ground or not.
		
		protected var _physicsComponent:HeroPhysicsComponent;
		protected var _moveComponent:HeroMoveComponent;

		public function HeroViewComponent(name:String, params:Object = null) {
			
			super(name, params);
		}
			
		override public function initialize():void {
			
			super.initialize();
			
			_physicsComponent = entity.components["physics"];
			_moveComponent = entity.components["move"];
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			var prevAnimation:String = _animation;
			
			if (_physicsComponent && _moveComponent) {
				
				if (!_moveComponent.onGround) {
					_animation = "jump";
				} else {
					var walkingSpeed:Number = getWalkingSpeed();
					if (walkingSpeed < -_moveComponent.acceleration) {
						_inverted = true;
						_animation = "walk";
					} else if (walkingSpeed > _moveComponent.acceleration) {
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
