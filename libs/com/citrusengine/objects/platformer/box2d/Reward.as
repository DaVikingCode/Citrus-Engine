package com.citrusengine.objects.platformer.box2d 
{

	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2FixtureDef;

	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.physics.Box2DCollisionCategories;

	import org.osflash.signals.Signal;

	import flash.utils.getDefinitionByName;
	
	/**
	 * The Reward class is meant to pop out of a RewardBox when the player bumps it. A Reward object is the equivelant of a "mushroom"
	 * "fire flower", or "invincible star" in the Mario games.
	 * 
	 * For each reward that you want in your game, you should make a class that extends this Reward class. If you want an ExtraLifeReward,
	 * you should make a class called ExtraLifeReward that extends Reward. Then hardcode your view, speed, impulseX, and impulseY properties.
	 * Of course, you can also add additional functionality as well by doing this.
	 * 
	 * When you create a RewardBox, you will pass the name of this class into the rewardClass property of RewardBox. That will make the RewardBox
	 * generate a Reward.
	 * 
	 * You can specify the <code>speed</code> property to set the speed that the reward moves at.
	 * 
	 * You can specify the <code>impulseX</code> and <code>impulseY</code> properties to make the reward "jump" out of the box.
	 * 
	 * You can specify the <code>collectorClass</code> property to tell the object who can collect it. It is set to <code>Hero</code> class by default.
	 * 
	 * Events:
	 * The <code>onCollect</code> Signal is dispatched when the reward is collected. Since the RewardBox generates the reward, you probably won't
	 * get a reference to the reward. Thus, you can instead listen for RewardBox.onRewardCollect to find out when the reward is collected. Nevertheless,
	 * if you listen for Reward.OnCollect, it passes a reference to itself when it dispatches.
	 * 
	 * Animation:
	 * The reward object only has a default animation.
	 * 
	 */
	public class Reward extends Box2DPhysicsObject 
	{
		/**
		 * The speed at which the reward moves. It will turn around when it hits a wall.
		 */
		public var speed:Number = 1;
		
		/**
		 * The speed on the x axis that the reward will fly out of the box.
		 */
		public var impulseX:Number = 0;
		
		/**
		 * The speed on the y axis that the reward will fly out of the box.
		 */
		public var impulseY:Number = -10;
		
		/**
		 * Dispatches when the reward gets collected. Also see RewardBox.onRewardCollect for a possibly more convenient event.
		 */
		public var onCollect:Signal;
		
		protected var _collectFixtureDef:b2FixtureDef;
		protected var _collectFixture:b2Fixture;
		
		private var _movingLeft:Boolean = false;
		private var _collectorClass:Class = Hero;
		private var _isNew:Boolean = true;
		
		public function Reward(name:String, params:Object = null) 
		{
			super(name, params);
			
			onCollect = new Signal(Reward);
		}
		
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handlePlatformContact);
			_collectFixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleCollectContact);
			onCollect.removeAll();
			
			_collectFixtureDef.destroy();
			
			super.destroy();
		}
		
		/**
		 * Specify the class of the object that you want the reward to be collected by.
		 * You can specify the collectorClass in String form (collectorClass = "com.myGame.MyHero") or via direct reference 
		 * (collectorClass = MyHero). You should use the String form when creating Rewards in an external level editor. Make sure and
		 * specify the entire classpath.
		 */
		public function get collectorClass():*
		{
			return _collectorClass;
		}
		
		public function set collectorClass(value:*):void
		{
			if (value is String)
				_collectorClass = getDefinitionByName(value) as Class;
			else if (value is Class)
				_collectorClass = value;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var velocity:V2 = _body.GetLinearVelocity();
			
			if (_isNew)
			{
				_isNew = false;
				velocity.x += impulseX;
				velocity.y += impulseY;
			}
			else
			{
				if (_movingLeft)
					velocity.x = -speed;
				else
					velocity.x = speed;
			}
			
			_body.SetLinearVelocity(velocity);
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			
			_bodyDef.fixedRotation = true;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = 0;
			_fixtureDef.restitution = 0;
			_fixtureDef.filter.categoryBits = Box2DCollisionCategories.Get("Items");
			_fixtureDef.filter.maskBits = Box2DCollisionCategories.GetAllExcept("GoodGuys", "BadGuys");
			
			_collectFixtureDef = new b2FixtureDef();
			_collectFixtureDef.shape = _shape;
			_collectFixtureDef.isSensor = true;
			_collectFixtureDef.filter.categoryBits = Box2DCollisionCategories.Get("Items");
			_collectFixtureDef.filter.maskBits = Box2DCollisionCategories.GetAllExcept("BadGuys");
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			
			_fixture.m_reportBeginContact = true;
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handlePlatformContact);
			
			_collectFixture = _body.CreateFixture(_collectFixtureDef);
			_collectFixture.m_reportBeginContact = true;
			_collectFixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleCollectContact);
		}
		
		protected function handleCollectContact(e:ContactEvent):void
		{
			var collider:Box2DPhysicsObject = e.other.GetBody().GetUserData() as Box2DPhysicsObject;
			
			if (collider is _collectorClass)
			{
				kill = true;
				onCollect.dispatch(this);
			}
		}
		
		protected function handlePlatformContact(e:ContactEvent):void
		{
			if (e.normal)
			{
				var collisionAngle:Number = new MathVector(e.normal.x, e.normal.y).angle * 180 / Math.PI;
				if (collisionAngle < 45 || collisionAngle > 135)
					_movingLeft = !_movingLeft;
			}
		}
	}

}