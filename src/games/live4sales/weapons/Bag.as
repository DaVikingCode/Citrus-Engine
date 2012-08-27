package games.live4sales.weapons {

	import Box2DAS.Dynamics.ContactEvent;

	import games.live4sales.characters.SalesWoman;
	import games.live4sales.objects.Block;

	import com.citrusengine.objects.Box2DPhysicsObject;
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
			
			var other:Box2DPhysicsObject = cEvt.other.GetBody().GetUserData();
			
			if (other is SalesWoman || other is Bag || other is Block)
				cEvt.contact.Disable();
			else
				explode();
		}

	}
}
