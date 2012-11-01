package com.citrusengine.system.components.box2d.hero {

	import Box2D.Dynamics.b2Fixture;

	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.objects.platformer.box2d.Enemy;
	import com.citrusengine.system.components.box2d.CollisionComponent;

	/**
	 * The Box2D Hero collision component. We need to access informations of the hero view & movement & physics component.
	 */
	public class HeroCollisionComponent extends CollisionComponent {
		
		protected var _viewComponent:HeroViewComponent;
		protected var _movementComponent:HeroMovementComponent;
		protected var _physicsComponent:HeroPhysicsComponent;
		
		protected var _enemyClass:Class = Enemy;
		protected var _combinedGroundAngle:Number = 0;

		public function HeroCollisionComponent(name:String, params:Object = null) {
			
			super(name, params);
		}
			
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize();
			
			_viewComponent = entity.components["view"];
			_movementComponent = entity.components["move"];
			_physicsComponent = entity.components["physics"];
		}
			
		override public function destroy():void {
			
			super.destroy();
		}
		
		/*override public function handlePreSolve(e:ContactEvent):void {
			
			super.handlePreSolve(e);
			
			if (!_movementComponent.ducking)
				return;
				
			var other:Box2DPhysicsObject = e.other.GetBody().GetUserData() as Box2DPhysicsObject;
			
			var heroTop:Number = _physicsComponent.y;
			var objectBottom:Number = other.y + (other.height / 2);
			
			if (objectBottom < heroTop)
				e.contact.Disable();
		}

		override public function handleBeginContact(e:ContactEvent):void {
			
			super.handleBeginContact(e);
			
			var collider:Box2DPhysicsObject = e.other.GetBody().GetUserData();
			
			if (_enemyClass && collider is _enemyClass) {
				
				if (_physicsComponent.body.GetLinearVelocity().y < _movementComponent.killVelocity && !_movementComponent.isHurt)
					_movementComponent.hurt(collider);
				else
					_movementComponent.giveDamage(collider);
			}
			
			//Collision angle
			if (e.normal) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{
				var collisionAngle:Number = new MathVector(e.normal.x, e.normal.y).angle * 180 / Math.PI;
				if (collisionAngle > 45 && collisionAngle < 135)
				{
					_viewComponent.groundContacts.push(e.other);
					_movementComponent.onGround = true;
					updateCombinedGroundAngle();
				}
			}
		}
			
		override public function handleEndContact(e:ContactEvent):void {
			
			super.handleEndContact(e);
			
			//Remove from ground contacts, if it is one.
			var index:int = _viewComponent.groundContacts.indexOf(e.other);
			if (index != -1)
			{
				_viewComponent.groundContacts.splice(index, 1);
				if (_viewComponent.groundContacts.length == 0)
					_movementComponent.onGround = false;
				updateCombinedGroundAngle();
			}
		}*/
		
		protected function updateCombinedGroundAngle():void {
			
			_combinedGroundAngle = 0;
			
			if (_viewComponent.groundContacts.length == 0)
				return;
			
			for each (var contact:b2Fixture in _viewComponent.groundContacts)
				var angle:Number = contact.GetBody().GetAngle();
				
			var turn:Number = 45 * Math.PI / 180;
			angle = angle % turn;
			_combinedGroundAngle += angle;
			_combinedGroundAngle /= _viewComponent.groundContacts.length;
		}

		public function get combinedGroundAngle():Number {
			return _combinedGroundAngle;
		}
	}
}
