package games.live4sales.weapons {
	
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.ContactEvent;

	import com.citrusengine.objects.platformer.box2d.Missile;
	import com.citrusengine.physics.Box2DCollisionCategories;

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
				_body.SetLinearVelocity(new V2());
			
			if (x > 480)
				kill = true;
		}
			
		override protected function handleBeginContact(cEvt:ContactEvent):void {
			explode();
		}
		
		override protected function defineBody():void {
			
			super.defineBody();
			
			_bodyDef.bullet = false;
			_bodyDef.allowSleep = true;
		}
		
		override protected function defineFixture():void {
			
			super.defineFixture();

			_fixtureDef.filter.categoryBits = Box2DCollisionCategories.Get("Level");
			_fixtureDef.filter.maskBits = Box2DCollisionCategories.GetAllExcept("Level");
		}

	}
}
