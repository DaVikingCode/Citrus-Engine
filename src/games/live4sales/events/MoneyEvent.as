package games.live4sales.events {

	import flash.events.Event;

	/**
	 * @author Aymeric
	 */
	public class MoneyEvent extends Event {
		
		public static const BUY_ITEM:String = "BUY_ITEM";
		public static const PICKUP_MONEY:String = "PICKUP_MONEY";

		public function MoneyEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}
