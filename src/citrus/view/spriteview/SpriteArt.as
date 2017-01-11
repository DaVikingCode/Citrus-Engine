package citrus.view.spriteview 
{
	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.core.IScene;
	import citrus.physics.IDebugView;
	import citrus.view.ACitrusCamera;
	import citrus.view.ACitrusView;
	import citrus.view.ICitrusArt;
	import citrus.view.ISpriteView;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	/**
	 * This is the class that all art objects use for the SpriteView scene view. If you are using the SpriteView (as opposed to the blitting view, for instance),
	 * then all your graphics will be an instance of this class. 
	 * 
	 * <ul>This class does the following things:
	 * <li>Creates the appropriate graphic depending on your CitrusObject's view property (loader, sprite, or bitmap), and loads it if it is a non-embedded graphic.</li>
	 * <li>Aligns the graphic with the appropriate registration (topLeft or center).</li>
	 * <li>Calls the MovieClip's appropriate frame label based on the CitrusObject's animation property.</li>
	 * <li>Updates the graphic's properties to be in-synch with the CitrusObject's properties once per frame.</li></ul>
	 * 
	 * <p>These objects will be created by the Citrus Engine's SpriteView, so you should never make them yourself. When you use <code>view.getArt()</code> to gain access to your game's graphics
	 * (for adding click events, for instance), you will get an instance of this object. It extends Sprite, so you can do all the expected stuff with it, 
	 * such as add click listeners, change the alpha, etc.</p>
	 * 
	 **/
	public class SpriteArt extends Sprite implements ICitrusArt
	{
		// The reference to your art via the view.
		private var _content:DisplayObject;
		
		/**
		 * For objects that are loaded at runtime, this is the object that load them. Then, once they are loaded, the content
		 * property is assigned to loader.content.
		 */
		public var loader:Loader;
		
		private static var _loopAnimation:Dictionary = new Dictionary();
		
		private var _updateArtEnabled:Boolean = true;
		private var _citrusObject:ISpriteView;
		private var _physicsComponent:*;
		private var _registration:String;
		private var _view:*;
		private var _animation:String;
		public var group:uint;
		
		public function SpriteArt(object:ISpriteView = null) 
		{
			super();
			if (object)
				initialize(object);
		}
		
		public function initialize(object:ISpriteView):void {
			
			_citrusObject = object;
			
			CitrusEngine.getInstance().onPlayingChange.add(_pauseAnimation);
			
			var ceScene:IScene = CitrusEngine.getInstance().scene;
			
			this.name = (_citrusObject as CitrusObject).name;
			
			if (_loopAnimation["walk"] != true) {
				_loopAnimation["walk"] = true;
			}
			
			mouseChildren = false;
		}
		
		/**
		 * Add a loop animation to the Dictionnary.
		 * @param tab an array with all the loop animation names.
		 */
		static public function setLoopAnimations(tab:Array):void {

			for each (var animation:String in tab) {
				_loopAnimation[animation] = true;
			}
		}
		
		/**
		 * The content property is the actual display object that your game object is using. For graphics that are loaded at runtime
		 * (not embedded), the content property will not be available immediately. You can listen to the COMPLETE event on the loader
		 * (or rather, the loader's contentLoaderInfo) if you need to know exactly when the graphic will be loaded.
		 */
		public function get content():DisplayObject {
			return _content;
		}
		
		public function destroy(viewChanged:Boolean = false):void {
			
			if (viewChanged) {
				if (_content is AnimationSequence)
					(_content as AnimationSequence).destroy();
				if (_content && _content.parent)
					removeChild(_content);
			} else {
				
				CitrusEngine.getInstance().onPlayingChange.remove(_pauseAnimation);
				
				CitrusWorldClock.destroyView(_view);
				
				_view = null;
			}
		}
		
		public function moveRegistrationPoint(registrationPoint:String):void {
			
			if (registrationPoint == "topLeft") {
				_content.x = 0;
				_content.y = 0;
			} else if (registrationPoint == "center") {
				_content.x = -_content.width / 2;
				_content.y = -_content.height / 2;
			}
			
		}
		
		public function get registration():String
		{
			return _registration;
		}
		
		public function set registration(value:String):void 
		{
			if (_registration == value || !_content)
				return;
				
			_registration = value;
			
			moveRegistrationPoint(_registration);
		}
		
		public function get view():*
		{
			return _view;
		}
		
		public function set view(value:*):void
		{
			if (_view == value)
				return;
				
			if (_content && _content.parent)
			{
				_citrusObject.handleArtChanged(this as ICitrusArt);
				destroy(true);
				_content = null;
			}
			
			_view = value;
			
			if (_view)
			{				
				var tmpObj:* ;
				
				if (_view is String)
				{
					// view property is a path to an image?
					var classString:String = _view;
					var suffix:String = classString.substring(classString.length - 4).toLowerCase();
					if (suffix == ".swf" || suffix == ".png" || suffix == ".gif" || suffix == ".jpg")
					{
						loader = new Loader();
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleContentLoaded);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleContentIOError);
						loader.load(new URLRequest(classString), new LoaderContext(false, ApplicationDomain.currentDomain, null));
					}
					// view property is a fully qualified class name in string form.
					else
					{
						try
						{
							var artClass:Class = getDefinitionByName(classString) as Class;
						}catch (e:Error)
						{
							throw new Error("[SpriteArt] could not find class definition for \"" + String(classString) + "\". \n Make sure that you compile it with the project or that its the right classpath.");
						}
						tmpObj = new artClass();
						if (tmpObj is MovieClip)
						_content = new AnimationSequence(tmpObj as MovieClip);
						else if(tmpObj is DisplayObject)
						_content = tmpObj;
						else
						throw new Error("[SpriteArt] class" + String(classString) + " does not define a DisplayObject.");
					}
				}
				else if (_view is Class)
				{
					tmpObj = new _view();
					//view property is a class reference
					if(tmpObj is DisplayObject)
						_content = tmpObj;
					else
						throw new Error("[SpriteArt] " + String(_view) + " does not define a DisplayObject.");
				}
				else if (_view is DisplayObject)
				{
					// view property is a Display Object reference
					_content = _view;
					
				} 
				else{
					var isArma:Boolean;
					CitrusWorldClock.setView(_view,_content);
					if(!isArma){
						throw new Error("SpriteArt doesn't know how to create a graphic object from the provided CitrusObject " + citrusObject);
					}
				
				}
				// Call the initialize function if it exists on the custom art class.
				if (_content && _content.hasOwnProperty("initialize"))
					_content["initialize"](_citrusObject);
					
				if (_content)
				{
					moveRegistrationPoint(_citrusObject.registration);
					addChild(_content);
					_citrusObject.handleArtReady(this as ICitrusArt);
				}
					
			}
		}
		
		/**
		 * Set it to false if you want to prevent the art to be updated. Be careful its properties (x, y, ...) won't be able to change!
		 */
		public function set updateArtEnabled(value:Boolean):void
		{
			_updateArtEnabled = value;
		}
		
		public function get updateArtEnabled():Boolean
		{
			return _updateArtEnabled;
		}
		
		public function get animation():String
		{
			return _animation;
		}
		
		public function set animation(value:String):void
		{
			if (_animation == value)
				return;
			
			_animation = value;
			
			var animLoop:Boolean = _loopAnimation[_animation];
			
			if (_content is AnimationSequence)
				(_content as AnimationSequence).changeAnimation(_animation, animLoop);
			else {
				CitrusWorldClock.setAnimation(_view,value,animLoop);
			}
		}
		
		public function get citrusObject():ISpriteView
		{
			return _citrusObject;
		}
		
		public function update(sceneView:ACitrusView):void
		{
			if (_citrusObject.inverted) {

				if (scaleX > 0)
					scaleX = -scaleX;

			} else {

				if (scaleX < 0)
					scaleX = -scaleX;
			}
			
			if (_content is SpritePhysicsDebugView) {
					
				var physicsDebugArt:IDebugView = (_content as SpritePhysicsDebugView).debugView as IDebugView;
				physicsDebugArt.transformMatrix = sceneView.camera.transformMatrix;
				physicsDebugArt.visibility = _citrusObject.visible;
				
				(_content as SpritePhysicsDebugView).update();
				
			} else if (_physicsComponent) {
				
				x = _physicsComponent.x + ( (sceneView.camera.camProxy.x - _physicsComponent.x) * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
				y = _physicsComponent.y + ( (sceneView.camera.camProxy.y - _physicsComponent.y) * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
				rotation = _physicsComponent.rotation;
				
			} else {
				if (sceneView.camera.parallaxMode == ACitrusCamera.PARALLAX_MODE_DEPTH)
				{
					x = _citrusObject.x + ( (sceneView.camera.camProxy.x - _citrusObject.x) * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
					y = _citrusObject.y + ( (sceneView.camera.camProxy.y - _citrusObject.y) * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
				}
				else
				{
					x = _citrusObject.x + ( (sceneView.camera.camProxy.x + sceneView.camera.camProxy.offset.x) * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
					y = _citrusObject.y + ( (sceneView.camera.camProxy.y + sceneView.camera.camProxy.offset.y) * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
				}
				rotation = _citrusObject.rotation;
			}
			
			visible = _citrusObject.visible;
			mouseChildren = mouseEnabled = _citrusObject.touchable;
			registration = _citrusObject.registration;
			view = _citrusObject.view;
			animation = _citrusObject.animation;
			group = _citrusObject.group;
		}
		
		/**
		 * Stop or play the animation if the Citrus Engine is playing or not
		 */
		private function _pauseAnimation(value:Boolean):void {
			
			if (_content is AnimationSequence)
				value ? (_content as AnimationSequence).resume() : (_content as AnimationSequence).pause();
		}
		
		private function handleContentLoaded(e:Event):void
		{
			_content = e.target.loader.content;
			
			if (_content is Bitmap)
				(_content as Bitmap).smoothing = true;
			if (_content is MovieClip)
			{
				_content = new AnimationSequence(_content as MovieClip);
				//make the animation setter think _animation changed even if it didn't.
				var anim:String = _animation; _animation = null; animation = anim;
			}
				
			moveRegistrationPoint(_citrusObject.registration);
			addChild(_content);
			_citrusObject.handleArtReady(this as ICitrusArt);
		}
		
		private function handleContentIOError(e:IOErrorEvent):void 
		{
			throw new Error(e.text);
		}
	}

}