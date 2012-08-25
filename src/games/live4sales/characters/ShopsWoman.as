package games.live4sales.characters {

	import games.live4sales.weapons.Bag;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.ContactEvent;

	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.physics.Box2DCollisionCategories;

	/**
	 * @author Aymeric
	 */
	public class ShopsWoman extends Box2DPhysicsObject {
		
		public var speed:Number = 1.3;
		
		private var _fighting:Boolean = false;

		public function ShopsWoman(name:String, params:Object = null) {
			super(name, params);
		}
			
		override public function destroy():void {
			
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			
			super.destroy();
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (!_fighting) {
			
				var velocity:V2 = _body.GetLinearVelocity();
				
				velocity.x = -speed;
				
				_body.SetLinearVelocity(velocity);
			}
			
			updateAnimation();
		}
		
		override protected function defineFixture():void {
			
			super.defineFixture();
			
			_fixtureDef.friction = 0;
			_fixtureDef.filter.categoryBits = Box2DCollisionCategories.Get("BadGuys");
			_fixtureDef.filter.maskBits = Box2DCollisionCategories.GetAllExcept("Items");
		}
			
		override protected function createFixture():void {
			
			super.createFixture();
			
			_fixture.m_reportBeginContact = true;
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		}
			
		protected function handleBeginContact(cEvt:ContactEvent):void {
			
			if (cEvt.other.GetBody().GetUserData() is SalesWoman)
				_fighting = true;
				
			if (cEvt.other.GetBody().GetUserData() is Bag)
				cEvt.contact.Disable();
		}
		
		protected function updateAnimation():void {
			
			_animation = "walk";
		}
	}
}
