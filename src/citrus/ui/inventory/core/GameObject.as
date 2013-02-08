/**
 * User: Makai Media Inc.
 * Date: 11/28/12
 * Time: 4:43 PM
 */
package citrus.ui.inventory.core {

	import citrus.datastructures.BitFlag;

	import flash.utils.getDefinitionByName;

	public class GameObject{

		protected var inventory:InventoryManager=InventoryManager.getInstance();

		public var name:String;
		protected var bitFlag:BitFlag;
		public var quantity:int = 1;

		public function GameObject() {
		}

		public function toggleState(... flags ):void {
			bitFlag.toggleFlags(flags);
		}

		public function hasAnyFlags(...flags):Boolean{
			return bitFlag.hasAnyFlags(flags);
		}

		 public function hasFlags( ... flags ):Boolean{
			 return bitFlag.hasFlags(flags);
		 }

		//override this to add parameters
		public function init():GameObject {
			
			bitFlag = new BitFlag(getDefinitionByName(name) as Class);
			return this;
		}
	}
}
