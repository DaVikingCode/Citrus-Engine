package citrus.objects.platformer.awayphysics {

	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.events.AWPEvent;

	import citrus.objects.AwayPhysicsObject;

	import org.osflash.signals.Signal;
	
	/**
	 * @author Aymeric
	 */
	public class Sensor extends AwayPhysicsObject {
		
		/**
		 * Dispatches on first contact with the sensor.
		 */
		public var onBeginContact:Signal;
		/**
		 * Dispatches when the object leaves the sensor.
		 */
		public var onEndContact:Signal;
		
		public function Sensor(name:String, params:Object = null) {
			
			super(name, params);
			
			onBeginContact = new Signal(AWPEvent);
			onEndContact = new Signal(AWPEvent);
		}

		override public function destroy():void {
			
			onBeginContact.removeAll();
			onEndContact.removeAll();
			
			_body.removeEventListener(AWPEvent.COLLISION_ADDED, handleBeginContact);
			
			super.destroy();
		}
		
		override protected function defineBody():void {
			
			_mass = 0;
			
			super.defineBody();
		}
		
		override protected function createConstraint():void {
			
			_body.addEventListener(AWPEvent.COLLISION_ADDED, handleBeginContact);
			
			_body.collisionFlags |= AWPCollisionFlags.CF_NO_CONTACT_RESPONSE;
		}
		
		protected function handleBeginContact(contact:AWPEvent):void {
			
			onBeginContact.dispatch(contact);
			trace('ok');
		}

	}
}
