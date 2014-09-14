package citrus.core {

	import citrus.datastructures.PoolObject;
	import citrus.input.Input;
	import citrus.system.Entity;
	import citrus.system.components.ViewComponent;
	import citrus.view.ACitrusView;
	import citrus.view.spriteview.SpriteView;

	import flash.display.Sprite;

	/**
	 * State class is just a wrapper for the AState class. It's important to notice it extends Sprite.
	 */
	public class State extends Sprite implements IState {

		/**
		 * Get a direct references to the Citrus Engine in your State.
		 */
		protected var _ce:CitrusEngine;

		protected var _realState:MediatorState;

		protected var _input:Input;

		public function State() {
			
			_ce = CitrusEngine.getInstance();

			_realState = new MediatorState(this);
		}

		/**
		 * Called by the Citrus Engine.
		 */
		public function destroy():void {
			_realState.destroy();
			_realState = null;
		}

		/**
		 * Gets a reference to this state's view manager. Take a look at the class definition for more information about this. 
		 */
		public function get view():ACitrusView {
			return _realState.view;
		}

		/**
		 * You'll most definitely want to override this method when you create your own State class. This is where you should
		 * add all your CitrusObjects and pretty much make everything. Please note that you can't successfully call add() on a 
		 * state in the constructur. You should call it in this initialize() method. 
		 */
		public function initialize():void {
			_realState.view = createView();
			_input = _ce.input;
		}

		/**
		 * This method calls update on all the CitrusObjects that are attached to this state.
		 * The update method also checks for CitrusObjects that are ready to be destroyed and kills them.
		 * Finally, this method updates the View manager. 
		 */
		public function update(timeDelta:Number):void {

			_realState.update(timeDelta);
		}

		/**
		 * Call this method to add a CitrusObject to this state. All visible game objects and physics objects
		 * will need to be created and added via this method so that they can be properly created, managed, updated, and destroyed. 
		 * @return The CitrusObject that you passed in. Useful for linking commands together.
		 */
		public function add(object:CitrusObject):CitrusObject {
			return _realState.add(object);
		}

		/**
		 * Call this method to add an Entity to this state. All entities will need to be created
		 * and added via this method so that they can be properly created, managed, updated, and destroyed.
		 * @return The Entity that you passed in. Useful for linking commands together.
		 */
		public function addEntity(entity:Entity):Entity {

			return _realState.addEntity(entity);
		}

		/**
		 * Call this method to add a PoolObject to this state. All pool objects and  will need to be created 
		 * and added via this method so that they can be properly created, managed, updated, and destroyed.
		 * @param poolObject The PoolObject isCitrusObjectPool's value must be true to be render through the State.
		 * @return The PoolObject that you passed in. Useful for linking commands together.
		 */
		public function addPoolObject(poolObject:PoolObject):PoolObject {

			return _realState.addPoolObject(poolObject);
		}

		/**
		 * When you are ready to remove an object from getting updated, viewed, and generally being existent, call this method.
		 * Alternatively, you can just set the object's kill property to true. That's all this method does at the moment. 
		 */
		public function remove(object:CitrusObject):void {
			_realState.remove(object);
		}
		
		/**
		 * removeImmediately instaneously destroys and remove the object from the state.
		 * 
		 * While using remove() is recommended, there are specific case where this is needed.
		 * please use with care.
		 * 
		 * Warning: 
		 * - can break box2D if called directly or indirectly in a collision listener.
		 * - effects unknown with nape.
		 */
		public function removeImmediately(object:CitrusObject):void {
			_realState.removeImmediately(object);
		}

		/**
		 * Gets a reference to a CitrusObject by passing that object's name in.
		 * Often the name property will be set via a level editor such as the Flash IDE. 
		 * @param name The name property of the object you want to get a reference to.
		 */
		public function getObjectByName(name:String):CitrusObject {

			return _realState.getObjectByName(name);
		}

		/**
		 * This returns a vector of all objects of a particular name. This is useful for adding an event handler
		 * to objects that aren't similar but have the same name. For instance, you can track the collection of 
		 * coins plus enemies that you've named exactly the same. Then you'd loop through the returned vector to change properties or whatever you want.
		 * @param name The name property of the object you want to get a reference to.
		 */
		public function getObjectsByName(name:String):Vector.<CitrusObject> {

			return _realState.getObjectsByName(name);
		}

		/**
		 * Returns the first instance of a CitrusObject that is of the class that you pass in. 
		 * This is useful if you know that there is only one object of a certain time in your state (such as a "Hero").
		 * @param type The class of the object you want to get a reference to.
		 */
		public function getFirstObjectByType(type:Class):CitrusObject {

			return _realState.getFirstObjectByType(type);
		}

		/**
		 * This returns a vector of all objects of a particular type. This is useful for adding an event handler
		 * to all similar objects. For instance, if you want to track the collection of coins, you can get all objects
		 * of type "Coin" via this method. Then you'd loop through the returned array to add your listener to the coins' event.
		 * @param type The class of the object you want to get a reference to.
		 */
		public function getObjectsByType(type:Class):Vector.<CitrusObject> {

			return _realState.getObjectsByType(type);
		}

		/**
		 * Destroy all the objects added to the State and not already killed.
		 * @param except CitrusObjects you want to save.
		 */
		public function killAllObjects(...except):void {

			_realState.killAllObjects(except);
		}

		/**
		 * Contains all the objects added to the State and not killed.
		 */
		public function get objects():Vector.<CitrusObject> {
			return _realState.objects;
		}

		/**
		 * Override this method if you want a state to create an instance of a custom view. 
		 */
		protected function createView():ACitrusView {
			return new SpriteView(this);
		}
	}
}