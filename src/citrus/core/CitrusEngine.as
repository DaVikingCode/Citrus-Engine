package citrus.core {

	import citrus.input.Input;
	import citrus.sounds.SoundManager;
	import citrus.utils.AGameData;
	import citrus.utils.LevelManager;

	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.geom.Matrix;
	import flash.media.SoundMixer;
	
	/**
	 * CitrusEngine is the top-most class in the library. When you start your project, you should make your
	 * document class extend this class unless you use Starling. In this case extends StarlingCitrusEngine.
	 * 
	 * <p>CitrusEngine is a singleton so that you can grab a reference to it anywhere, anytime. Don't abuse this power,
	 * but use it wisely. With it, you can quickly grab a reference to the manager classes such as current Scene, Input and SoundManager.</p>
	 */	
	public class CitrusEngine extends MovieClip
	{
		public static const VERSION:String = "3.1.12";
				
		private static var _instance:CitrusEngine;
		
		/**
		 * DEBUG is not used by CitrusEngine, it is there for your own convenience
		 * so you can access it wherever the _ce 'shortcut' is. defaults to false.
		 */
		public var DEBUG:Boolean = false;
		
		/**
		 * Used to pause animations in SpriteArt and StarlingArt.
		 */
		public var onPlayingChange:Signal;
		
		/**
		 * called after a stage resize event
		 * signal passes the new screenWidth and screenHeight as arguments.
		 */
		public var onStageResize:Signal;
		
		/**
		 * You may use a class to store your game's data, this is already an abstract class made for that. 
		 * It's also a dynamic class, so you won't have problem to access information in its extended class.
		 */
		public var gameData:AGameData;
		
		/**
		 * You may use the Citrus Engine's level manager if you have several levels to handle. Take a look on its class for more information.
		 */
		public var levelManager:LevelManager;
		
		/**
		 * the matrix that describes the transformation required to go from scene container space to flash stage space.
		 * note : this does not include the camera's transformation.
		 * the transformation required to go from flash stage to in scene space when a camera is active would be obtained with
		 * var m:Matrix = camera.transformMatrix.clone();
		 * m.concat(_ce.transformMatrix);
		 * 
		 * using flash only, the scene container is aligned and of the same scale as the flash stage, so this is not required.
		 */
		public const transformMatrix:Matrix = new Matrix();
		
		protected var _scene:IScene;
		protected var _newScene:IScene;
		protected var _sceneTransitionning:IScene;
		protected var _futureScene:IScene;
		protected var _sceneDisplayIndex:uint = 0;
		protected var _playing:Boolean = true;
		protected var _input:Input;
		
		protected var _fullScreen:Boolean = false;
		protected var _screenWidth:int = 0;
		protected var _screenHeight:int = 0;
		
		private var _startTime:Number;
		private var _gameTime:Number;
		private var _nowTime:Number;
		protected var _timeDelta:Number;
		
		private var _sound:SoundManager;
		private var _console:Console;
		
		public static function getInstance():CitrusEngine
		{
			return _instance;
		}
		
		/**
		 * Flash's innards should be calling this, because you should be extending your document class with it.
		 */		
		public function CitrusEngine()
		{
			_instance = this;
			
			onPlayingChange = new Signal(Boolean);
			onStageResize = new Signal(int, int);
			
			onPlayingChange.add(handlePlayingChange);
			
			// on iOS if the physical button is off, mute the sound
			if ("audioPlaybackMode" in SoundMixer)
				try { SoundMixer.audioPlaybackMode = "ambient"; }
					catch(e:ArgumentError) {
							trace("[CitrusEngine] could not set SoundMixer.audioPlaybackMode to ambient.");
						}
			
			//Set up console
			_console = new Console(9); //Opens with tab key by default
			_console.onShowConsole.add(handleShowConsole);
			_console.addCommand("set", handleConsoleSetCommand);
			_console.addCommand("get", handleConsoleGetCommand);
			addChild(_console);
			
			//timekeeping
			_gameTime = _startTime = new Date().time;
			
			//Set up input
			_input = new Input();
			
			//Set up sound manager
			_sound = SoundManager.getInstance();
			
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		/**
		 * Destroy the Citrus Engine, use it only if the Citrus Engine is just a part of your project and not your Main class.
		 */
		public function destroy():void {
			
			onPlayingChange.removeAll();
			onStageResize.removeAll();
			
			stage.removeEventListener(Event.ACTIVATE, handleStageActivated);
			stage.removeEventListener(Event.DEACTIVATE, handleStageDeactivated);
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, handleStageFullscreen);
			stage.removeEventListener(Event.RESIZE, handleStageResize);
			
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			if (_scene)
				_scene.destroy();
				
			_console.destroy();
			removeChild(_console);
			
			_input.destroy();
			_sound.destroy();
		}
		
		/**
		 * A reference to the active game scene. Actually, that's not entirely true. If you've recently changed scenes and a tick
		 * hasn't occurred yet, then this will reference your new scene; this is because actual scene-changes only happen pre-tick.
		 * That way you don't end up changing scenes in the middle of a scene's tick, effectively fucking stuff up.
		 * 
		 * If you had set up a futureScene, accessing the scene it wil return you the futureScene to enable some objects instantiation 
		 * (physics, views, etc).
		 */		
		public function get scene():IScene
		{
			if (_futureScene)
				return _futureScene;
						
			else if (_newScene)
				return _newScene;
						
			else 
				return _scene;
		}
		
		/**
		 * We only ACTUALLY change scenes on enter frame so that we don't risk changing scenes in the middle of a scene update.
		 * However, if you use the scene getter, it will grab the new one for you, so everything should work out just fine.
		 */		
		public function set scene(value:IScene):void
		{
			_newScene = value;
		}
		
		/**
		 * Get a direct access to the futureScene. Note that the futureScene is really set up after an update so it isn't 
		 * available via scene getter before a scene update.
		 */
		public function get futureScene():IScene {
			return _futureScene ? _futureScene : _sceneTransitionning;
		}
		
		/**
		 * The futureScene variable is useful if you want to have two scenes running at the same time for making a transition. 
		 * Note that the futureScene is added with the same index than the scene, so it will be behind unless the scene runs 
		 * on Starling and the futureScene on the display list (which is absolutely doable).
		 */
		public function set futureScene(value:IScene):void {
			_sceneTransitionning = value;
		}
		
		/**
		 * @return true if the Citrus Engine is playing
		 */		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		/**
		 * Runs and pauses the game loop. Assign this to false to pause the game and stop the
		 * <code>update()</code> methods from being called.
		 * Dispatch the Signal onPlayingChange with the value.
		 * CitrusEngine calls its own handlePlayingChange listener to
		 * 1.reset all input actions when "playing" changes
		 * 2.pause or resume all sounds.
		 * override handlePlayingChange to override all or any of these behaviors.
		 */
		public function set playing(value:Boolean):void
		{
			if (value == _playing)
				return;
				
			_playing = value;
			if (_playing)
				_gameTime = new Date().time;
			onPlayingChange.dispatch(_playing);
		}
		
		/**
		 * You can get access to the Input manager object from this reference so that you can see which keys are pressed and stuff. 
		 */		
		public function get input():Input
		{
			return _input;
		}
		
		/**
		 * A reference to the SoundManager instance. Use it if you want.
		 */		
		public function get sound():SoundManager
		{
			return _sound;
		}
		
		/**
		 * A reference to the console, so that you can add your own console commands. See the class documentation for more info.
		 * The console can be opened by pressing the tab key.
		 * There is one console command built-in by default, but you can add more by using the addCommand() method.
		 * 
		 * <p>To try it out, try using the "set" command to change a property on a CitrusObject. You can toggle Box2D's
		 * debug draw visibility like this "set Box2D visible false". If your Box2D CitrusObject instance is not named
		 * "Box2D", use the name you gave it instead.</p>
		 */		
		public function get console():Console
		{
			return _console;
		}
		
		/**
		 * Set up things that need the stage access.
		 */
		protected function handleAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, handleStageDeactivated);
			stage.addEventListener(Event.ACTIVATE, handleStageActivated);
			
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleStageFullscreen);
			stage.addEventListener(Event.RESIZE, handleStageResize);
			
			_fullScreen = (stage.displayState == StageDisplayState.FULL_SCREEN || stage.displayState  == StageDisplayState.FULL_SCREEN_INTERACTIVE);
			resetScreenSize();
			
			_input.initialize();
			
			this.initialize();
		}
		
		/**
		 * Called when CitrusEngine is added to the stage and ready to run.
		 */
		public function initialize():void {
		}
		
		protected function handleStageFullscreen(e:FullScreenEvent):void
		{
			_fullScreen = e.fullScreen;
		}
		
		protected function handleStageResize(e:Event):void
		{
			resetScreenSize();
			onStageResize.dispatch(_screenWidth, _screenHeight);
		}
		
		/**
		 * on resize or fullscreen this is called and makes sure _screenWidth/_screenHeight is correct,
		 * it can be overriden to update other values that depend on the values of _screenWidth/_screenHeight.
		 */
		protected function resetScreenSize():void
		{
			_screenWidth = stage.stageWidth;
			_screenHeight = stage.stageHeight;
		}
		
		/**
		 * called when the value of 'playing' changes.
		 * resets input actions , pauses/resumes all sounds by default.
		 */
		protected function handlePlayingChange(value:Boolean):void
		{
			if(input)
				input.resetActions();
			
			if (sound)
				if(value)
					sound.resumeAll();
				else
					sound.pauseAll();
		}
		
		/**
		 * This is the game loop. It switches scenes if necessary, then calls update on the current scene.
		 */		
		//TODO The CE updates use the timeDelta to keep consistent speed during slow framerates. However, Box2D becomes unstable when changing timestep. Why?
		protected function handleEnterFrame(e:Event):void
		{
			//Update the scene
			if (_scene && _playing)
			{
				_nowTime = new Date().time;
				_timeDelta = (_nowTime - _gameTime) * 0.001;
				_gameTime = _nowTime;
				
				_scene.update(_timeDelta);
				if (_futureScene)
					_futureScene.update(_timeDelta);
			}
			
			_input.citrus_internal::update();
			
		}
		
		/**
		 * Set CitrusEngine's playing to false. Every update methods aren't anymore called.
		 */
		protected function handleStageDeactivated(e:Event):void
		{
			playing = false;
		}
		
		/**
		 * Set CitrusEngine's playing to true. The main loop is performed.
		 */
		protected function handleStageActivated(e:Event):void
		{
			playing = true;
		}
		
		private function handleShowConsole():void
		{
			if (_input.enabled)
			{
				_input.enabled = false;
				_console.onHideConsole.addOnce(handleHideConsole);
			}
		}
		
		private function handleHideConsole():void
		{
			_input.enabled = true;
		}
		
		private function handleConsoleSetCommand(objectName:String, paramName:String, paramValue:String):void
		{
			var object:CitrusObject = _scene.getObjectByName(objectName);
			
			if (!object)
			{
				trace("Warning: There is no object named " + objectName);
				return;
			}
			
			var value:Object;
			if (paramValue == "true")
				value = true;
			else if (paramValue == "false")
				value = false;
			else
				value = paramValue;
			
			if (object.hasOwnProperty(paramName))
				object[paramName] = value;
			else
				trace("Warning: " + objectName + " has no parameter named " + paramName + ".");
		}
		
		private function handleConsoleGetCommand(objectName:String, paramName:String):void
		{
			var object:CitrusObject = _scene.getObjectByName(objectName);
			
			if (!object)
			{
				trace("Warning: There is no object named " + objectName);
				return;
			}
			
			if (object.hasOwnProperty(paramName))
				trace(objectName + " property:" + paramName + "=" + object[paramName]);	
			else
				trace("Warning: " + objectName + " has no parameter named " + paramName + ".");
		}
		
		public function get fullScreen():Boolean
		{
			return _fullScreen;
		}
		
		public function set fullScreen(value:Boolean):void
		{
			if (value == _fullScreen)
				return;
				
			if(value)
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			else
				stage.displayState = StageDisplayState.NORMAL;
			
			resetScreenSize();
		}
		
		public function get screenWidth():int
		{
			return _screenWidth;
		}
		
		public function get screenHeight():int
		{
			return _screenHeight;
		}
	}
}