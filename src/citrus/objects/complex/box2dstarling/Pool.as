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
	
	// Pool uses the BuoyancyController to simulate liquid. 
	
	public class Pool extends Box2DPhysicsObject
	{
		public var poolWidth:Number = 400;
		public var poolHeight:Number = 200;
		public var wallThickness:Number = 15;
		public var waterHeight:Number = 170;
		public var ws:int = 30;//worldscale
		
		// These are the parameters for the water area
		public var density:Number = 1.8;
		public var linearDrag:Number=3;
		public var angularDrag:Number=2;
		
		private var pool:b2Body;
		private var poolFixtureDef:b2FixtureDef;
		private var poolFixture:b2Fixture;
		
		private var buoyancyController:b2BuoyancyController = new b2BuoyancyController();
		
		public function Pool(name:String, params:Object=null)
		{
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
			//the water shape
			b2PolygonShape(_shape).SetAsOrientedBox(poolWidth/_box2D.scale, (waterHeight-wallThickness)/_box2D.scale, 
				new b2Vec2(0, -waterHeight/_box2D.scale));
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
			
			//left wall
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(wallThickness/_box2D.scale, poolHeight/_box2D.scale, 
				new b2Vec2((-poolWidth-wallThickness)/_box2D.scale, (-poolHeight+wallThickness)/_box2D.scale));
			poolFixtureDef.shape = _shape;
			pool.CreateFixture(poolFixtureDef);
			
			//right wall
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(wallThickness/_box2D.scale, poolHeight/_box2D.scale, 
				new b2Vec2((poolWidth+wallThickness)/_box2D.scale, (-poolHeight+wallThickness)/_box2D.scale));
			poolFixtureDef.shape = _shape;
			pool.CreateFixture(poolFixtureDef);
			
			//bottom
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsBox(poolWidth/_box2D.scale, wallThickness/_box2D.scale);
			poolFixtureDef.shape = _shape;
			pool.CreateFixture(poolFixtureDef);
			
			buoyancyController.normal.Set(0,-1);
			buoyancyController.offset=-(_bodyDef.position.y - 2*waterHeight/ws + wallThickness/ws);
			buoyancyController.useDensity=true;
			buoyancyController.density=1.8;
			buoyancyController.linearDrag=3;
			buoyancyController.angularDrag=2;
			_box2D.world.AddController(buoyancyController);
		}
		
		override public function handleBeginContact(contact:b2Contact):void
		{
			if(contact && contact.GetFixtureB().GetUserData().name == "water")
			{
				var bodyA:b2Body=contact.GetFixtureA().GetBody();
				//needs better checking if multiple controllers are used 
				if (bodyA.GetControllerList()==null) {
					buoyancyController.AddBody(bodyA);
				}
			}
		}
		
		override public function handleEndContact(contact:b2Contact):void
		{
			if(contact.GetFixtureB().GetUserData().name == "water")
			{
				if (contact.GetFixtureA().GetBody().GetControllerList()!=null) {
					buoyancyController.RemoveBody(contact.GetFixtureA().GetBody());
				}
			}
		}
	}
}
