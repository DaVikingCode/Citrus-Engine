/**
 * User: Makai Media Inc.
 * Date: 2/6/13
 * Time: 4:41 PM
 */
package {

	import citrus.core.CitrusEngine;
	import citrus.objects.CitrusSprite;

	public class InventoryTester extends CitrusEngine{
		public function InventoryTester() {
			state = new InventoryState();
		}
	}
}
