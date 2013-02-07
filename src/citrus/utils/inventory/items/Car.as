/**
 * User: Makai Media Inc.
 * Date: 2/6/13
 * Time: 10:49 AM
 */
package citrus.utils.inventory.items {

	import citrus.utils.inventory.core.GameObject;
	
	public class Car extends GameObject {
		public static const UNLOCKED:uint=1 << 0;
		public static const STARTED:uint=1 << 1;

		public function Car() {
			super();
		}

		override public function init():GameObject {
			name = "items.Car";
			return super.init();
		}
	}
}
