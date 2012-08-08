package com.citrusengine.core
{

	import com.citrusengine.system.Entity;
	import com.citrusengine.system.components.ViewComponent;
	import com.citrusengine.view.CitrusView;
	import com.citrusengine.view.spriteview.SpriteView;

	import flash.display.Sprite;
	
	/**
	 * The State class is very important. It usually contains the logic for a particular state the game is in.
	 * There can only ever be one state running at a time. You should extend the State class
	 * to create logic and scripts for your levels. You can build one state for each level, or
	 * create a state that represents all your levels. You can get and set the reference to your active
	 * state via the CitrusEngine class.
	 */	
	public class State extends Sprite implements IState
	{
		private var _objects:Vector.<CitrusObject> = new Vector.<CitrusObject>();
		private var _view:CitrusView;
		private var _input:Input;
		
		public function State()
		{
			
		}
		
		/**
		 * Called by the Citrus Engine.
		 */		
		public function destroy():void
		{
			//Call destroy on all objects, and remove all art from the stage.
			var n:Number = _objects.length;
			for (var i:int = n - 1; i >= 0; i--)
			{
				var object:CitrusObject = _objects[i];
				object.destroy();
				
				_view.removeArt(object);
			}
			_objects.length = 0;
			_view.destroy();
		}
		
		/**
		 * Gets a reference to this state's view manager. Take a look at the class definition for more information about this. 
		 */		
		public function get view():CitrusView
		{
			return _view;
		}
		
		/**
		 * You'll most definitely want to override this method when you create your own State class. This is where you should
		 * add all your CitrusObjects and pretty much make everything. Please note that you can't successfully call add() on a 
		 * state in the constructur. You should call it in this initialize() method. 
		 */		
		public function initialize():void
		{
			_view = createView();
			_input = CitrusEngine.getInstance().input;
		}
		
		/**
		 * This method calls update on all the CitrusObjects that are attached to this state.
		 * The update method also checks for CitrusObjects that are ready to be destroyed and kills them.
		 * Finally, this method updates the Input and View managers. 
		 */		
		public function update(timeDelta:Number):void
		{
			//Call update on all objects
			var garbage:Array = [];
			var n:Number = _objects.length;
			for (var i:int = 0; i < n; i++)
			{
				var object:CitrusObject = _objects[i];
				if (object.kill)
					garbage.push(object);
				else
					object.update(timeDelta);
			}
			
			//Destroy all objects marked for destroy
			//TODO There might be a limit on the number of Box2D bodies that you can destroy in one tick?
			n = garbage.length;
			for (i = 0; i < n; i++)
			{
				var garbageObject:CitrusObject = garbage[i];
				_objects.splice(_objects.indexOf(garbageObject), 1);
				
				if (garbageObject is Entity)
					_view.removeArt((garbageObject as Entity).components["view"]);				
				else
					_view.removeArt(garbageObject);
				
				garbageObject.destroy();
			}
			
			//Update the input object
			_input.update();
			
			//Update the state's view
			_view.update();
		}
		
		/**
		 * Call this method to add a CitrusObject to this state. All visible game objects and physics objects
		 * will need to be created and added via this method so that they can be properly creatd, managed, updated, and destroyed. 
		 * @return The CitrusObject that you passed in. Useful for linking commands together.
		 */		
		public function add(object:CitrusObject):CitrusObject
		{
			_objects.push(object);
			_view.addArt(object);
			return object;
		}
		
		/**
		 * Call this method to add an Entity to this state. All entities will need to be created
		 * and added via this method so that they can be properly creatd, managed, updated, and destroyed.
		 * @param view : an Entity is designed for complex objects, most of the time they have a view component.
		 * @return The CitrusObject that you passed in. Useful for linking commands together.
		 */
		public function addEntity(entity:Entity, view:ViewComponent = null):Entity {
			
			_objects.push(entity);
			_view.addArt(view);
			return entity;
		}
		
		/**
		 * When you are ready to remove an object from getting updated, viewed, and generally being existent, call this method.
		 * Alternatively, you can just set the object's kill property to true. That's all this method does at the moment. 
		 */		
		public function remove(object:CitrusObject):void
		{
			object.kill = true;
		}
		
		/**
		 * Gets a reference to a CitrusObject by passing that object's name in.
		 * Often the name property will be set via a level editor such as the Flash IDE. 
		 * @param name The name property of the object you want to get a reference to.
		 */		
		public function getObjectByName(name:String):CitrusObject
		{
			for each (var object:CitrusObject in _objects)
			{
				if (object.name == name)
					return object;
			}
			return null;
		}
		
		/**
		 * Returns the first instance of a CitrusObject that is of the class that you pass in. 
		 * This is useful if you know that there is only one object of a certain time in your state (such as a "Hero").
		 * @param type The class of the object you want to get a reference to.
		 */		
		public function getFirstObjectByType(type:Class):CitrusObject
		{
			for each (var object:CitrusObject in _objects)
			{
				if (object is type)
					return object;
			}
			return null;
		}
		
		/**
		 * This returns an array of all objects of a particular type. This is useful for adding an event handler
		 * to all similar objects. For instance, if you want to track the collection of coins, you can get all objects
		 * of type "Coin" via this method. Then you'd loop through the returned array to add your listener to the coins' event. 
		 */		
		public function getObjectsByType(type:Class):Vector.<CitrusObject>
		{
			var objects:Vector.<CitrusObject> = new Vector.<CitrusObject>();
			
			for each (var object:CitrusObject in _objects)
			{
				if (object is type)
				{
					objects.push(object);
				}
			}
			return objects;
		}
		
		/**
		 * Override this method if you want a state to create an instance of a custom view. 
		 */		
		protected function createView():CitrusView
		{
			return new SpriteView(this);
		}
	}
}