package citrus.core {

	import citrus.physics.APhysicsEngine;
	import citrus.datastructures.PoolObject;
	import citrus.objects.APhysicsObject;
	import citrus.system.Component;
	import citrus.system.Entity;
	import citrus.system.components.ViewComponent;
	import citrus.view.ACitrusView;

	/**
	 * The MediatorState class is very important. It usually contains the logic for a particular state the game is in.
	 * You should never instanciate/extend this class by your own. It's used via a wrapper: State or StarlingState or Away3DState.
	 * There can only ever be one state running at a time. You should extend the State class
	 * to create logic and scripts for your levels. You can build one state for each level, or
	 * create a state that represents all your levels. You can get and set the reference to your active
	 * state via the CitrusEngine class.
	 */
	final public class MediatorState {

		private var _objects:Vector.<CitrusObject> = new Vector.<CitrusObject>();
		private var _poolObjects:Vector.<PoolObject> = new Vector.<PoolObject>();
		private var _view:ACitrusView;
		private var _istate:IState;

		private var _garbage:Array = [];
		private var _numObjects:uint = 0;

		public function MediatorState(istate:IState) {
			_istate = istate;
		}

		/**
		 * Called by the Citrus Engine.
		 */
		public function destroy():void {
			
			for each (var poolObject:PoolObject in _poolObjects)
				poolObject.destroy();

			_poolObjects.length = 0;
			
			_numObjects = _objects.length;
			var co:CitrusObject;
			while((co = _objects.pop()) != null)
				removeImmediately(co);
			_numObjects = _objects.length = 0;

			_view.destroy();
			
			_objects = null;
			_poolObjects = null;
			_view = null;
		}

		/**
		 * Gets a reference to this state's view manager. Take a look at the class definition for more information about this. 
		 */
		public function get view():ACitrusView {
			return _view;
		}

		public function set view(value:ACitrusView):void {
			
			_view = value;
		}

		/**
		 * This method calls update on all the CitrusObjects that are attached to this state.
		 * The update method also checks for CitrusObjects that are ready to be destroyed and kills them.
		 * Finally, this method updates the View manager. 
		 */
		public function update(timeDelta:Number):void {

			_numObjects = _objects.length;
			
			var object:CitrusObject;

			for (var i:uint = 0; i < _numObjects; ++i) { //run through objects from 'left' to 'right'
			
				object = _objects.shift(); // get first object in list
				
				if (object.kill)
					_garbage.push(object); // push object to garbage
					
				else {
					_objects.push(object); // re-insert object at the end of _objects
					
					if (object.updateCallEnabled)
						object.update(timeDelta);
				}
			}

			// Destroy all objects marked for destroy
			// TODO There might be a limit on the number of Box2D bodies that you can destroy in one tick?
			var garbageObject:CitrusObject;
			while((garbageObject = _garbage.shift()) != null)
				removeImmediately(garbageObject);

			for each (var poolObject:PoolObject in _poolObjects)
				poolObject.updatePhysics(timeDelta);

			// Update the state's view
			_view.update(timeDelta);
		}

		/**
		 * Call this method to add a CitrusObject to this state. All visible game objects and physics objects
		 * will need to be created and added via this method so that they can be properly created, managed, updated, and destroyed. 
		 * @return The CitrusObject that you passed in. Useful for linking commands together.
		 */
		public function add(object:CitrusObject):CitrusObject {
			
			if (object is Entity)
				throw new Error("Object named: " + object.name + " is an entity and should be added to the state via addEntity method.");
			
			for each (var objectAdded:CitrusObject in objects) 
				if (object == objectAdded)
					throw new Error(object.name + " is already added to the state.");
			
			if (object is APhysicsObject)
				(object as APhysicsObject).addPhysics();
			
			if(object is APhysicsEngine)
				_objects.unshift(object);
			else
				_objects.push(object);
				
			_view.addArt(object);
			
			return object;
		}

		/**
		 * Call this method to add an Entity to this state. All entities will need to be created
		 * and added via this method so that they can be properly created, managed, updated, and destroyed.
		 * @return The Entity that you passed in. Useful for linking commands together.
		 */
		public function addEntity(entity:Entity):Entity {
			
			for each (var objectAdded:CitrusObject in objects)
				if (entity == objectAdded)
					throw new Error(entity.name + " is already added to the state.");
			
			_objects.push(entity);
			
			var views:Vector.<Component> = entity.lookupComponentsByType(ViewComponent);
			if (views.length > 0)
				for each(var view:ViewComponent in views)
				{
					_view.addArt(view);
				}
					
			return entity;
		}

		/**
		 * Call this method to add a PoolObject to this state. All pool objects and  will need to be created 
		 * and added via this method so that they can be properly created, managed, updated, and destroyed.
		 * @param poolObject The PoolObject isCitrusObjectPool's value must be true to be render through the State.
		 * @return The PoolObject that you passed in. Useful for linking commands together.
		 */
		public function addPoolObject(poolObject:PoolObject):PoolObject {

			if (poolObject.isCitrusObjectPool) {
				poolObject.citrus_internal::state = _istate;
				_poolObjects.push(poolObject);

				return poolObject;

			} else return null;
		}

		/**
		 * removeImmediately instaneously destroys and remove the object from the state.
		 * 
		 * While using remove() is recommended, there are specific case where this is needed.
		 * please use with care.
		 */
		public function remove(object:CitrusObject):void {
			object.kill = true;
		}
		
		public function removeImmediately(object:CitrusObject):void {
			if(object == null)
				return;
				
			var i:uint = _objects.indexOf(object);
			
			if(i < 0)
				return;
				
			object.kill = true;
			_objects.splice(i, 1);

			if (object is Entity) {
				var views:Vector.<Component> = (object as Entity).lookupComponentsByType(ViewComponent);
				
				if (views.length > 0)
					for each(var view:ViewComponent in views)
						_view.removeArt(view);
						
			} else
				_view.removeArt(object);

			object.destroy();

			--_numObjects;
		}

		/**
		 * Gets a reference to a CitrusObject by passing that object's name in.
		 * Often the name property will be set via a level editor such as the Flash IDE. 
		 * @param name The name property of the object you want to get a reference to.
		 */
		public function getObjectByName(name:String):CitrusObject {

			for each (var object:CitrusObject in _objects) {
				if (object.name == name)
					return object;
			}
			
			if (_poolObjects.length > 0)
			{
				var poolObject:PoolObject;
				var found:Boolean = false;
				for each(poolObject in _poolObjects)
				{
					poolObject.foreachRecycled(function(pobject:*):Boolean
					{
						if (pobject is CitrusObject && pobject["name"] == name)
						{
							object = pobject;
							return found = true;
						}
						return false;
					});
					
					if (found)
						return object;
				}
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
			var object:CitrusObject;
			
			for each (object in _objects) {
				if (object.name == name)
					objects.push(object);
			}
			
			if (_poolObjects.length > 0)
			{
				var poolObject:PoolObject;
				for each(poolObject in _poolObjects)
				{
					poolObject.foreachRecycled(function(pobject:*):Boolean
					{
						if (pobject is CitrusObject && pobject["name"] == name)
							objects.push(pobject as CitrusObject);
						return false;
					});
				}
			}

			return objects;
		}

		/**
		 * Returns the first instance of a CitrusObject that is of the class that you pass in. 
		 * This is useful if you know that there is only one object of a certain time in your state (such as a "Hero").
		 * @param type The class of the object you want to get a reference to.
		 */
		public function getFirstObjectByType(type:Class):CitrusObject {
			var object:CitrusObject;
			
			for each (object in _objects) {
				if (object is type)
					return object;
			}
			
			if (_poolObjects.length > 0)
			{
				var poolObject:PoolObject;
				var found:Boolean = false;
				for each(poolObject in _poolObjects)
				{
					poolObject.foreachRecycled(function(pobject:*):Boolean
					{
						if (pobject is type)
						{
							object = pobject;
							return found = true;
						}
						return false;
					});
					
					if (found)
						return object;
				}
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
			var object:CitrusObject;
			
			for each (object in _objects) {
				if (object is type) {
					objects.push(object);
				}
			}
			
			if (_poolObjects.length > 0)
			{
				var poolObject:PoolObject;
				for each(poolObject in _poolObjects)
				{
					poolObject.foreachRecycled(function(pobject:*):Boolean
					{
						if (pobject is type)
							objects.push(pobject as CitrusObject);
						return false;
					});
				}
			}

			return objects;
		}

		/**
		 * Destroy all the objects added to the State and not already killed.
		 * @param except CitrusObjects you want to save.
		 */
		public function killAllObjects(except:Array):void {

			for each (var objectToKill:CitrusObject in _objects) {

				objectToKill.kill = true;

				for each (var objectToPreserve:CitrusObject in except) {

					if (objectToKill == objectToPreserve) {

						objectToPreserve.kill = false;
						except.splice(except.indexOf(objectToPreserve), 1);
						break;
					}
				}
			}
		}

		/**
		 * Contains all the objects added to the State and not killed.
		 */
		public function get objects():Vector.<CitrusObject> {
			return _objects;
		}
	}
}