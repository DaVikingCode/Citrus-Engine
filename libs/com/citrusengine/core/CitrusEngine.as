package com.citrusengine.core {

	import starling.core.Starling;
	import starling.events.Event;
	
	import com.citrusengine.utils.AGameData;
	import com.citrusengine.utils.LevelManager;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * CitrusEngine is the top-most class in the library. When you start your project, you should make your
	 * document class extend this class.
	 * 
	 * <p>CitrusEngine is a singleton so that you can grab a reference to it anywhere, anytime. Don't abuse this power,
	 * but use it wisely. With it, you can quickly grab a reference to the manager classes such as current State, Input and SoundManager.</p>
	 * 
	 * <p>CitrusEngine can access to the Stage3D power thanks to the <a href="http://starling-framework.org/">Starling Framework</a></p>
	 */	
	public class CitrusEngine extends MovieClip
	{
		public static const VERSION:String = "3.00.00 BETA 2";
				
		private static var _instance:CitrusEngine;
		
		protected var _starling:Starling;
		
		private var _levelManager:LevelManager;
		private var _state:IState;
		private var _newState:IState;
		private var _stateDisplayIndex:uint = 0;
		private var _startTime:Number;
		private var _gameTime:Number;
		private var _playing:Boolean = true;
		private var _gameData:AGameData;
		private var _input:Input;
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
			
			addEventListener(flash.events.Event.ENTER_FRAME, handleEnterFrame);
			addEventListener(flash.events.Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		/**
		 * You should call this function to create your Starling view. The RootClass is internal, it is never used elsewhere. 
		 * StarlingState is added on the starling stage : <code>_starling.stage.addChildAt(_state as StarlingState, _stateDisplayIndex);</code>
		 * @param debugMode : if true, display a Stats class instance.
		 * @param antiAliasing : The antialiasing value allows you to set the anti-aliasing (0 - 16), generally a value of 1 is totally acceptable.
		 * @param viewPort : Starling's viewport, default is (0, 0, stage.stageWidth, stage.stageHeight, change to (0, 0, stage.fullScreenWidth, stage.fullScreenHeight) for mobile.
		 */
		public function setUpStarling(debugMode:Boolean = false, antiAliasing:uint = 1, viewPort:Rectangle = null):void {
			
			if (!viewPort)
				viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			_starling = new Starling(RootClass, stage, viewPort, null, "auto", "baseline");
			
			_starling.antiAliasing = antiAliasing;
			_starling.showStats = debugMode;
			 
			_starling.addEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
		}
		
		// be sure that starling is initialized (especially on mobile)
		protected function _context3DCreated(evt:starling.events.Event):void {
			
			_starling.removeEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
			
			_starling.start();
		}
		
		public function get starling():Starling {
			return _starling;
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
		 * Runs and pauses the game loop. Assign this to false to pause the game and stop the
		 * <code>update()</code> methods from being called. 
		 */		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function set playing(value:Boolean):void
		{
			_playing = value;
			if (_playing)
				_gameTime = new Date().time;
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
		 * You can get to my Input manager object from this reference so that you can see which keys are pressed and stuff. 
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
		 * The console can be opened by pressing the tilde key (It looks like this: "~" right below the escape key).
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
		private function handleAddedToStage(e:flash.events.Event):void 
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, handleAddedToStage);
			stage.scaleMode = "noScale";
			stage.align = "topLeft";
			stage.addEventListener(flash.events.Event.DEACTIVATE, handleStageDeactivated);
			
			_input.initialize();
		}
		
		/**
		 * This is the game loop. It switches states if necessary, then calls update on the current state.
		 */		
		//TODO The CE updates use the timeDelta to keep consistent speed during slow framerates. However, Box2D becomes unstable when changing timestep. Why?
		private function handleEnterFrame(e:flash.events.Event):void
		{
			//Change states if it has been requested
			if (_newState)
			{
				// if we use Stage3D with StarlingView
				if (_starling) {
					if (_starling.isStarted) {
						
						if (_state) {
							
							_state.destroy();
							_starling.stage.removeChild(_state as StarlingState);
							_starling.nativeStage.removeChildAt(2); // Remove Box2D or Nape view
						}
						_state = _newState;
						_newState = null;
					
						_starling.stage.addChildAt(_state as StarlingState, _stateDisplayIndex);
						_state.initialize();
					}
					
				} 
				else // if we use class display list with the SpriteView or BlittingView 
				{
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
		
		private function handleStageDeactivated(e:flash.events.Event):void
		{
			if (_playing)
			{
				if (_starling)
					_starling.stop();
					
				playing = false;
				stage.addEventListener(flash.events.Event.ACTIVATE, handleStageActivated);
			}
		}
		
		private function handleStageActivated(e:flash.events.Event):void
		{
			if (_starling)
				_starling.start();
					
			playing = true;
			stage.removeEventListener(flash.events.Event.ACTIVATE, handleStageActivated);
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

import starling.display.Sprite;

/**
 * RootClass is the root of Starling, it is never destroyed and only accessed through <code>_starling.stage</code>.
 */
internal class RootClass extends Sprite {
	
	public function RootClass() {
	}
}