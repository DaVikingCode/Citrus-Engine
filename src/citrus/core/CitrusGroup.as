package citrus.core {

	import citrus.system.Entity;
	import citrus.view.ISpriteView;

	/**
	 * A CitrusGroup defines a group of objects which may be of different kind. It extends Entity class, it means that you can easily add components to 
	 * a CitrusGroup to define different behaviors. You can also set quickly different params to all group's objects and their view.
	 */
	public class CitrusGroup extends Entity {

		protected var _groupObjects:Vector.<CitrusObject> = new Vector.<CitrusObject>();

		public function CitrusGroup(name:String, params:Object = null) {
			super(name, params);
		}
			
		override public function destroy():void {
			
			_groupObjects.length = 0;
			
			super.destroy();
		}
		
		/**
		 * Add an object to the group.
		 * @param object An object to add to the group.
		 * @return return the CitrusGroup for chained operation.
		 */
		public function addObject(object:CitrusObject):CitrusGroup {

			_groupObjects.push(object);
			
			return this;
		}
		
		/**
		 * Remove an object of the group.
		 * @param object An object to remove from the group.
		 * @return return the CitrusGroup for chained operation.
		 */
		public function removeObject(object:CitrusObject):CitrusGroup {

			_groupObjects.splice(_groupObjects.indexOf(object), 1);
			
			return this;
		}
		
		/**
		 * Define properties for all objects into the group like we do for a CitrusObject.
		 * @param param An object where properties and value are defined.
		 */
		public function setParamsOnObjects(param:Object):void {

			for each (var object:CitrusObject in _groupObjects)				
				setParams(object, param);
		}
		
		/**
		 * Define properties for all objects' view into the group like we do for a CitrusObject.
		 * @param param An object where properties and value are defined.
		 */
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
		
		/**
		 * groupObjects is a vector containing all the objects registered into the group.
		 */
		public function get groupObjects():Vector.<CitrusObject> {
			return _groupObjects;
		}
		
	}
}
