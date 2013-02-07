/**
 * User: Makai Media Inc.
 * Date: 2/6/13
 * Time: 4:41 PM
 */
package citrus.utils.inventory{

	import citrus.core.CitrusEngine;

	public class InventoryTester extends CitrusEngine{
		public function InventoryTester() {
			state = new InventoryState();
		}
	}
}
