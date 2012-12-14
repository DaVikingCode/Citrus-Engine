package citrus.system.components.box2d.hero {

	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Fixture;

	import citrus.math.MathVector;
	import citrus.objects.platformer.box2d.Crate;
	import citrus.objects.platformer.box2d.Enemy;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.system.components.box2d.CollisionComponent;

	import flash.geom.Point;

	/**
	 * The Box2D Hero collision component. We need to access informations of the hero view, movement and physics component.
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
		
		override public function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void {
			
			super.handlePreSolve(contact, oldManifold);
			
			if (!_movementComponent.ducking)
				return;
				
			var other:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(_physicsComponent, contact);
			
			var heroTop:Number = _physicsComponent.y;
			var objectBottom:Number = other.y + (other.height / 2);
			
			if (objectBottom < heroTop)
				contact.SetEnabled(false);
		}

		override public function handleBeginContact(contact:b2Contact):void {
			
			super.handleBeginContact(contact);
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(_physicsComponent, contact);
			
			if (_enemyClass && collider is _enemyClass) {
				
				if (_physicsComponent.body.GetLinearVelocity().y < _movementComponent.killVelocity && !_movementComponent.isHurt)
					_movementComponent.hurt(collider);
				else
					_movementComponent.giveDamage(collider);
			}
			
			//Collision angle if we don't touch a Sensor.
			if (contact.GetManifold().m_localPoint && !(collider is Sensor)) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{
				var normalPoint:Point = new Point(contact.GetManifold().m_localPoint.x, contact.GetManifold().m_localPoint.y);
				var collisionAngle:Number = new MathVector(normalPoint.x, normalPoint.y).angle * 180 / Math.PI;
				if (collisionAngle > 45 && collisionAngle < 135 || collisionAngle == -90 || collider is Crate)
				{
					//we don't want the Hero to be set up as onGround if it touches a cloud.
					if (collider is Platform && (collider as Platform).oneWay && collisionAngle == -90)
						return;
					
					_viewComponent.groundContacts.push(collider.body.GetFixtureList());
					_movementComponent.onGround = true;
					updateCombinedGroundAngle();
				}
			}
		}
			
		override public function handleEndContact(contact:b2Contact):void {
			
			super.handleEndContact(contact);
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(_physicsComponent, contact);
			
			//Remove from ground contacts, if it is one.
			var index:int = _viewComponent.groundContacts.indexOf(collider.body.GetFixtureList());
			if (index != -1)
			{
				_viewComponent.groundContacts.splice(index, 1);
				if (_viewComponent.groundContacts.length == 0)
					_movementComponent.onGround = false;
				updateCombinedGroundAngle();
			}
		}
		
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
