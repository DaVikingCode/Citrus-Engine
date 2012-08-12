package com.citrusengine.system.components.box2d.hero {

	import Box2DAS.Dynamics.ContactEvent;

	import com.citrusengine.physics.Box2DCollisionCategories;
	import com.citrusengine.system.components.box2d.Box2DComponent;
	import com.citrusengine.system.components.box2d.CollisionComponent;
	import com.citrusengine.utils.Box2DShapeMaker;

	/**
	 * The Box2D Hero physics component add the fixture listener, change its friction, restitution...
	 */
	public class HeroPhysicsComponent extends Box2DComponent {
		
		protected var _collisionComponent:CollisionComponent;

		protected var _friction:Number = 0.75;

		public function HeroPhysicsComponent(name:String, params:Object = null) {
			super(name, params);
		}
			
		override public function destroy():void {
			
			_fixture.removeEventListener(ContactEvent.PRE_SOLVE, _collisionComponent.handlePreSolve);
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, _collisionComponent.handleBeginContact);
			_fixture.removeEventListener(ContactEvent.END_CONTACT, _collisionComponent.handleEndContact);
			
			super.destroy();
		}

		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize();
			
			_collisionComponent = entity.components["collision"];
			
			_fixture.addEventListener(ContactEvent.PRE_SOLVE, _collisionComponent.handlePreSolve);
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, _collisionComponent.handleBeginContact);
			_fixture.addEventListener(ContactEvent.END_CONTACT, _collisionComponent.handleEndContact);
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
			_fixtureDef.filter.categoryBits = Box2DCollisionCategories.Get("GoodGuys");
			_fixtureDef.filter.maskBits = Box2DCollisionCategories.GetAll();
		}

		override protected function createFixture():void {
			
			super.createFixture();

			_fixture.m_reportPreSolve = true;
			_fixture.m_reportBeginContact = true;
			_fixture.m_reportEndContact = true;
		}
		
		public function changeFixtureToZero():void {
			_fixture.SetFriction(0);
		}
		
		public function changeFixtureToItsInitialValue():void {
			_fixture.SetFriction(_friction);
		}
	}
}
