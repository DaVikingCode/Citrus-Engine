package games.live4sales.weapons {

	import Box2DAS.Dynamics.ContactEvent;

	import games.live4sales.characters.SalesWoman;

	import com.citrusengine.objects.platformer.box2d.Missile;

	/**
	 * @author Aymeric
	 */
	public class Bag extends Missile {

		public function Bag(name:String, params:Object = null) {
			super(name, params);
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (x > 480)
				kill = true;
		}
			
		override protected function handleBeginContact(cEvt:ContactEvent):void {
			
			if (cEvt.other.GetBody().GetUserData() is SalesWoman || cEvt.other.GetBody().GetUserData() is Bag) {
				cEvt.contact.Disable();
			} else if (!cEvt.other.IsSensor()) {
				explode();
			}
		}

	}
}
