package citrus.view.starlingview {

	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.core.IState;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.physics.APhysicsEngine;
	import citrus.physics.IDebugView;
	import citrus.system.components.ViewComponent;
	import citrus.view.ACitrusCamera;
	import citrus.view.ACitrusView;
	import citrus.view.ICitrusArt;
	import citrus.view.ISpriteView;
	import flash.geom.Matrix;

	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;

	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.extensions.particles.PDParticleSystem;
	import starling.textures.Texture;
	import starling.utils.deg2rad;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	/**
	 * This is the class that all art objects use for the StarlingView state view. If you are using the StarlingView (as opposed to the blitting view, for instance),
	 * then all your graphics will be an instance of this class. 
	 * <ul>There are 2 ways to manage MovieClip/animations :
	 * <li>specify a "object.swf" in the view property of your object's creation.</li>
	 * <li>add an AnimationSequence to your view property of your object's creation, see the AnimationSequence for more information about it.</li>
	 * The AnimationSequence is more optimized than the .swf (which creates textures "on the fly" thanks to the DynamicAtlas class). You can also use the awesome 
	 * <a href="http://dragonbones.github.com/">DragonBones</a> 2D skeleton animation solution.</ul>
	 * 
	 * <ul>This class does the following things:
	 * 
	 * <li>Creates the appropriate graphic depending on your CitrusObject's view property (loader, sprite, or bitmap), and loads it if it is a non-embedded graphic.</li>
	 * <li>Aligns the graphic with the appropriate registration (topLeft or center).</li>
	 * <li>Calls the MovieClip's appropriate frame label based on the CitrusObject's animation property.</li>
	 * <li>Updates the graphic's properties to be in-synch with the CitrusObject's properties once per frame.</li></ul>
	 * 
	 * <p>These objects will be created by the Citrus Engine's StarlingView, so you should never make them yourself. When you use <code>view.getArt()</code> to gain access to your game's graphics
	 * (for adding click events, for instance), you will get an instance of this object. It extends Sprite, so you can do all the expected stuff with it, 
	 * such as add click listeners, change the alpha, etc.</p>
	 **/
	public class StarlingArt extends Sprite implements ICitrusArt {

		// The reference to your art via the view.
		private var _content:starling.display.DisplayObject;

		/**
		 * For objects that are loaded at runtime, this is the object that load them. Then, once they are loaded, the content
		 * property is assigned to loader.content.
		 */
		public var loader:Loader;

		// properties :

		private static var _loopAnimation:Dictionary = new Dictionary();
		
		private static var _m:Matrix = new Matrix();
		
		private var _ce:StarlingCitrusEngine;

		private var _citrusObject:ISpriteView;
		private var _physicsComponent:*;
		private var _registration:String;
		private var _view:*;
		private var _animation:String;
		public var group:uint;

		private var _texture:Texture;

		private var _viewHasChanged:Boolean = false; // when the view changed, the animation wasn't updated if it was the same name. This var fix that.
		private var _updateArtEnabled:Boolean = true;

		public function StarlingArt(object:ISpriteView = null) {
			
			_ce = CitrusEngine.getInstance() as StarlingCitrusEngine;

			if (object)
				initialize(object);
		}

		public function initialize(object:ISpriteView):void {

			_citrusObject = object;

			_ce.onPlayingChange.add(_pauseAnimation);

			var ceState:IState = _ce.state;

			if (_citrusObject is ViewComponent && ceState.getFirstObjectByType(APhysicsEngine) as APhysicsEngine)
				_physicsComponent = (_citrusObject as ViewComponent).entity.lookupComponentByName("physics");

			this.name = (_citrusObject as CitrusObject).name;

			if (_loopAnimation["walk"] != true) {
				_loopAnimation["walk"] = true;
			}
		}

		/**
		 * The content property is the actual display object that your game object is using. For graphics that are loaded at runtime
		 * (not embedded), the content property will not be available immediately. You can listen to the COMPLETE event on the loader
		 * (or rather, the loader's contentLoaderInfo) if you need to know exactly when the graphic will be loaded.
		 */
		public function get content():starling.display.DisplayObject {
			return _content;
		}

		public function destroy():void {

			if (_viewHasChanged)
				removeChild(_content);
			else
				_ce.onPlayingChange.remove(_pauseAnimation);

			if (_content is starling.display.MovieClip) {

				Starling.juggler.remove(_content as starling.display.MovieClip);
				_content.dispose();

			} else if (_content is AnimationSequence) {

				(_content as AnimationSequence).destroy();
				_content.dispose();

			} else if (_content is Image) {

				if (_texture)
					_texture.dispose();

				_content.dispose();

			} else if (_content is PDParticleSystem) {

				Starling.juggler.remove(_content as PDParticleSystem);
				(_content as PDParticleSystem).stop();
				_content.dispose();

			} else if (_content is StarlingTileSystem) {
				(_content as StarlingTileSystem).destroy();
				_content.dispose();

			} else if (_view is Armature) {
				WorldClock.clock.remove(_view);
				(_view as Armature).dispose();
				_content.dispose();

			} else if (_content is starling.display.DisplayObject) {
									
				_content.dispose();
			}
			
			_viewHasChanged = false;
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
		 * Determines animations playing in loop. You can add one in your state class: <code>StarlingArt.setLoopAnimations(["walk", "climb"])</code>;
		 */
		static public function get loopAnimation():Dictionary {
			return _loopAnimation;
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

		public function get registration():String {
			return _registration;
		}

		public function set registration(value:String):void {

			if (_registration == value || !_content)
				return;

			_registration = value;

			moveRegistrationPoint(_registration);
		}

		public function get view():* {
			return _view;
		}

		public function set view(value:*):void {

			if (_view == value)
				return;

			if (_content && _content.parent) {
				_viewHasChanged = true;
				_citrusObject.handleArtChanged(this as ICitrusArt);
				destroy();
				_content = null;
			}
			
			_view = value;			
			
			if (_view) {
				
				var tmpObj:*;
				var contentChanged:Boolean = true;
				
				if (_view is String) {
					// view property is a path to an image?
					var classString:String = _view;
					var suffix:String = classString.substring(classString.length - 4).toLowerCase();
					var url:URLRequest = new URLRequest(classString);
					
					if (suffix == ".swf" || suffix == ".png" || suffix == ".gif" || suffix == ".jpg") {
						
						loader = new Loader();
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleContentLoaded);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleContentIOError);
						loader.load(url, new LoaderContext(false, ApplicationDomain.currentDomain, null));
						return;
					}
					else if (suffix == ".atf") {
						
						var urlLoader:URLLoader = new URLLoader();
						urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
						urlLoader.addEventListener(Event.COMPLETE, handleBinaryContentLoaded);
						urlLoader.load(url);
						return;
					}
					// view property is a fully qualified class name in string form. 
					else {
						
						try
						{
							var artClass:Class = getDefinitionByName(classString) as Class;
						}catch (e:Error)
						{
							throw new Error("StarlingArt could not find class definition for \"" + String(classString) + "\". \n Make sure that you compile it with the project or that its the right classpath.");
						}
							
						tmpObj = new artClass();
						
						if (tmpObj is flash.display.MovieClip) {
							_content = AnimationSequence.fromMovieClip(tmpObj, _animation, 30);
						} 
						else if (tmpObj is flash.display.Bitmap) {
							_content = new Image(_texture = Texture.fromBitmap(tmpObj, false, false, _ce.scaleFactor));
						}
						else if (tmpObj is BitmapData) {
							_content = new Image(_texture = Texture.fromBitmapData(tmpObj, false, false, _ce.scaleFactor));
						}
						else if(tmpObj is starling.display.DisplayObject) {
							_content = tmpObj;						
						}

					}

				} else if (_view is Class) {
					
					tmpObj = new _view();
					if (tmpObj is flash.display.MovieClip) {
						_content = AnimationSequence.fromMovieClip(tmpObj, _animation, 30);
					} 
					else if (tmpObj is flash.display.Bitmap) {
						_content = new Image(_texture = Texture.fromBitmap(tmpObj, false, false, _ce.scaleFactor));
					}
					else if (tmpObj is BitmapData) {
						_content = new Image(_texture = Texture.fromBitmapData(tmpObj, false, false, _ce.scaleFactor));
					}
					else if(tmpObj is starling.display.DisplayObject) {
						_content = tmpObj;						
					}

				} else if (_view is flash.display.MovieClip) {
					_content = AnimationSequence.fromMovieClip(_view, _animation, 30);
					
				} else if (_view is starling.display.DisplayObject) {
					
					_content = _view;
					
					if (_view is starling.display.MovieClip)
						Starling.juggler.add(_content as starling.display.MovieClip);
					else if (_view is PDParticleSystem)
						Starling.juggler.add(_content as PDParticleSystem);

				} else if (_view is Texture) {
					_content = new Image(_texture = _view);
					
				} else if (_view is Bitmap) {
					// TODO : cut bitmap if size > 2048 * 2048, use StarlingTileSystem?
					_content = new Image(_texture = Texture.fromBitmap(_view, false, false, _ce.scaleFactor));
					
				} else if (_view is Armature) {
					_content = (_view as Armature).display as Sprite;
					WorldClock.clock.add(_view);
					
				} else if (_view is uint) {
					
					// TODO : manage radius -> circle
					_content = new Quad(_citrusObject.width, _citrusObject.height, _view);
				} else
					contentChanged = false;
				
				if(_content == null || contentChanged == false)
					throw new Error("StarlingArt doesn't know how to create a graphic object from the provided CitrusObject " + citrusObject);
				else
				{
					moveRegistrationPoint(_citrusObject.registration);
					
					if (_content.hasOwnProperty("initialize"))
					_content["initialize"](_citrusObject);
					
					_citrusObject.handleArtReady(this as ICitrusArt);
					
					addChild(_content);
				}
					
			}
		}

		public function get animation():String {
			return _animation;
		}

		public function set animation(value:String):void {

			if (_animation == value && !_viewHasChanged)
				return;

			_animation = value;

			if (_animation != null && _animation != "") {

				var animLoop:Boolean = _loopAnimation[_animation];

				if (_content is AnimationSequence)
					(_content as AnimationSequence).changeAnimation(_animation, animLoop);
				else if (_view is Armature)
					(_view as Armature).animation.gotoAndPlay(value, -1, -1, animLoop ? 0 : 1);
			}

			_viewHasChanged = false;
		}

		public function get citrusObject():ISpriteView {
			return _citrusObject;
		}

		public function update(stateView:ACitrusView):void {
			if (_citrusObject.inverted) {

				if (scaleX > 0)
					scaleX = -scaleX;

			} else {

				if (scaleX < 0)
					scaleX = -scaleX;
			}

			if (_content is StarlingPhysicsDebugView) {

				var physicsDebugArt:IDebugView = (_content as StarlingPhysicsDebugView).debugView as IDebugView; 
				
				_m.copyFrom(stateView.camera.transformMatrix);
				_m.scale(Starling.current.viewPort.width / Starling.current.stage.stageWidth, Starling.current.viewPort.height / Starling.current.stage.stageHeight);
				_m.translate(Starling.current.viewPort.x, Starling.current.viewPort.y);
				physicsDebugArt.transformMatrix = _m;
				physicsDebugArt.visibility = _citrusObject.visible;
				
				(_content as StarlingPhysicsDebugView).update();

			} else if (_physicsComponent) {

				x = _physicsComponent.x + ( (stateView.camera.camProxy.x - _physicsComponent.x) * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
				y = _physicsComponent.y + ( (stateView.camera.camProxy.y - _physicsComponent.y) * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
				rotation = deg2rad(_physicsComponent.rotation);

			} else {
				if (stateView.camera.parallaxMode == ACitrusCamera.PARALLAX_MODE_DEPTH)
				{
					x = _citrusObject.x + ( (stateView.camera.camProxy.x - _citrusObject.x) * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
					y = _citrusObject.y + ( (stateView.camera.camProxy.y - _citrusObject.y) * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
				}
				else
				{
					x = _citrusObject.x + ( (stateView.camera.camProxy.x + stateView.camera.camProxy.offset.x) * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
					y = _citrusObject.y + ( (stateView.camera.camProxy.y + stateView.camera.camProxy.offset.y) * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
				}
				rotation = deg2rad(_citrusObject.rotation);
			}

			visible = _citrusObject.visible;
			touchable = _citrusObject.touchable;
			registration = _citrusObject.registration;
			view = _citrusObject.view;
			animation = _citrusObject.animation;
			group = _citrusObject.group;
		}

		/**
		 * Remove or add to the Juggler if the Citrus Engine is playing or not
		 */
		private function _pauseAnimation(value:Boolean):void {

			if (_content is starling.display.MovieClip)
				value ? Starling.juggler.add(_content as starling.display.MovieClip) : Starling.juggler.remove(_content as starling.display.MovieClip);
			else if (_content is AnimationSequence)
				(_content as AnimationSequence).pauseAnimation(value);
			else if (_content is PDParticleSystem)
				value ? Starling.juggler.add(_content as PDParticleSystem) : Starling.juggler.remove(_content as PDParticleSystem);
			else if (_view is Armature)
				value ? (_view as Armature).animation.play() : (_view as Armature).animation.stop();
		}

		private function handleContentLoaded(evt:Event):void {

			loader = null;
			
			(evt.target.loader as Loader).removeEventListener(Event.COMPLETE, handleContentLoaded);
			(evt.target.loader as Loader).removeEventListener(IOErrorEvent.IO_ERROR, handleContentIOError);
			
			if (!(evt.target.loader.content is flash.display.MovieClip ||
				evt.target.loader.content is Bitmap))
			{
				throw new Error("StarlingArt: Loaded content for "+(_citrusObject as CitrusObject).name+" can only be a MovieClip or a Bitmap");
			}
			
			if (_content && _content.parent)
			{
				_viewHasChanged = true;
				destroy();
			}
			
			if (evt.target.loader.content is flash.display.MovieClip)
				_content = AnimationSequence.fromMovieClip(evt.target.loader.content, _animation, 30);
			else if (evt.target.loader.content is Bitmap)
				_content = new Image(_texture = Texture.fromBitmap(evt.target.loader.content, false, false, _ce.scaleFactor));
			
			moveRegistrationPoint(_citrusObject.registration);
			_citrusObject.handleArtReady(this as ICitrusArt);
			addChild(_content);
		}
		
		/**
		 * Handles loading of the atf assets.
		 */
		private function handleBinaryContentLoaded(evt:Event):void {
			
			loader = null;
			
			evt.target.removeEventListener(Event.COMPLETE, handleBinaryContentLoaded);
			
			_texture = Texture.fromAtfData(evt.target.data as ByteArray, _ce.scaleFactor, false);
			_content = new Image(_texture);
			
			moveRegistrationPoint(_citrusObject.registration);
			_citrusObject.handleArtReady(this as ICitrusArt);
			addChild(_content);
		}

		private function handleContentIOError(evt:IOErrorEvent):void {
			loader = null;
			throw new Error(evt.text);
		}
		
		/**
		 * Set it to false if you want to prevent the art to be updated. Be careful its properties (x, y, ...) won't be able to change!
		 */
		public function get updateArtEnabled():Boolean {
			return _updateArtEnabled;
		}
		
		/**
		 * Set it to false also made the Sprite flattened!
		 */
		public function set updateArtEnabled(value:Boolean):void {
			_updateArtEnabled = value;
			_updateArtEnabled ? unflatten() : flatten();
		}

	}
}
