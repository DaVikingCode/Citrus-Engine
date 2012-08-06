package com.citrusengine.objects.platformer.box2d {

	import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2FixtureDef;

	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.physics.Box2DCollisionCategories;
	import com.citrusengine.utils.Box2DShapeMaker;

	import flash.display.MovieClip;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	/**
	 * This is a common example of a side-scrolling bad guy. He has limited logic, basically
	 * only turning around when he hits a wall.
	 * 
	 * When controlling collision interactions between two objects, such as a Horo and Baddy,
	 * I like to let each object perform its own actions, not control one object's action from the other object.
	 * For example, the Hero doesn't contain the logic for killing the Baddy, and the Baddy doesn't contain the
	 * logic for making the hero "Spring" when he kills him. 
	 */	
	public class Baddy extends Box2DPhysicsObject
	{
		[Property(value="1.3")]
		public var speed:Number = 1.3;
		
		[Property(value="3")]
		public var enemyKillVelocity:Number = 3;
		
		[Property(value="left")]
		public var startingDirection:String = "left";
		
		[Property(value="400")]
		public var hurtDuration:Number = 400;
		
		[Property(value="-100000")]
		public var leftBound:Number = -100000;
		
		[Property(value="100000")]
		public var rightBound:Number = 100000;
		
		[Citrus(value="10")]
		public var wallSensorOffset:Number = 10;
		
		[Citrus(value="2")]
		public var wallSensorWidth:Number = 2;
		
		[Citrus(value="2")]
		public var wallSensorHeight:Number = 2;
		
		protected var _hurtTimeoutID:Number = 0;
		protected var _hurt:Boolean = false;
		protected var _enemyClass:* = Hero;
		protected var _lastXPos:Number;
		protected var _lastTimeTurnedAround:Number = 0;
		protected var _waitTimeBeforeTurningAround:Number = 1000;
		
		protected var _leftSensorShape:b2PolygonShape;
		protected var _rightSensorShape:b2PolygonShape;
		protected var _leftSensorFixture:b2Fixture;
		protected var _rightSensorFixture:b2Fixture;
		protected var _sensorFixtureDef:b2FixtureDef;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, speed:Number, view:* = null, leftBound:Number = -100000, rightBound:Number = 100000, startingDirection:String = "left"):Baddy
		{
			if (view == null) view = MovieClip;
			return new Baddy(name, { x: x, y: y, width: width, height: height, speed: speed, view: view, leftBound: leftBound, rightBound: rightBound, startingDirection: startingDirection } );
		}
		
		public function Baddy(name:String, params:Object=null)
		{
			super(name, params);
			
			if (startingDirection == "left")
			{
				_inverted = true;
			}
		}
		
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_leftSensorFixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
			_rightSensorFixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
			clearTimeout(_hurtTimeoutID);
			_sensorFixtureDef.destroy();
			_leftSensorShape.destroy();
			_rightSensorShape.destroy();
			super.destroy();
		}
		
		public function get enemyClass():*
		{
			return _enemyClass;
		}
		
		[Property(value="com.citrusengine.objects.platformer.box2d.Hero")]
		public function set enemyClass(value:*):void
		{
			if (value is String)
				_enemyClass = getDefinitionByName(value) as Class;
			else if (value is Class)
				_enemyClass = value;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var position:V2 = _body.GetPosition();
			_lastXPos = position.x;
			
			//Turn around when they pass their left/right bounds
			if ((_inverted && position.x * 30 < leftBound) || (!_inverted && position.x * 30 > rightBound))
				turnAround();
			
			var velocity:V2 = _body.GetLinearVelocity();
			if (!_hurt)
			{
				if (_inverted)
					velocity.x = -speed;
				else
					velocity.x = speed;
			}
			
			_body.SetLinearVelocity(velocity);
			
			updateAnimation();
		}
		
		public function hurt():void
		{
			_hurt = true;
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
		}
		
		public function turnAround():void
		{
			_inverted = !_inverted;
			_lastTimeTurnedAround = new Date().time;
		}
		
		override protected function createBody():void
		{
			super.createBody();
			_body.SetFixedRotation(true);
		}
		
		override protected function createShape():void
		{
			_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.2);
			
			var sensorWidth:Number = wallSensorWidth / _box2D.scale;
			var sensorHeight:Number = wallSensorHeight / _box2D.scale;
			var sensorOffset:V2 = new V2( -_width / 2 - (sensorWidth / 2), _height / 2 - (wallSensorOffset / _box2D.scale));
			_leftSensorShape = new b2PolygonShape();
			_leftSensorShape.SetAsBox(sensorWidth, sensorHeight, sensorOffset);
			
			sensorOffset.x = -sensorOffset.x;
			_rightSensorShape = new b2PolygonShape();
			_rightSensorShape.SetAsBox(sensorWidth, sensorHeight, sensorOffset);
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = 0;
			_fixtureDef.filter.categoryBits = Box2DCollisionCategories.Get("BadGuys");
			_fixtureDef.filter.maskBits = Box2DCollisionCategories.GetAllExcept("Items");
			
			_sensorFixtureDef = new b2FixtureDef();
			_sensorFixtureDef.shape = _leftSensorShape;
			_sensorFixtureDef.isSensor = true;
			_sensorFixtureDef.filter.categoryBits = Box2DCollisionCategories.Get("BadGuys");
			_sensorFixtureDef.filter.maskBits = Box2DCollisionCategories.GetAllExcept("Items");
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			_fixture.m_reportBeginContact = true;
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			
			_leftSensorFixture = body.CreateFixture(_sensorFixtureDef);
			_leftSensorFixture.m_reportBeginContact = true;
			_leftSensorFixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
			
			_sensorFixtureDef.shape = _rightSensorShape;
			_rightSensorFixture = body.CreateFixture(_sensorFixtureDef);
			_rightSensorFixture.m_reportBeginContact = true;
			_rightSensorFixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
		}
		
		protected function handleBeginContact(e:ContactEvent):void
		{
			var collider:Box2DPhysicsObject = e.other.GetBody().GetUserData();
			
			if (collider is _enemyClass && collider.body.GetLinearVelocity().y > enemyKillVelocity)
				hurt();
			
		}
		
		protected function handleSensorBeginContact(e:ContactEvent):void
		{
			if (_body.GetLinearVelocity().x < 0 && e.fixture == _rightSensorFixture)
				return;
			
			if (_body.GetLinearVelocity().x > 0 && e.fixture == _leftSensorFixture)
				return;
				
			var collider:Box2DPhysicsObject = e.other.GetBody().GetUserData();
			if (collider is Platform || collider is Baddy)
			{
				turnAround();
			}
		}
		
		protected function updateAnimation():void
		{
			if (_hurt)
				_animation = "die";
			else
				_animation = "walk";
		}
		
		protected function endHurtState():void
		{
			_hurt = false;
			kill = true;
		}
	}
}