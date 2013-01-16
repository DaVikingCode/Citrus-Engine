package citrus.core {

	import citrus.system.Entity;
	import citrus.view.ISpriteView;

	/**
	 * @author Aymeric
	 */
	public class CitrusGroup extends Entity {

		protected var _groupObjects:Vector.<CitrusObject> = new Vector.<CitrusObject>();

		public function CitrusGroup(name:String, params:Object = null) {
			super(name, params);
		}

		public function addObject(object:CitrusObject):void {

			_groupObjects.push(object);
		}

		public function removeObject(object:CitrusObject):void {

			_groupObjects.splice(_groupObjects.indexOf(object), 1);
		}

		public function setParamsOnObjects(param:Object):void {

			for each (var object:CitrusObject in _groupObjects)				
				setParams(object, param);
		}
		
		public function setParamsOnViews(param:Object):void {
			
			for each (var object:ISpriteView in _groupObjects)				
				setParams(object.view, param);
		}
		
		/**
		 * Gets a reference to a CitrusObject by passing that object's name in.
		 * Often the name property will be set via a level editor such as the Flash IDE. 
		 * @param name The name property of the object you want to get a reference to.
		 */
		public function getObjectByName(name:String):CitrusObject {

			for each (var object:CitrusObject in _groupObjects) {
				if (object.name == name)
					return object;
			}

			return null;
		}
		
		/**
		 * This returns a vector of all objects of a particular name. This is useful for adding an event handler
		 * to objects that aren't similar but have the same name. For instance, you can track the collection of 
		 * coins plus enemies that you've named exactly the same. Then you'd loop through the returned vector to change properties or whatever you want.
		 * @param name The name property of the object you want to get a reference to.
		 */
		public function getObjectsByName(name:String):Vector.<CitrusObject> {

			var objects:Vector.<CitrusObject> = new Vector.<CitrusObject>();

			for each (var object:CitrusObject in _groupObjects) {
				if (object.name == name)
					objects.push(object);
			}

			return objects;
		}

		/**
		 * Returns the first instance of a CitrusObject that is of the class that you pass in. 
		 * This is useful if you know that there is only one object of a certain time in your state (such as a "Hero").
		 * @param type The class of the object you want to get a reference to.
		 */
		public function getFirstObjectByType(type:Class):CitrusObject {

			for each (var object:CitrusObject in _groupObjects) {
				if (object is type)
					return object;
			}

			return null;
		}

		/**
		 * This returns a vector of all objects of a particular type. This is useful for adding an event handler
		 * to all similar objects. For instance, if you want to track the collection of coins, you can get all objects
		 * of type "Coin" via this method. Then you'd loop through the returned array to add your listener to the coins' event.
		 * @param type The class of the object you want to get a reference to.
		 */
		public function getObjectsByType(type:Class):Vector.<CitrusObject> {

			var objects:Vector.<CitrusObject> = new Vector.<CitrusObject>();

			for each (var object:CitrusObject in _groupObjects) {
				if (object is type) {
					objects.push(object);
				}
			}

			return objects;
		}

		public function get groupObjects():Vector.<CitrusObject> {
			return _groupObjects;
		}
		
	}
}
