package games.live4sales.box2d.weapons {

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;

	import com.citrusengine.objects.platformer.box2d.Missile;
	import com.citrusengine.physics.PhysicsCollisionCategories;
	
	/**
	 * @author Aymeric
	 */
	public class Bag extends Missile {

		public function Bag(name:String, params:Object = null) {
			super(name, params);
		}
		
		override public function update(timeDelta:Number):void {
			
			if (!_exploded)
				_body.SetLinearVelocity(_velocity);
			else
				_body.SetLinearVelocity(new b2Vec2());
			
			if (x > 480)
				kill = true;
		}
			
		override public function handleBeginContact(contact:b2Contact):void {
			explode();
		}
		
		override protected function defineBody():void {
			
			super.defineBody();
			
			_bodyDef.bullet = false;
			_bodyDef.allowSleep = true;
		}
		
		override protected function defineFixture():void {
			
			super.defineFixture();

			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("Level");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("Level");
		}

	}
}
