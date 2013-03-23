package citrus.objects.platformer.box2d 
{

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;

	import citrus.math.MathVector;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;

	import org.osflash.signals.Signal;

	import flash.geom.Point;
	import flash.utils.getDefinitionByName;

	/**
	 * The Reward class is meant to pop out of a RewardBox when the player bumps it. A Reward object is the equivalent of a "mushroom"
	 * "fire flower", or "invincible star" in the Mario games.
	 * 
	 * <p>For each reward that you want in your game, you should make a class that extends this Reward class. If you want an ExtraLifeReward,
	 * you should make a class called ExtraLifeReward that extends Reward. Then hardcode your view, speed, impulseX, and impulseY properties.
	 * Of course, you can also add additional functionality as well by doing this.</p>
	 * 
	 * <p>When you create a RewardBox, you will pass the name of this class into the rewardClass property of RewardBox. That will make the RewardBox
	 * generate a Reward.</p>
	 * 
	 * <ul>Properties:
	 * <li>speed : set the speed that the reward moves at.</li>
	 * <li>impulseX and impulseY : make the reward "jump" out of the box.</li>
	 * <li>collectorClass : tell the object who can collect it. It is set to <code>Hero</code> class by default.</li></ul>
	 * 
	 * <ul>Events:
	 * <li>onCollect : the Signal is dispatched when the reward is collected. Since the RewardBox generates the reward, you probably won't
	 * get a reference to the reward. Thus, you can instead listen for <code>RewardBox.onRewardCollect</code> to find out when the reward is collected. Nevertheless,
	 * if you listen for <code>Reward.OnCollect</code>, it passes a reference to itself when it dispatches.</li></ul>
	 * 
	 * <ul>Animation:
	 * <li>The reward object only has a default animation.</li></ul>
	 * 
	 */
	public class Reward extends Box2DPhysicsObject 
	{
		/**
		 * The speed at which the reward moves. It will turn around when it hits a wall.
		 */
		[Inspectable(defaultValue="1")]
		public var speed:Number = 1;
		
		/**
		 * The speed on the x axis that the reward will fly out of the box.
		 */
		[Inspectable(defaultValue="0")]
		public var impulseX:Number = 0;
		
		/**
		 * The speed on the y axis that the reward will fly out of the box.
		 */
		[Inspectable(defaultValue="-10")]
		public var impulseY:Number = -10;
		
		/**
		 * Dispatches when the reward gets collected. Also see <code>RewardBox.onRewardCollect</code> for a possibly more convenient event.
		 */
		public var onCollect:Signal;
		
		protected var _collectFixtureDef:b2FixtureDef;
		protected var _collectFixture:b2Fixture;
		
		private var _movingLeft:Boolean = false;
		private var _collectorClass:Class = Hero;
		private var _isNew:Boolean = true;
		
		public function Reward(name:String, params:Object = null) 
		{
			_beginContactCallEnabled = true;
			
			super(name, params);
			
			onCollect = new Signal(Reward);
		}
		
		override public function destroy():void
		{
			onCollect.removeAll();
			
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
		
		[Inspectable(defaultValue="citrus.objects.platformer.box2d.Hero",type="String")]
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
			
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
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
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("Items");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("GoodGuys", "BadGuys");
			
			_collectFixtureDef = new b2FixtureDef();
			_collectFixtureDef.shape = _shape;
			_collectFixtureDef.isSensor = true;
			_collectFixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("Items");
			_collectFixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("BadGuys");
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			
			_collectFixture = _body.CreateFixture(_collectFixtureDef);
		}
		
		override public function handleBeginContact(contact:b2Contact):void {
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (collider is _collectorClass)
			{
				kill = true;
				onCollect.dispatch(this);
			}
			
			if (contact.GetManifold().m_localPoint)
			{
				var normalPoint:Point = new Point(contact.GetManifold().m_localPoint.x, contact.GetManifold().m_localPoint.y);
				var collisionAngle:Number = new MathVector(normalPoint.x, normalPoint.y).angle * 180 / Math.PI;
				if (collisionAngle < 45 || collisionAngle > 135)
					_movingLeft = !_movingLeft;
			}
		}
	}

}