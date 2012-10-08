package com.citrusengine.view.away3dview {

	import Box2DAS.Dynamics.b2DebugDraw;

	import away3d.containers.ObjectContainer3D;
	import away3d.events.LoaderEvent;
	import away3d.loaders.Loader3D;

	import awayphysics.debug.AWPDebugDraw;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.core.IState;
	import com.citrusengine.core.State;
	import com.citrusengine.objects.AwayPhysicsObject;
	import com.citrusengine.objects.platformer.awayphysics.IPlatformer;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.physics.Nape;
	import com.citrusengine.system.components.ViewComponent;
	import com.citrusengine.view.ISpriteView;

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

			if (_citrusObject is ViewComponent && (ceState.getFirstObjectByType(Box2D) as Box2D || ceState.getFirstObjectByType(Nape) as Nape))
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
				} else {
					throw new Error("Away3DArt doesn't know how to create a graphic object from the provided CitrusObject " + citrusObject);
					return;
				}

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
				
				if (content is AwayPhysicsDebugArt) {
					
					(content as AwayPhysicsDebugArt).update();
					
					var awayPhysicsDebugArt:AWPDebugDraw = (content as AwayPhysicsDebugArt).debugDrawer;
					
					if (_citrusObject.visible)
						awayPhysicsDebugArt.debugMode = AWPDebugDraw.DBG_DrawTransform + 1;
					else
						awayPhysicsDebugArt.debugMode = 0;
					
				} else {
					
					x = _citrusObject.x;
					y = _citrusObject.y;
					z = _citrusObject.z;
					
					var physicsObject3D:AwayPhysicsObject = _citrusObject as AwayPhysicsObject;
					var platformerPhysicsObject3D:IPlatformer = (_citrusObject as AwayPhysicsObject) as IPlatformer;
					
					if (physicsObject3D && physicsObject3D.body)
						rotateTo(physicsObject3D.body.rotation.x, physicsObject3D.body.rotation.y, physicsObject3D.body.rotation.z);
					else if (physicsObject3D && platformerPhysicsObject3D.character)
						rotateTo(platformerPhysicsObject3D.ghostObject.rotation.x, platformerPhysicsObject3D.ghostObject.rotation.y, platformerPhysicsObject3D.ghostObject.rotation.z);
				}
				
				
			} else if (stateView.mode == "2D") {
			
				scaleX = _citrusObject.inverted ? -1 : 1;
				// position = object position + (camera position * inverse parallax)
				
				if (content is Box2DDebugArt) {
					
					(content as Box2DDebugArt).update();
					
					var box2dDebugArt:b2DebugDraw = (_ce.state as State).getChildByName("Box2D debug view") as b2DebugDraw;
					
					if (stateView.cameraTarget) {
						
						box2dDebugArt.x = stateView.container.x;
						box2dDebugArt.y = stateView.container.y;
					}
					
					box2dDebugArt.visible = _citrusObject.visible;
					
				} else if (content is NapeDebugArt) {
					
					(content as NapeDebugArt).update();
					
					var napeDebugArt:DisplayObject = (_ce.state as State).getChildByName("Nape debug view") as DisplayObject;
					
					if (stateView.cameraTarget) {
						
						napeDebugArt.x = stateView.container.x;
						napeDebugArt.y = stateView.container.y;
					}
					
					napeDebugArt.visible = _citrusObject.visible;
					
				} else if (_physicsComponent) {
	
					x = _citrusObject.x - stateView.viewRoot.width * 0.5 + (-stateView.container.x * (1 - _citrusObject.parallax)) + _citrusObject.offsetX * scaleX;
					y = -1 * (_citrusObject.y - stateView.viewRoot.height * 0.5 + (-stateView.container.y * (1 - _citrusObject.parallax)) - _citrusObject.offsetY);
					rotationZ = -_citrusObject.rotation;
	
				} else {
					
					x = _citrusObject.x - stateView.viewRoot.width * 0.5 + (-stateView.container.x * (1 - _citrusObject.parallax)) + _citrusObject.offsetX * scaleX;
					y = -1 * (_citrusObject.y - stateView.viewRoot.height * 0.5 + (-stateView.container.y * (1 - _citrusObject.parallax)) - _citrusObject.offsetY);
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
