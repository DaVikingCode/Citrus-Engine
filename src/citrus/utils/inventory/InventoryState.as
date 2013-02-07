/**
 * User: Makai Media Inc.
 * Date: 2/6/13
 * Time: 4:42 PM
 */
package citrus.utils.inventory {

	import citrus.core.State;
	import citrus.utils.inventory.core.InventoryManager;

	import items.Car;
	import items.Key;

	import flash.text.TextField;

	public class InventoryState extends State {
		public function InventoryState()
		{
			var textField:TextField=new TextField();
			textField.text="";
			textField.width=500;
			addChild(textField);

			var inventory:InventoryManager= InventoryManager.getInstance();
			inventory.add(new Car().init());
			inventory.add(new Key().init());

			textField.text+="Is key shiny? "+inventory.status("items.Key", Key.POLISHED)+"\n";

			inventory.toggleState("items.Key", Key.POLISHED);

			textField.text+="Is key shiny? "+inventory.status("items.Key", Key.POLISHED)+"\n";

			textField.text+="Can I open the car if the key is shiny? "+inventory.status("items.Car", Car.UNLOCKED)+"\n";

			inventory.toggleState("items.Key", Key.FOUND);

			textField.text+="Can I open the car because I found the key, but haven't unlocked it? "+inventory.status("items.Car", Car.UNLOCKED)+"\n";

			if(inventory.status("items.Key", Key.FOUND)){
				inventory.toggleState("items.Car", Car.UNLOCKED);
			}

			textField.text+="Now is the car open? "+inventory.status("items.Car", Car.UNLOCKED)+"\n";

			inventory.add(new Key().init());

			textField.text+="How many keys? "+inventory.get("items.Key").quantity+"\n";

		}
	}
}
