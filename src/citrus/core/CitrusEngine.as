package citrus.core {

	import citrus.input.Input;
	import citrus.utils.AGameData;
	import citrus.utils.LevelManager;

	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * CitrusEngine is the top-most class in the library. When you start your project, you should make your
	 * document class extend this class unless you use Starling. In this case extends StarlingCitrusEngine.
	 * 
	 * <p>CitrusEngine is a singleton so that you can grab a reference to it anywhere, anytime. Don't abuse this power,
	 * but use it wisely. With it, you can quickly grab a reference to the manager classes such as current State, Input and SoundManager.</p>
	 */	
	public class CitrusEngine extends MovieClip
	{
		public static const VERSION:String = "3.1.0";
				
		private static var _instance:CitrusEngine;
		
		/**
		 * Used to pause animations in SpriteArt and StarlingArt.
		 */
		public var onPlayingChange:Signal;
		
		protected var _state:IState;
		protected var _newState:IState;
		protected var _stateDisplayIndex:uint = 0;
		protected var _playing:Boolean = true;
		protected var _input:Input;
		
		private var _levelManager:LevelManager;
		private var _startTime:Number;
		private var _gameTime:Number;
		private var _gameData:AGameData;
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
			
			//Set up console
			_console = new Console(9); //Opens with tab key by default
			_console.onShowConsole.add(handleShowConsole);
			_console.addCommand("set", handleConsoleSetCommand);
			addChild(_console);
			
			//timekeeping
			_startTime = new Date().time;
			_gameTime = _startTime;
			
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
			
			stage.removeEventListener(Event.ACTIVATE, handleStageActivated);
			stage.removeEventListener(Event.DEACTIVATE, handleStageDeactivated);
			
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			if (_state) {
				
				_state.destroy();
				
				if (_state is State)
					removeChild(_state as State);
			}
				
			_console.destroy();
			removeChild(_console);
			
			_input.destroy();
			_sound.destroy();
		}
		
		/**
		 * Return the level manager, use it if you want. Take a look on its class for more information.
		 */
		public function get levelManager():LevelManager {
			return _levelManager;
		}
		
		/**
		 * You may use the Citrus Engine's level manager if you have several levels. Take a look on its class for more information.
		 */
		public function set levelManager(value:LevelManager):void {
			_levelManager = value;
		}
		
		/**
		 * A reference to the active game state. Acutally, that's not entirely true. If you've recently changed states and a tick
		 * hasn't occured yet, then this will reference your new state; this is because actual state-changes only happen pre-tick.
		 * That way you don't end up changing states in the middle of a state's tick, effectively fucking stuff up. 
		 */		
		public function get state():IState
		{			
			if (_newState)
				return _newState;
			else {
				return _state;
			}
		}
		
		/**
		 * We only ACTUALLY change states on enter frame so that we don't risk changing states in the middle of a state update.
		 * However, if you use the state getter, it will grab the new one for you, so everything should work out just fine.
		 */		
		public function set state(value:IState):void
		{
			_newState = value;			
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
		 * Dispatch the Signal onPlayingChange with the value
		 */
		public function set playing(value:Boolean):void
		{
			_playing = value;
			if (_playing)
				_gameTime = new Date().time;
			
			onPlayingChange.dispatch(_playing);
		}
		
		/**
		 * A reference to the Abstract GameData instance. Use it if you want.
		 * It's a dynamic class, so you don't have problem to access informations in its extended class.
		 */
		public function get gameData():AGameData {
			return _gameData;
		}

		/**
		 * You may use a class to store your game's data, there is already an abstract class for that :
		 */
		public function set gameData(gameData:AGameData):void {
			_gameData = gameData;
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
			
			_input.initialize();
		}
		
		/**
		 * This is the game loop. It switches states if necessary, then calls update on the current state.
		 */		
		//TODO The CE updates use the timeDelta to keep consistent speed during slow framerates. However, Box2D becomes unstable when changing timestep. Why?
		protected function handleEnterFrame(e:Event):void
		{
			//Change states if it has been requested
			if (_newState)
			{
				if (_newState is State) {
					
					if (_state) {
							
						_state.destroy();
						removeChild(_state as State);
					}
					_state = _newState;
					_newState = null;
					
					addChildAt(_state as State, _stateDisplayIndex);
					_state.initialize();					
				}
			}
			
			//Update the state
			if (_state && _playing)
			{
				var nowTime:Number = new Date().time;
				var timeSinceLastFrame:Number = nowTime - _gameTime;
				var timeDelta:Number = timeSinceLastFrame * 0.001;
				_gameTime = nowTime;
				
				_state.update(timeDelta);
			}
			
		}
		
		protected function handleStageDeactivated(e:Event):void
		{
			if (_playing)
			{
				playing = false;
				stage.addEventListener(Event.ACTIVATE, handleStageActivated);
			}
		}
		
		protected function handleStageActivated(e:Event):void
		{
			playing = true;
			stage.removeEventListener(Event.ACTIVATE, handleStageActivated);
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
			var object:CitrusObject = _state.getObjectByName(objectName);
			
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
	}
}