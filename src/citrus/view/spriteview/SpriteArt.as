package citrus.view.spriteview 
{

	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.core.IState;
	import citrus.physics.APhysicsEngine;
	import citrus.physics.IDebugView;
	import citrus.system.components.ViewComponent;
	import citrus.view.ISpriteView;
	import flash.geom.Point;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;

	/**
	 * This is the class that all art objects use for the SpriteView state view. If you are using the SpriteView (as opposed to the blitting view, for instance),
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
	public class SpriteArt extends Sprite
	{
		// The reference to your art via the view.
		private var _content:DisplayObject;
		
		/**
		 * For objects that are loaded at runtime, this is the object that load them. Then, once they are loaded, the content
		 * property is assigned to loader.content.
		 */
		public var loader:Loader;
		
		/**
		 * Set it to false if you want to prevent the art to be updated. Be careful its properties (x, y, ...) won't be able to change!
		 */
		public var updateArtEnabled:Boolean = true;
		
		private var _citrusObject:ISpriteView;
		private var _physicsComponent:*;
		private var _registration:String;
		private var _view:*;
		private var _animation:String;
		public var group:uint;
		
		public function SpriteArt(object:ISpriteView = null) 
		{
			if (object)
				initialize(object);
		}
		
		public function initialize(object:ISpriteView):void {
			
			_citrusObject = object;
			
			CitrusEngine.getInstance().onPlayingChange.add(_pauseAnimation);
			
			var ceState:IState = CitrusEngine.getInstance().state;
			
			if (_citrusObject is ViewComponent && ceState.getFirstObjectByType(APhysicsEngine) as APhysicsEngine)
				_physicsComponent = (_citrusObject as ViewComponent).entity.lookupComponentByName("physics");
			
			this.name = (_citrusObject as CitrusObject).name;
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
				
				if (_view is String)
					removeChild(_content.loaderInfo.loader);
				else if (_content && _content.parent)
					removeChild(_content.parent);
				
			} else {
				
				CitrusEngine.getInstance().onPlayingChange.remove(_pauseAnimation);
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
				destroy(true);
			
			_view = value;
			
			if (_view)
			{				
				
				if (_view is String)
				{
					// view property is a path to an image?
					var classString:String = _view;
					var suffix:String = classString.substring(classString.length - 4).toLowerCase();
					if (suffix == ".swf" || suffix == ".png" || suffix == ".gif" || suffix == ".jpg")
					{
						loader = new Loader();
						addChild(loader);
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleContentLoaded);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleContentIOError);
						loader.load(new URLRequest(classString));
					}
					// view property is a fully qualified class name in string form.
					else
					{
						var artClass:Class = getDefinitionByName(classString) as Class;
						_content = new artClass();
						moveRegistrationPoint(_citrusObject.registration);
						addChild(_content);
					}
				}
				else if (_view is Class)
				{
					//view property is a class reference
					_content = new citrusObject.view();
					moveRegistrationPoint(_citrusObject.registration);
					addChild(_content);
				}
				else if (_view is DisplayObject)
				{
					// view property is a Display Object reference
					_content = _view;
					moveRegistrationPoint(_citrusObject.registration);
					addChild(_content);
				} 
				else
					throw new Error("SpriteArt doesn't know how to create a graphic object from the provided CitrusObject " + citrusObject);
				
				// Call the initialize function if it exists on the custom art class.
				if (_content && _content.hasOwnProperty("initialize"))
					_content["initialize"](_citrusObject);
					
			}
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
			
			if (_content is MovieClip)
			{
				var mc:MovieClip = _content as MovieClip;
				if (_animation != null && _animation != "" && hasAnimation(_animation))
					mc.gotoAndStop(_animation);
			}
		}
		
		public function get citrusObject():ISpriteView
		{
			return _citrusObject;
		}
		
		public function update(stateView:SpriteView):void
		{
			if (_citrusObject.inverted) {

				if (scaleX > 0)
					scaleX = -scaleX;

			} else {

				if (scaleX < 0)
					scaleX = -scaleX;
			}
			
			var cam:SpriteCamera = (stateView.camera as SpriteCamera);
			var camPosition:Point = cam.camPos;
			
			if (_content is IDebugView) {
				
				(_content as IDebugView).update();
				
			} else if (_physicsComponent) {
				
				x = _physicsComponent.x + (camPosition.x * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
				y = _physicsComponent.y + (camPosition.y * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
				rotation = _physicsComponent.rotation;
				
			} else {
				
				x = _citrusObject.x + (camPosition.x * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
				y = _citrusObject.y + (camPosition.y * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
				rotation = _citrusObject.rotation;
			}
			
			visible = _citrusObject.visible;
			mouseChildren = mouseEnabled = _citrusObject.touchable;
			registration = _citrusObject.registration;
			view = _citrusObject.view;
			animation = _citrusObject.animation;
			group = _citrusObject.group;
		}
		
		public function hasAnimation(animation:String):Boolean
		{
			for each (var anim:FrameLabel in (_content as MovieClip).currentLabels)
			{
				if (anim.name == animation)
					return true;
			}
			
			return false;
		}
		
		/**
		 * Stop or play the animation if the Citrus Engine is playing or not
		 */
		private function _pauseAnimation(value:Boolean):void {
			
			if (_content is MovieClip)
				if (hasAnimation(_animation))
				value ? (_content as MovieClip).gotoAndStop(_animation) : (_content as MovieClip).stop();
		}
		
		private function handleContentLoaded(e:Event):void
		{
			_content = e.target.loader.content;
			
			if (_content is Bitmap)
				(_content as Bitmap).smoothing = true;
				
			moveRegistrationPoint(_citrusObject.registration);
		}
		
		private function handleContentIOError(e:IOErrorEvent):void 
		{
			throw new Error(e.text);
		}
	}

}