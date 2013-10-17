package citrus.input {

	import citrus.core.citrus_internal;
	import citrus.core.CitrusEngine;
	import citrus.input.controllers.Keyboard;

	import org.osflash.signals.Signal;
	
	/**
	 * A class managing input of any controllers that is an InputController.
	 * Actions are inspired by Midi signals, but they carry an InputAction object.
	 * "action signals" are either ON, OFF, or CHANGE.
	 * to track action status, and check whether action was just triggered or is still on,
	 * actions have phases (see InputAction).
	 **/	
	public class Input
	{
		protected var _ce:CitrusEngine;
		protected var _timeActive:int = 0;
		protected var _enabled:Boolean = true;
		protected var _initialized:Boolean;
		
		protected var _controllers:Vector.<InputController>;
		protected var _actions:Vector.<InputAction>;
		
		/**
		 * time interval to clear the InputAction's disposed list automatically.
		 */
		public var clearDisposedActionsInterval:uint = 480;
		
		/**
		 * Lets InputControllers trigger actions.
		 */
		public var triggersEnabled:Boolean = true;
		
		protected var _routeActions:Boolean = false;
		protected var _routeChannel:uint;
		
		internal var actionON:Signal;
		internal var actionOFF:Signal;
		internal var actionCHANGE:Signal;
		
		//easy access to the default keyboard
		public var keyboard:Keyboard;
		
		public function Input()
		{
			_controllers = new Vector.<InputController>();
			_actions = new Vector.<InputAction>();
			
			actionON = new Signal();
			actionOFF = new Signal();
			actionCHANGE = new Signal();
			
			actionON.add(doActionON);
			actionOFF.add(doActionOFF);
			actionCHANGE.add(doActionCHANGE);
			
			_ce = CitrusEngine.getInstance();
		}
		
		public function initialize():void
		{
			if (_initialized)
				return;
			
			//default keyboard
			keyboard = new Keyboard("keyboard");
			
			_initialized = true;
		}
		
		public function addController(controller:InputController):void
		{
			if (_controllers.lastIndexOf(controller) < 0)
				_controllers.push(controller);
		}
		
		public function addAction(action:InputAction):void
		{
			if (_actions.lastIndexOf(action) < 0)
					_actions[_actions.length] = action;
		}
		
		public function controllerExists(name:String):Boolean
		{
			for each (var c:InputController in _controllers)
			{
				if (name == c.name)
					return true;
			}
			return false;
		}
		
		public function getControllerByName(name:String):InputController
		{
			var c:InputController;
			for each (c in _controllers)
				if (name == c.name)
					return c;
			return null;
		}
		
		/**
		 * Returns true if the action has been triggered OFF in this frame or in the previous frame.
		 */
		public function hasDone(actionName:String, channel:uint = 0):Boolean
		{
			var a:InputAction;
			for each (a in _actions)
				if (a.name == actionName && (_routeActions ? (_routeChannel == channel) : a.channel == channel) && a.phase == InputPhase.END)
					return true;
			return false;
		}
		
		/**
		 * Returns true if action has just been triggered, or is still on.
		 */
		public function isDoing(actionName:String, channel:uint = 0):Boolean
		{
			var a:InputAction;
			for each (a in _actions)
				if (a.name == actionName && (_routeActions ? (_routeChannel == channel) : a.channel == channel) && a.time > 1 && a.phase < InputPhase.END)
					return true;
			return false;
		}
		
		/**
		 * Returns true if action has been triggered in this frame.
		 */
		public function justDid(actionName:String, channel:uint = 0):Boolean
		{
			var a:InputAction;
			for each (a in _actions)
				if (a.name == actionName && (_routeActions ? (_routeChannel == channel) : a.channel == channel) && a.time == 1)
					return true;
			return false;
		}
		
		/**
		 * get an action from the current 'active' actions to check out their phase,value or time.
		 * returns null if no actions are available (if so, the action ended 2 frames previous to the call.)
		 * 
		 * example :
		 * <code>
		 * var action:InputAction = _ce.input.getAction("jump");
		 * if(action && action.phase >= InputPhase.ON && action.time > 120)
		 *    trace("the jump action lasted 120 frames. its value is",action.value);
		 * </code>
		 * 
		 * keep doing the jump action for about 2 seconds (if running at 60 fps) and you'll see the trace.
		 * @param	name
		 * @param	channel
		 * @return	InputAction
		 */
		public function getAction(name:String, channel:uint = 0):InputAction
		{
			var a:InputAction;
			for each (a in _actions)
				if (name == a.name && (_routeActions ? (_routeChannel == channel) : a.channel == channel))
					return a;
			return null;	
		}
		
		/**
		 * returns a list of all currently active actions (optionally filter by channel number)
		 * @return
		 */
		public function getActions(channel:int = -1):Vector.<InputAction>
		{
			var actions:Vector.<InputAction> = new Vector.<InputAction>;
			var a:InputAction;
			for each (a in _actions)
				if (channel < 0)
					actions.push(a)
				else if ((_routeActions ? (_routeChannel == channel) : a.channel == channel))
					actions.push(a);
			return actions;
		}
		
		/**
		 * Call this right after justDid, isDoing or hasDone to get the action's value in the current frame...
		 * or use getAction() directly to access all action properties!
		 */
		public function getActionValue(actionName:String, channel:uint = 0):Number
		{
			var a:InputAction;
			for each (a in _actions)
				if (actionName == a.name && (_routeActions ? (_routeChannel == channel) : a.channel == channel) && a.value)
					return a.value;
			return 0;
		}
		
		/**
		 * Call this right after justDid, isDoing or hasDone to get the action's message in the current frame...
		 * or use getAction() directly to access all action properties!
		 */
		public function getActionMessage(actionName:String, channel:uint = 0):String
		{
			var a:InputAction;
			for each (a in _actions)
				if (actionName == a.name && (_routeActions ? (_routeChannel == channel) : a.channel == channel) && a.value)
					return a.message;
			return null;
		}
		
		/**
		 * Adds a new action of phase 0 if it does not exist.
		 */
		private function doActionON(action:InputAction):void
		{
			if (!triggersEnabled)
			{
				action.dispose();
				return;
			}
			var a:InputAction;
			
			for each (a in _actions)
				if (a.eq(action))
				{
					action.dispose();
					return;
				}
			action._phase = InputPhase.BEGIN;
			_actions[_actions.length] = action;
		}
		
		/**
		 * Sets action to phase 3. will be advanced to phase 4 in next update, and finally will be removed
		 * on the update after that.
		 */
		private function doActionOFF(action:InputAction):void
		{
			if (!triggersEnabled)
			{
				action.dispose();
				return;
			}
			var a:InputAction;
			for each (a in _actions)
				if (a.eq(action))
				{
					a._phase = InputPhase.END;
					a._value = action._value;
					a._message = action._message;
					action.dispose();
					return;
				}
		}
		
		/**
		 * Changes the value property of an action, or adds action to list if it doesn't exist.
		 * a continuous controller, can simply trigger ActionCHANGE and never have to trigger ActionON.
		 * this will take care adding the new action to the list, setting its phase to 0 so it will respond
		 * to justDid, and then only the value will be changed. - however your continous controller DOES have
		 * to end the action by triggering ActionOFF.
		 */
		private function doActionCHANGE(action:InputAction):void
		{
			if (!triggersEnabled)
			{
				action.dispose();
				return;
			}
			var a:InputAction;
			for each (a in _actions)
			{
				if (a.eq(action))
				{
					a._phase = InputPhase.ON;
					a._value = action._value;
					a._message = action._message;
					action.dispose();
					return;
				}
			}
			action._phase = InputPhase.BEGIN;
			_actions[_actions.length] = action;
		}
		
		/**
		 * Input.update is called in the end of your state update.
		 * keep this in mind while you create new controllers - it acts only after everything else.
		 * update first updates all registered controllers then finally
		 * advances actions phases by one if not phase 2 (phase two can only be voluntarily advanced by
		 * doActionOFF.) and removes actions of phase 4 (this happens one frame after doActionOFF was called.)
		 */
		citrus_internal function update():void
		{
			if (InputAction.disposed.length > 0 && _timeActive % clearDisposedActionsInterval == 0)
				InputAction.clearDisposed();
			_timeActive++;
			
			if (!_enabled)
				return;
			
			var c:InputController;
			for each (c in _controllers)
			{
				if (c.enabled)
					c.update();
			}
			
			var i:String;
			for (i in _actions)
			{
				InputAction(_actions[i]).itime++;
				if (_actions[i].phase > InputPhase.END)
				{
					_actions[i].dispose();
					_actions.splice(uint(i), 1);
				}
				else if (_actions[i].phase !== InputPhase.ON)
					_actions[i]._phase++;
			}
		
			
		}
		
		public function removeController(controller:InputController):void
		{
			var i:int = _controllers.lastIndexOf(controller);
			stopActionsOf(controller);
			_controllers.splice(i, 1);
		}
		
		public function stopActionsOf(controller:InputController,channel:int = -1):void
		{
			var action:InputAction;
			for each(action in _actions)
			{
				if (channel > -1)
					if (action.channel == channel) action._phase = InputPhase.ENDED;
				else
					action._phase = InputPhase.ENDED;
			}
		}
		
		public function resetActions():void
		{
			_actions.length = 0;
		}
		
		/**
		 *  addOrSetAction sets existing parameters of an action to new values or adds action if
		 *  it doesn't exist.
		 */
		public function addOrSetAction(action:InputAction):void
		{
			var a:InputAction;
			for each (a in _actions)
			{
				if (a.eq(action))
				{
					a._phase = action.phase;
					a._value = action.value;
					return;
				}
			}
			_actions[_actions.length] = action;
		}
		
		/**
		 * returns a Vector of all actions in current frame.
		 * actions are cloned (no longer active inside the input system) 
		 * as opposed to using getActions().
		 */
		public function getActionsSnapshot():Vector.<InputAction>
		{
			var snapshot:Vector.<InputAction> = new Vector.<InputAction>;
			var a:InputAction;
			for each (a in _actions)
				snapshot.push(a.clone());
			return snapshot;
		}
		
		/**
		 * Start routing all actions to a single channel - used for pause menus or generally overriding the Input system.
		 */
		public function startRouting(channel:uint):void
		{
			_routeActions = true;
			_routeChannel = channel;
		}
		
		/**
		 * Stop routing actions.
		 */
		public function stopRouting():void
		{
			_routeActions = false;
			_routeChannel = 0;
		}
		
		/**
		 * Helps knowing if Input is routing actions or not.
		 */
		public function isRouting():Boolean
		{
			return _routeActions;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if (_enabled == value)
				return;
			
			var controller:InputController;
			for each (controller in _controllers)
				controller.enabled = value;
			
			_enabled = value;
		}
		
		private function destroyControllers():void
		{
			for each (var c:InputController in _controllers)
			{
				c.destroy();
			}
			_controllers.length = 0;
			_actions.length = 0;
		}
		
		public function destroy():void
		{
			destroyControllers();
			
			actionON.removeAll();
			actionOFF.removeAll();
			actionCHANGE.removeAll();
			
			resetActions();
			InputAction.clearDisposed();
		}
	
	}

}