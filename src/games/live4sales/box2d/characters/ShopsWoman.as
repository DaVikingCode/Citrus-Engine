package games.live4sales.box2d.characters {

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;

	import games.live4sales.box2d.objects.Block;
	import games.live4sales.box2d.objects.Cash;
	import games.live4sales.box2d.weapons.Bag;
	import games.live4sales.utils.Grid;

	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.physics.PhysicsCollisionCategories;

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
			
			onTouchLeftSide.removeAll();
			
			super.destroy();
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (!_fighting) {
			
				var velocity:b2Vec2 = _body.GetLinearVelocity();
				
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
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("BadGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("BadGuys");
		}

		override public function handleBeginContact(contact:b2Contact):void {
			
			var other:Box2DPhysicsObject = Box2DPhysicsObject.CollisionGetOther(this, contact);
			
			if (other is SalesWoman || other is Block || other is Cash)
				_fighting = true;
				
			else if (other is Bag) {
				life--;
				contact.SetEnabled(false);
			}
		}
			
		override public function handleEndContact(contact : b2Contact) : void {
		
			var other:Box2DPhysicsObject = Box2DPhysicsObject.CollisionGetOther(this, contact);
			
			if (other is SalesWoman || other is Block || other is Cash)
				_fighting = false;
		}
		
		protected function updateAnimation():void {
			
			_animation = _fighting ? "attack" : "walk";
		}
	}
}
