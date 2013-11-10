package citrus.view {

	import citrus.core.CitrusObject;
	import citrus.utils.LoadManager;

	import flash.utils.Dictionary;
	
	/**
	 * This is an abstract class that is extended by any view managers, such as the SpriteView. It provides default properties
	 * and functionality that all game views need, such as camera controls, parallaxing, and graphics object displaying and management.
	 * 
	 * <p>This is the class by which you will grab a reference to the graphical representations of your Citrus Objects,
	 * which will be useful if you need to add mouse event handlers to them, or add graphics effects and filter.</p>
	 * 
	 * <p>The CitrusView was meant to be extended to support multiple rendering methods, such as blitting, or even Stage3D thanks to Starling and Away3D. 
	 * The goal is to provide as much decoupling as possible of the data/logic from the view.</p> 
	 */	
	public class ACitrusView
	{
		/**
		 * This is the manager object that keeps track of the asynchronous load progress of all graphics objects that are loading.
		 * You will want to use the load manager's bytesLoaded and bytesTotal properties to monitor when your state's graphics are
		 * completely loaded and ready for revealing.
		 * 
		 * <p>Normally, you will want to hide your state from the player's view until the load manager dispatches its onComplete event,
		 * notifying you that all graphics have been loaded. This is the object that you will want to reference in your loading screens.
		 * </p> 
		 */		
		public var loadManager:LoadManager;
		
		public var camera:ACitrusCamera;
		
		protected var _viewObjects:Dictionary = new Dictionary();
		protected var _root:*;
		protected var _viewInterface:Class;
		
		/**
		 * There is one CitrusView per state, so when a new state is initialized, it creates the view instance.
		 * You can override which type of CitrusView you would like to create via the <code>State.createView()</code> protected method.
		 * Thanks to the State class, you have access to traditional flash display list, blitting and Away3D. 
		 * If you want to target Starling you have to use the StarlingState class.
		 */		
		public function ACitrusView(root:*, viewInterface:Class)
		{
			_root = root;
			_viewInterface = viewInterface;
			
			loadManager = new LoadManager();
		}
		
		public function destroy():void
		{
			camera.destroy();
			loadManager.destroy();
		}
		
		/**
		 * This should be implemented by a CitrusView subclass. The update method's job is to iterate through all the CitrusObjects,
		 * and update their graphical counterparts on every frame. See the SpriteView's implementation of the update() method for
		 * specifics. 
		 */		
		public function update(timeDelta:Number):void
		{
		}
		
		/**
		 * The active state automatically calls this method whenever a new CitrusObject is added to it. It uses the CitrusObject
		 * to create the appropriate graphical representation. It also tells the LoadManager to begin listening to Loader events
		 * on the graphics object.
		 */		
		public function addArt(citrusObject:Object):void
		{
			if (!(citrusObject is _viewInterface))
				return;
			
			var art:Object = createArt(citrusObject);
			
			if (art)
				_viewObjects[citrusObject] = art;
			
			if (art["content"] == null)
				loadManager.add(art, citrusObject as CitrusObject);
			
		}
		
		/**
		 * This is called by the active state whenever a CitrusObject is removed from the state, effectively also removing the
		 * art representation. 
		 */		
		public function removeArt(citrusObject:Object):void
		{
			if (!(citrusObject is _viewInterface))
				return;
			
			destroyArt(citrusObject);
			delete _viewObjects[citrusObject];
		}
		
		/**
		 * Gets the graphical representation of a CitrusObject that is being managed by the active state's view.
		 * This is the method that you will want to call to get the art for a CitrusObject.
		 * 
		 * <p>For instance, if you want to perform an action when the user clicks an object, you will want to call
		 * this method to get the MovieClip that is associated with the CitrusObject that you are listening for a click upon.
		 * </p>
		 */		
		public function getArt(citrusObject:Object):Object
		{
			if (!citrusObject is _viewInterface)
				throw new Error("The object " + citrusObject + " does not have a graphical counterpart because it does not implement " + _viewInterface + ".");
			
			return _viewObjects[citrusObject];
		}
		
		/**
		 * Gets a reference to the CitrusObject associated with the provided art object.
		 * This is useful for instances such as when you need to get the CitrusObject for a graphic that got clicked on or otherwise interacted with.
		 * @param art The graphical object that represents the CitrusObject you want.
		 * @return The CitrusObject associated with the provided art object.
		 */
		public function getObjectFromArt(art:Object):Object
		{
			for (var object:Object in _viewObjects)
			{
				if (_viewObjects[object] == art)
					return object;
			}
			return null;
		}
		
		/**
		 * A CitrusView subclass will extend this method to provide specifics on how to create the graphical representation of a CitrusObject.
		 * @param citrusObject The object for which to create the art.
		 * @return The art object.
		 * 
		 */		
		protected function createArt(citrusObject:Object):Object
		{
			return null;
		}
		
		/**
		 * A CitrusView subclass will extend this method to update the graphical representation for each CitrusObject.
		 * @param citrusObject A CitrusObject whose graphical counterpart needs to be updated.
		 * @param art The graphics object that will be updated based on the provided CitrusObject.
		 */		
		protected function updateArt(citrusObject:Object, art:Object):void
		{
			
		}
		
		/**
		 * A CitrusView subclass will extend this method to destroy the art associated with the provided CitrusObject. 
		 */		
		protected function destroyArt(citrusObject:Object):void
		{
			
		}
	}
}