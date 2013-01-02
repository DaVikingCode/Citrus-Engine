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

		public var content:ObjectContainer3D;
		
		public var loader:Loader;
		public var loader3D:Loader3D;
		
		private var _ce:CitrusEngine;

		private var _citrusObject:ISpriteView;
		private var _physicsComponent:*;
		private var _registration:String;
		private var _view:*;
		private var _animation:String;
		private var _group:int;

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
				_physicsComponent = (_citrusObject as ViewComponent).entity.components["physics"];

			this.name = (_citrusObject as CitrusObject).name;
		}

		public function destroy(viewChanged:Boolean = false):void {

			if (viewChanged) {
				
				/*if (_view is String)
				removeChild(content.loaderInfo.loader);
				else
				removeChild(content);*/

			} else {

				// CitrusEngine.getInstance().onPlayingChange.remove(_pauseAnimation);
				_view = null;
			}
		}

		public function moveRegistrationPoint(registrationPoint:String):void {
			
			if (registrationPoint == "topLeft") {
				//content.x = 0;
				//content.y = 0;
			} else if (registrationPoint == "center") {
				//content.x = -content.width / 2;
				//content.y = -content.height / 2;
			}

		}

		public function get registration():String {
			return _registration;
		}

		public function set registration(value:String):void {
			
			if (_registration == value || !content)
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

			if (content && content.parent)
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
						content = new artClass();
						moveRegistrationPoint(_citrusObject.registration);
						addChild(content);
					}
				} else if (_view is Class) {
					// view property is a class reference
					content = new citrusObject.view();
					moveRegistrationPoint(_citrusObject.registration);
					addChild(content);
					
				} else if (_view is ObjectContainer3D) {
					// view property is a Display Object reference
					content = _view;
					moveRegistrationPoint(_citrusObject.registration);
					addChild(content);
				} else
					throw new Error("Away3DArt doesn't know how to create a graphic object from the provided CitrusObject " + citrusObject);

				if (content && content.hasOwnProperty("initialize"))
					content["initialize"](_citrusObject);
			}
		}

		public function get animation():String {
			return _animation;
		}

		public function set animation(value:String):void {
			
			if (_animation == value)
				return;

			_animation = value;

			if (content is AnimationSequence) {
				var animationSequence:AnimationSequence = content as AnimationSequence;
				if (_animation != null && _animation != "" && animationSequence.mesh)
					animationSequence.changeAnimation(_animation);
			}
		}

		public function get group():int {
			return _group;
		}

		public function set group(value:int):void {
			_group = value;
		}

		public function get citrusObject():ISpriteView {
			return _citrusObject;
		}

		public function update(stateView:Away3DView):void {
			
			if (stateView.mode == "3D") {
				
				if (content is Away3DPhysicsDebugView) {
				
					(content as Away3DPhysicsDebugView).update();
					
					if (_citrusObject.visible)
						(content as Away3DPhysicsDebugView).debugMode(9);
					else
						(content as Away3DPhysicsDebugView).debugMode(0);
					
				} else {
					
					x = _citrusObject.x;
					y = _citrusObject.y;
					z = _citrusObject.z;
					
					if (citrusObject.getBody())
						rotateTo(citrusObject.getBody().rotation.x, citrusObject.getBody().rotation.y, citrusObject.getBody().rotation.z);
				}
				
				
			} else if (stateView.mode == "2D") {
			
				scaleX = _citrusObject.inverted ? -1 : 1;
				// position = object position + (camera position * inverse parallax)
				
				var physicsDebugArt:DisplayObject;
				
				if (content is Away3DPhysicsDebugView) {
				
					(content as Away3DPhysicsDebugView).update();
					
					physicsDebugArt = _ce.stage.getChildByName("debug view") as DisplayObject;
					
					if (stateView.camera.target) {
						
						physicsDebugArt.x = stateView.viewRoot.x;
						physicsDebugArt.y = stateView.viewRoot.y;
					}
					
					physicsDebugArt.visible = _citrusObject.visible;
					
				} else if (_physicsComponent) {
	
					x = _citrusObject.x - (_ce as Away3DCitrusEngine).away3D.width * 0.5 + (-stateView.viewRoot.x * (1 - _citrusObject.parallax)) + _citrusObject.offsetX * scaleX;
					y = -1 * (_citrusObject.y - (_ce as Away3DCitrusEngine).away3D.height * 0.5 + (-stateView.viewRoot.y * (1 - _citrusObject.parallax)) - _citrusObject.offsetY);
					rotationZ = -_citrusObject.rotation;
	
				} else {
					
					x = _citrusObject.x - (_ce as Away3DCitrusEngine).away3D.width * 0.5 + (-stateView.viewRoot.x * (1 - _citrusObject.parallax)) + _citrusObject.offsetX * scaleX;
					y = -1 * (_citrusObject.y - (_ce as Away3DCitrusEngine).away3D.height * 0.5 + (-stateView.viewRoot.y * (1 - _citrusObject.parallax)) - _citrusObject.offsetY);
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

			if (content is MovieClip)
				value ? MovieClip(content).gotoAndStop(_animation) : MovieClip(content).stop();
		}

		private function handleContentLoaded(e:Event):void {
			
			content = e.target.loader.content;

			if (content is Bitmap)
				Bitmap(content).smoothing = true;

			moveRegistrationPoint(_citrusObject.registration);
		}
		
		private function handle3DContentLoaded(e:LoaderEvent):void {
			
			content = e.target.loader.content;
			
			//moveRegistrationPoint(_citrusObject.registration);
		}

		private function handleContentIOError(e:IOErrorEvent):void {
			
			throw new Error(e.text);
		}
		
		private function handle3DContentIOError(e:LoaderEvent):void {
			
			throw new Error(e.message);
		}
	}
}
