package citrus.system.components.box2d.hero {

	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2DShapeMaker;
	import citrus.system.components.box2d.Box2DComponent;
	import citrus.system.components.box2d.CollisionComponent;

	/**
	 * The Box2D Hero physics component add the fixture listener, change its friction, restitution...
	 */
	public class HeroPhysicsComponent extends Box2DComponent {
		
		protected var _friction:Number = 0.75;

		public function HeroPhysicsComponent(name:String, params:Object = null) {
			
			_preContactCallEnabled = true;
			_beginContactCallEnabled = true;
			_endContactCallEnabled = true;
			
			super(name, params);
		}
			
		override public function destroy():void {
			
			super.destroy();
		}

		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize();
			
			_collisionComponent = entity.lookupComponentByName("collision") as CollisionComponent;
		}

		override protected function defineBody():void {
			
			super.defineBody();
			
			_bodyDef.fixedRotation = true;
			_bodyDef.allowSleep = false;
		}

		override protected function createShape():void {
			
			_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.1);
		}

		override protected function defineFixture():void {
			
			super.defineFixture();
			
			_fixtureDef.friction = _friction;
			_fixtureDef.restitution = 0;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("GoodGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAll();
		}
		
		public function changeFixtureToZero():void {
			_fixture.SetFriction(0);
		}
		
		public function changeFixtureToItsInitialValue():void {
			_fixture.SetFriction(_friction);
		}
	}
}
