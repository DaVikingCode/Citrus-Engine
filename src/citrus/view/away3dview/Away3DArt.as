package citrus.view.away3dview {

	import away3d.containers.ObjectContainer3D;
	import away3d.events.LoaderEvent;
	import away3d.loaders.Loader3D;

	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.core.IState;
	import citrus.core.away3d.Away3DCitrusEngine;
	import citrus.physics.APhysicsEngine;
	import citrus.system.components.ViewComponent;
	import citrus.view.ISpriteView;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;

	/**
	 * @author Aymeric
	 */
	public class Away3DArt extends ObjectContainer3D {

		// The reference to your art via the view.
		private var _content:ObjectContainer3D;

		public var loader:Loader;
		public var loader3D:Loader3D;

		/**
		 * Set it to false if you want to prevent the art to be updated. Be careful its properties (x, y, ...) won't be able to change!
		 */
		public var updateArtEnabled:Boolean = true;

		private var _ce:CitrusEngine;

		private var _citrusObject:ISpriteView;
		private var _physicsComponent:*;
		private var _registration:String;
		private var _view:*;
		private var _animation:String;
		public var group:uint;

		public function Away3DArt(object:ISpriteView = null) {

			if (object)
				initialize(object);
		}

		public function initialize(object:ISpriteView):void {

			_citrusObject = object;

			_ce = CitrusEngine.getInstance();

			// CitrusEngine.getInstance().onPlayingChange.add(_pauseAnimation);

			var ceState:IState = _ce.state;

			if (_citrusObject is ViewComponent && ceState.getFirstObjectByType(APhysicsEngine) as APhysicsEngine)
				_physicsComponent = (_citrusObject as ViewComponent).entity.lookupComponentByName("physics");

			this.name = (_citrusObject as CitrusObject).name;
		}

		/**
		 * The content property is the actual display object that your game object is using. For graphics that are loaded at runtime
		 * (not embedded), the content property will not be available immediately. You can listen to the COMPLETE event on the loader
		 * (or rather, the loader's contentLoaderInfo) if you need to know exactly when the graphic will be loaded.
		 */
		public function get content():ObjectContainer3D {
			return _content;
		}

		public function destroy(viewChanged:Boolean = false):void {

			if (viewChanged) {
				
				/*if (_view is String)
				removeChild(_content.loaderInfo.loader);
				else
				removeChild(_content);*/

			} else {

				// CitrusEngine.getInstance().onPlayingChange.remove(_pauseAnimation);
				_view = null;
			}
		}

		public function moveRegistrationPoint(registrationPoint:String):void {

			if (registrationPoint == "topLeft") {
				// _content.x = 0;
				// _content.y = 0;
			} else if (registrationPoint == "center") {
				// _content.x = -_content.width / 2;
				// _content.y = -_content.height / 2;
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

			if (_content && _content.parent)
				destroy(true);

			_view = value;

			if (_view) {

				if (_view is String) {
					// view property is a path to an image?
					var classString:String = _view;
					var suffix:String = classString.substring(classString.length - 4).toLowerCase();

					if (suffix == ".obj") {
						loader3D = new Loader3D();
						addChild(loader3D);
						loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, handle3DContentLoaded);
						loader.addEventListener(LoaderEvent.LOAD_ERROR, handle3DContentIOError);
						loader.load(new URLRequest(classString));
					}
					
					/*if (suffix == ".swf" || suffix == ".png" || suffix == ".gif" || suffix == ".jpg") {
					loader = new Loader();
					addChild(loader);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleContentLoaded);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleContentIOError);
					loader.load(new URLRequest(classString));
					}*/
					// view property is a fully qualified class name in string form. 
					else {
						var artClass:Class = getDefinitionByName(classString) as Class;
						_content = new artClass();
						moveRegistrationPoint(_citrusObject.registration);
						addChild(_content);
					}
				} else if (_view is Class) {
					// view property is a class reference
					_content = new citrusObject.view();
					moveRegistrationPoint(_citrusObject.registration);
					addChild(_content);

				} else if (_view is ObjectContainer3D) {
					// view property is a Display Object reference
					_content = _view;
					moveRegistrationPoint(_citrusObject.registration);
					addChild(_content);
				} else
					throw new Error("Away3DArt doesn't know how to create a graphic object from the provided CitrusObject " + citrusObject);

				// Call the initialize function if it exists on the custom art class.
				if (_content && _content.hasOwnProperty("initialize"))
					_content["initialize"](_citrusObject);
			}
		}

		public function get animation():String {
			return _animation;
		}

		public function set animation(value:String):void {

			if (_animation == value)
				return;

			_animation = value;

			if (_content is AnimationSequence) {
				var animationSequence:AnimationSequence = _content as AnimationSequence;
				if (_animation != null && _animation != "" && animationSequence.mesh)
					animationSequence.changeAnimation(_animation);
			}
		}

		public function get citrusObject():ISpriteView {
			return _citrusObject;
		}

		public function update(stateView:Away3DView):void {

			if (stateView.mode == "3D") {

				if (_content is Away3DPhysicsDebugView) {

					(_content as Away3DPhysicsDebugView).update();

					if (_citrusObject.visible)
						(_content as Away3DPhysicsDebugView).debugMode(9);
					else
						(_content as Away3DPhysicsDebugView).debugMode(0);

				} else {

					x = _citrusObject.x;
					y = _citrusObject.y;
					z = _citrusObject.z;

					if (citrusObject.getBody())
						rotateTo(citrusObject.getBody().rotation.x, citrusObject.getBody().rotation.y, citrusObject.getBody().rotation.z);
				}


			} else if (stateView.mode == "2D") {

				if (_citrusObject.inverted) {

					if (scaleX > 0)
						scaleX = -scaleX;

				} else {

					if (scaleX < 0)
						scaleX = -scaleX;
				}
				// position = object position + (camera position * inverse parallax)

				var physicsDebugArt:DisplayObject;

				if (_content is Away3DPhysicsDebugView) {

					(_content as Away3DPhysicsDebugView).update();

					physicsDebugArt = _ce.stage.getChildByName("debug view") as DisplayObject;

					if (stateView.camera.target) {

						physicsDebugArt.x = stateView.viewRoot.x;
						physicsDebugArt.y = stateView.viewRoot.y;
					}

					physicsDebugArt.visible = _citrusObject.visible;

				} else if (_physicsComponent) {

					x = _citrusObject.x - (_ce as Away3DCitrusEngine).away3D.width * 0.5 + (-stateView.viewRoot.x * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
					y = -1 * (_citrusObject.y - (_ce as Away3DCitrusEngine).away3D.height * 0.5 + (-stateView.viewRoot.y * (1 - _citrusObject.parallaxY)) - _citrusObject.offsetY);
					rotationZ = -_citrusObject.rotation;

				} else {

					x = _citrusObject.x - (_ce as Away3DCitrusEngine).away3D.width * 0.5 + (-stateView.viewRoot.x * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
					y = -1 * (_citrusObject.y - (_ce as Away3DCitrusEngine).away3D.height * 0.5 + (-stateView.viewRoot.y * (1 - _citrusObject.parallaxY)) - _citrusObject.offsetY);
					rotationZ = -_citrusObject.rotation;
				}
			}

			visible = _citrusObject.visible;
			registration = _citrusObject.registration;
			view = _citrusObject.view;
			animation = _citrusObject.animation;
			group = _citrusObject.group;
		}

		/**
		 * Stop or play the animation if the Citrus Engine is playing or not
		 */
		private function _pauseAnimation(value:Boolean):void {

			if (_content is MovieClip)
				value ? MovieClip(_content).gotoAndStop(_animation) : MovieClip(_content).stop();
		}

		private function handleContentLoaded(e:Event):void {

			_content = e.target.loader.content;

			if (_content is Bitmap)
				Bitmap(_content).smoothing = true;

			moveRegistrationPoint(_citrusObject.registration);
		}

		private function handle3DContentLoaded(e:LoaderEvent):void {

			_content = e.target.loader.content;

			// moveRegistrationPoint(_citrusObject.registration);
		}

		private function handleContentIOError(e:IOErrorEvent):void {

			throw new Error(e.text);
		}

		private function handle3DContentIOError(e:LoaderEvent):void {

			throw new Error(e.message);
		}
	}
}
