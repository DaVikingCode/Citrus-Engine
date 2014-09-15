package citrus.input.controllers.gamepad
{
	import citrus.input.controllers.gamepad.controls.ButtonController;
	import citrus.input.InputAction;
	import citrus.input.InputController;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.osflash.signals.Signal;
	
	/**
	 * Experimental InputController that waits for a new gamepad buttons pressed to assign a new button to it.
	 * 
	 * var buttonRebinder:GamePadButtonRebinder = new GamePadButtonRebinder("", "down", true, true, 5000);
	 * 		buttonRebinder.onDone.add(function(ok:Boolean):void
	 * 		{
	 * 			if (ok)
	 * 				trace("ACTION HAS BEEN REBOUND CORRECTLY.");
	 * 			else
	 * 				trace("ACTION HAS NOT BEEN REBOUND, TIMER IS COMPLETE.");
	 * 		});
	 */
	public class GamePadButtonRebinder extends InputController
	{
		
		protected var _actionName:String;
		protected var _route:Boolean;
		protected var _removeActions:Boolean;
		protected var _gamePadManager:GamePadManager;
		protected var _gamePads:Vector.<Gamepad>;
		protected var _gamePadIndex:int;
		protected var _gamePad:Gamepad;
		protected var _timeOut:int;
		protected var _timer:Timer;
		
		private var _success:Boolean = false;
		
		/**
		 * dispatches true if rebound correctly, or false if timer is over.
		 */
		public var onDone:Signal;
		
		public function GamePadButtonRebinder(name:String, action:String, route:Boolean = true, removeActions:Boolean = true , timeOut:int = -1, gamePadIndex:int = -1)
		{
			_actionName = action;
			_route = route;
			_removeActions = removeActions;
			super(name);
			_updateEnabled = true;
			_gamePadIndex = gamePadIndex;
			
			_gamePadManager = GamePadManager.getInstance();
			_gamePads = new Vector.<Gamepad>();
			var gp:Gamepad;
			for (var i:int = 0; i < _gamePadManager.numGamePads; i++)
			{
				gp = _gamePadManager.getGamePadAt(i);
				_gamePads.push(gp);
			}
				
			onDone = new Signal(Boolean);
				
			_timeOut = timeOut;
				
			if (_gamePadIndex > -1)
			{
				 _gamePad = _gamePadManager.getGamePadAt(_gamePadIndex);
				 _gamePad.triggerActivity = true;
			}
			else
			for each (gp in _gamePads)
				gp.triggerActivity = true;
			
			if (_route)
				_input.startRouting(999);
				
			if (_timeOut > -1)
			{
				_timer = new Timer(_timeOut, 1);
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				_timer.start();
			}
		}
		
		protected var time:int = 0;
		override public function update():void
		{
			time++;
			
			if (time % 2 == 0)
				return;
				
			var actions:Vector.<InputAction> = _input.getActions(999);
			if (actions.length > 0)
			{
				for each (var action:InputAction in actions)
				{
					if (action.controller is ButtonController)
					{
						var b:ButtonController = action.controller as ButtonController;
						if ((_gamePad && b.gamePad == _gamePad) || !_gamePad)
						{
							if(_removeActions)
							b.gamePad.removeActionFromButtons(_actionName);
							_input.stopActionsOf(b); // stop action of ButtonController
							b.gamePad.setButtonAction(b.name, _actionName); //set new action
							_success = true;
							destroy(); //destroy self
							break;
						}
					}
				}
			}
		}
		
		protected function onTimerComplete(te:TimerEvent):void
		{
			te.target.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			_updateEnabled = false;
			destroy();
		}
		
		
		override public function destroy():void
		{
			if (_gamePad)
			{
				_gamePad.triggerActivity = false;
				_gamePad = null;
			}
			else
			for each (var gp:Gamepad in _gamePads)
				gp.triggerActivity = false;
			
			_gamePads.length = 0;
				
			if(_route)
				_input.stopRouting();
			_input.resetActions();
			_gamePadManager = null;
			super.destroy();
			
			onDone.dispatch(_success);
			onDone.removeAll();
		}
	
	}

}