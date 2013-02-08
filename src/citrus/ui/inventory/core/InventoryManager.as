/**
 * User: Makai Media Inc.
 * Date: 12/5/12
 * Time: 1:26 PM
 */
package citrus.ui.inventory.core {

	import flash.utils.Dictionary;

	public class InventoryManager {

		public var slots:Dictionary = new Dictionary();
		private static var _instance:InventoryManager;

		public function InventoryManager() {
		}

		public static function getInstance():InventoryManager {
			if (!_instance) {
				_instance = new InventoryManager();
			}
			return _instance;
		}

		public function clear():void{
			slots = new Dictionary();
		}

		public function add(gameObject:GameObject):void {
			if (!slots[gameObject.name]) {
				slots[gameObject.name] = gameObject;
			}else{
				slots[gameObject.name].quantity++;
			}
		}

		public function remove(gameObject:GameObject):void {
			if (slots[gameObject.name]) {
				slots[gameObject.name].quantity--;
				if(slots[gameObject.name].quantity==0){
					slots[gameObject.name] = null;
				}
			}
		}

		public function get(name:String):GameObject {
			return  slots[name] as GameObject;
		}

		public function status(name:String, ...flags):Boolean{
			if(slots[name]){
				return  slots[name].hasFlags(flags);
			}
			return false;
		}

		public function hasAnyFlags(name:String,  ...flags):Boolean{
			if(slots[name]){
				return  slots[name].hasAnyFlags(flags);
			}
			return false;
		}

		public function toggleState(name:String, ...flags):void {
			trace("[Item State Changed for] ",name);
			if(slots[name]){
				slots[name].toggleState(flags);
			}
		}

	}
}
