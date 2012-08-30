package games.live4sales.characters {

	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.ContactEvent;

	import games.live4sales.objects.Block;
	import games.live4sales.objects.Cash;
	import games.live4sales.utils.Grid;
	import games.live4sales.weapons.Bag;

	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.physics.Box2DCollisionCategories;

	import org.osflash.signals.Signal;

	/**
	 * @author Aymeric
	 */
	public class ShopsWoman extends Box2DPhysicsObject {
		
		public var speed:Number = 0.7;
		public var life:uint = 4;
		
		public var onTouchLeftSide:Signal;
		
		private var _fighting:Boolean = false;

		public function ShopsWoman(name:String, params:Object = null) {
			
			super(name, params);
			
			onTouchLeftSide = new Signal();
		}
			
		override public function destroy():void {
			
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.removeEventListener(ContactEvent.END_CONTACT, handleEndContact);
			
			onTouchLeftSide.removeAll();
			
			super.destroy();
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (!_fighting) {
			
				var velocity:V2 = _body.GetLinearVelocity();
				
				velocity.x = -speed;
				
				_body.SetLinearVelocity(velocity);
			}
				
			if (x < 0) {
				onTouchLeftSide.dispatch();
				kill = true;
			}
			
			if (life == 0) {
				kill = true;
				Grid.tabBaddies[group] = false;
			} else {
				Grid.tabBaddies[group] = true;
			}
			
			updateAnimation();
		}
		
		override protected function defineBody():void {
			
			super.defineBody();
			
			_bodyDef.fixedRotation = true;
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
			_fixture.m_reportEndContact = true;
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.addEventListener(ContactEvent.END_CONTACT, handleEndContact);
		}
			
		protected function handleBeginContact(cEvt:ContactEvent):void {
			
			var other:Box2DPhysicsObject = cEvt.other.GetBody().GetUserData();
			
			if (other is SalesWoman || other is Block || other is Cash)
				_fighting = true;
				
			else if (other is Bag) {
				life--;
				cEvt.contact.Disable();
			}
		}
		
		protected function handleEndContact(cEvt:ContactEvent):void {
			
			var other:Box2DPhysicsObject = cEvt.other.GetBody().GetUserData();
			
			if (other is SalesWoman || other is Block || other is Cash)
				_fighting = false;
		}
		
		protected function updateAnimation():void {
			
			_animation = "walk";
		}
	}
}
