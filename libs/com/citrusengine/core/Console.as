package com.citrusengine.core
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;
	
	/**
	 * You can use the console to perform any type of command at your game's runtime. Press the key that opens it, then type a
	 * command into the console, then press enter. If your command is recognized, the command's handler function will fire.
	 * 
	 * <p>You can create your own console commands by using the <code>addCommand</code> method.</p>
	 * 
	 * <p>When the console is open, it does not disable game input. You can manually toggle game input by listening for
	 * the <code>onShowConsole</code> and <code>onHideConsole</code> Signals.</p>
	 * 
	 * <p>When the console is open, you can press the up key to step backwards through your executed command history, 
	 * even after you've closed your SWF. Pressing the down key will step forward through your history.
	 * Use this to quickly access commonly executed commands.</p>
	 * 
	 * <p>Each command follows this pattern: <code>commandName param1 param2 param3...</code>. First, you call the 
	 * command name that you want to execute, then you pass any parameters into the command. For instance, you can
	 * set the jumpHeight property on a Hero object using the following command: "set myHero jumpHeight 20". That
	 * command finds an object named "myHero" and sets its jumpHeight property to 20.</p>
	 * 
	 * <p>Make sure and see the <code>addCommand</code> definition to learn how to add your own console commands.</p>
	 */	
	public class Console extends Sprite
	{
		public var openKey:uint = 9;
		private var _inputField:TextField;
		private var _openKey:int;
		private var _executeKey:int;
		private var _prevHistoryKey:int;
		private var _nextHistoryKey:int;
		private var _commandHistory:Array;
		private var _historyMax:Number;
		private var _showing:Boolean;
		private var _currHistoryIndex:int;
		private var _numCommandsInHistory:Number;
		private var _commandDelegates:Dictionary;
		private var _shared:SharedObject;
		private var _enabled:Boolean = true;
		
		//events
		private var _onShowConsole:Signal;
		private var _onHideConsole:Signal;
		
		/**
		 * Creates the instance of the console. This is a display object, so it is also added to the stage. 
		 */		
		public function Console(openKey:int = 9)
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			_shared = SharedObject.getLocal("history");
			
			this.openKey = openKey;
			_executeKey = flash.ui.Keyboard.ENTER;
			_prevHistoryKey = flash.ui.Keyboard.UP;
			_nextHistoryKey = flash.ui.Keyboard.DOWN;
			_historyMax = 25;
			_showing = false;
			_currHistoryIndex = 0;
			_numCommandsInHistory = 0;
			
			if (_shared.data.history)
			{
				_commandHistory = _shared.data.history as Array;
				_numCommandsInHistory = _commandHistory.length;
			}
			else
			{
				_commandHistory = new Array();
				_shared.data.history = _commandHistory;
			}
			_commandDelegates = new Dictionary();
			
			_inputField = addChild(new TextField()) as TextField;
			_inputField.type = TextFieldType.INPUT;
			_inputField.addEventListener(FocusEvent.FOCUS_OUT, onConsoleFocusOut);
			_inputField.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF, false, false, false);
			
			visible = false;
			
			_onShowConsole = new Signal();
			_onHideConsole = new Signal();
		}
		
		/**
		 * Gets dispatched when the console is shown. Handler accepts 0 params.
		 */		
		public function get onShowConsole():Signal
		{
			return _onShowConsole;
		}
		
		/**
		 * Gets dispatched when the console is hidden. Handler accepts 0 params.
		 */		
		public function get onHideConsole():Signal
		{
			return _onHideConsole;
		}
		
		/**
		 * Determines whether the console can be used. Set this property to false before releasing your final game. 
		 */		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if (_enabled == value)
				return;
			
			_enabled = value;
			
			if (_enabled)
			{
				stage.addEventListener(KeyboardEvent.KEY_UP, onToggleKeyPress);
			}
			else
			{
				stage.removeEventListener(KeyboardEvent.KEY_UP, onToggleKeyPress);
				hideConsole();
			}
		}
		
		/**
		 * Can be called to clear the command history. 
		 */		
		public function clearStoredHistory():void
		{
			_shared.clear();
		}
		
		/**
		 * Adds a command to the console. Use this method to create your own commands. The <code>name</code> parameter
		 * is the word that you must type into the console to fire the command handler. The <code>func</code> parameter
		 * is the function that will fire when the console command is executed.
		 * 
		 * <p>Your command handler should accept the parameters that are expected to be passed into the command. All
		 * of them should be typed as a String. As an example, this is a valid handler definition for the "set" command.</p>
		 * 
		 * <p><code>private function handleSetPropertyCommand(objectName:String, propertyName:String, propertyValue:String):void</code></p>
		 * 
		 * <p>You can then create logic for your command using the arguments.</p>
		 *  
		 * @param name The word you want to use to execute your command in the console.
		 * @param func The handler function that will get called when the command is executed. This function should accept the commands parameters as arguments.
		 * 
		 */		
		public function addCommand(name:String, func:Function):void
		{
			_commandDelegates[name] = func;
		}
		
		public function addCommandToHistory(command:String):void
		{
			var commandIndex:int = _commandHistory.indexOf(command);
			if (commandIndex != -1)
			{
				_commandHistory.splice(commandIndex, 1);
				_numCommandsInHistory--;
			}
				
			_commandHistory.push(command);
			_numCommandsInHistory++;
			
			if (_commandHistory.length > _historyMax)
			{
				_commandHistory.shift();
				_numCommandsInHistory--;
			}
			
			_shared.flush();
		}
		
		public function getPreviousHistoryCommand():String
		{
			if (_currHistoryIndex > 0)
				_currHistoryIndex--;
			
			return getCurrentCommand();
		}
		
		public function getNextHistoryCommand():String
		{
			if (_currHistoryIndex < _numCommandsInHistory)
				_currHistoryIndex++;
				
			return getCurrentCommand();
		}
		
		public function getCurrentCommand():String
		{
			var command:String = _commandHistory[_currHistoryIndex];
			
			if (!command)
			{
				return "";
			}
			return command;
		}
		
		public function toggleConsole():void
		{
			if (_showing)
				hideConsole();
			else
				showConsole();
		}
		
		public function showConsole():void
		{
			if (!_showing)
			{
				_showing = true;
				visible = true;
				stage.focus = _inputField;
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPressInConsole);
				_currHistoryIndex = _numCommandsInHistory;
				_onShowConsole.dispatch();
			}
		}
		
		public function hideConsole():void
		{
			if (_showing)
			{
				_showing = false;
				visible = false;
				stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPressInConsole);
				_onHideConsole.dispatch();
			}
		}
		
		public function clearConsole():void
		{
			_inputField.text = "";
		}
		
		private function onAddedToStage(event:Event):void
		{
			graphics.beginFill(0x000000, .8);
			graphics.drawRect(0, 0, stage.stageWidth, 30);
			graphics.endFill();
			
			_inputField.width = stage.stageWidth;
			_inputField.y = 4;
			_inputField.x = 4;
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onToggleKeyPress);
		}
		
		private function onConsoleFocusOut(event:FocusEvent):void
		{
			hideConsole();
		}
		
		private function onToggleKeyPress(event:KeyboardEvent):void
		{
			if (event.keyCode == openKey)
			{
				toggleConsole();
			}
		}
		
		private function onKeyPressInConsole(event:KeyboardEvent):void
		{
			if (event.keyCode == _executeKey)
			{
				if (_inputField.text == "" || _inputField.text == " ")
					return;
 
				addCommandToHistory(_inputField.text);
				
				var args:Array = _inputField.text.split(" ");
				var command:String = args.shift();
				clearConsole();
				hideConsole();
				
				var func:Function = _commandDelegates[command];
				if (func != null)
				{
					try
					{
						func.apply(this, args);
					}
					catch(e:ArgumentError)
					{
						if (e.errorID == 1063) //Argument count mismatch on [some function]. Expected [x], got [y]
						{
							trace(e.message);
							var expected:Number = Number(e.message.slice(e.message.indexOf("Expected ") + 9, e.message.lastIndexOf(",")));
							var lessArgs:Array = args.slice(0, expected);
							func.apply(this, lessArgs);
						}
					}
				}
			}
			else if (event.keyCode == _prevHistoryKey)
			{
				_inputField.text = getPreviousHistoryCommand();
				event.preventDefault();
				_inputField.setSelection(_inputField.text.length, _inputField.text.length);
			}
			else if (event.keyCode == _nextHistoryKey)
			{
				_inputField.text = getNextHistoryCommand();
				event.preventDefault();
				_inputField.setSelection(_inputField.text.length, _inputField.text.length);
			}
		}
	}
}