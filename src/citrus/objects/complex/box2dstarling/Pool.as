package citrus.objects.complex.box2dstarling{
	
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Controllers.b2BuoyancyController;
	
	import citrus.objects.Box2DPhysicsObject;
	import citrus.physics.box2d.Box2DUtils;
	
	/**
	 * Pool uses the BuoyancyController to simulate liquid physics. It's a rectangular region in which the controller influences the bodies inside of it
	 */	
	
	public class Pool extends Box2DPhysicsObject
	{
		/**
		 *strength of the surrounding bodies
		 */	
		[Inspectable(defaultValue="5")]
		public var wallThickness:Number = 5;
		
		/**
		 *build the left wall?
		 */	
		[Inspectable(defaultValue="true")]
		public var leftWall:Boolean = true;
		
		/**
		 *build the right wall?
		 */	
		[Inspectable(defaultValue="true")]
		public var rightWall:Boolean = true;
		
		/**
		 *build the bottom?
		 */	
		[Inspectable(defaultValue="true")]
		public var bottom:Boolean = true;
		
		// These are the parameters for the water area
		[Inspectable(defaultValue="2")]
		public var density:Number = 2;
		
		[Inspectable(defaultValue="3")]
		public var linearDrag:Number=3;
		
		[Inspectable(defaultValue="2")]
		public var angularDrag:Number=2;
		
		
		private var ws:int = 30;//worldscale
		private var pool:b2Body;
		private var poolFixtureDef:b2FixtureDef;
		private var poolFixture:b2Fixture;
		
		private var buoyancyController:b2BuoyancyController = new b2BuoyancyController();
		
		public function Pool(name:String, params:Object=null)
		{
			
			_beginContactCallEnabled = true;
			_endContactCallEnabled = true;
			
			super(name, params);
		}
		
		override public function destroy():void
		{
			_box2D.world.DestroyController(buoyancyController);
			_box2D.world.DestroyBody(pool);
			super.destroy();
		}
		
		override protected function defineBody():void
		{
			_bodyDef = new b2BodyDef();
			_bodyDef.type = b2Body.b2_staticBody;
			_bodyDef.position.Set(x/ws, y/ws);
		}
		
		override protected function createBody():void
		{
			//the water body
			_body = _box2D.world.CreateBody(_bodyDef);
			_body.SetUserData(this);
			//surrounding body
			pool = _box2D.world.CreateBody(_bodyDef);
			pool.SetUserData(this);
		}
		
		override protected function createShape():void
		{
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(_width/2, _height/2 - wallThickness/ws, new b2Vec2(0, -wallThickness/ws));
		}
		
		override protected function defineFixture():void
		{
			_fixtureDef = new b2FixtureDef();
			_fixtureDef.shape = _shape;
			_fixtureDef.isSensor = true;
			_fixtureDef.userData = {name:"water"};
		}
		
		override protected function createFixture():void
		{
			_fixture = _body.CreateFixture(_fixtureDef);
			
			poolFixtureDef = new b2FixtureDef();
			poolFixtureDef.isSensor = false;
			poolFixtureDef.friction = 0.6;
			poolFixtureDef.restitution = 0.3;
			poolFixtureDef.userData = {name:"pool"};
			
			if (leftWall)
			{
				_shape = new b2PolygonShape();
				b2PolygonShape(_shape).SetAsOrientedBox(wallThickness/ws, _height/2, new b2Vec2(-_width/2 - wallThickness/ws, 0));
				poolFixtureDef.shape = _shape;
				pool.CreateFixture(poolFixtureDef);
			}
			
			if(rightWall)
			{
				_shape = new b2PolygonShape();
				b2PolygonShape(_shape).SetAsOrientedBox(wallThickness/ws, _height/2, new b2Vec2(_width/2 + wallThickness/ws, 0));
				poolFixtureDef.shape = _shape;
				pool.CreateFixture(poolFixtureDef);
			}
			
			if (bottom)
			{
				_shape = new b2PolygonShape();
				b2PolygonShape(_shape).SetAsOrientedBox(_width/2, wallThickness/ws, new b2Vec2(0, _height/2 - wallThickness/ws));
				poolFixtureDef.shape = _shape;
				pool.CreateFixture(poolFixtureDef);
			}
			
			buoyancyController.normal.Set(0,-1);
			buoyancyController.offset = -(_y - _height/2);
			buoyancyController.useDensity = true;
			buoyancyController.density = density;
			buoyancyController.linearDrag = linearDrag;
			buoyancyController.angularDrag = angularDrag;
			_box2D.world.AddController(buoyancyController);
		}
		
		override public function handleBeginContact(contact:b2Contact):void
		{
			if(contact.GetFixtureA() == _fixture || contact.GetFixtureB() == _fixture)
			{
				//needs better checking if multiple controllers are used 
				if (Box2DUtils.CollisionGetOther(this, contact).body.GetControllerList() == null) {
					buoyancyController.AddBody(Box2DUtils.CollisionGetOther(this, contact).body);
				}
			}
		}
		
		override public function handleEndContact(contact:b2Contact):void
		{
			if(contact.GetFixtureA() == _fixture || contact.GetFixtureB() == _fixture)
			{
				if (Box2DUtils.CollisionGetOther(this, contact).body.GetControllerList() != null) {
					buoyancyController.RemoveBody(Box2DUtils.CollisionGetOther(this, contact).body);
				}
			}
		}
	}
}
