package com.citrusengine.input {

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.input.controllers.Keyboard;

	import org.osflash.signals.Signal;
	
	/**
	 * A class managing input of any controllers that is an InputController.
	 * Actions are inspired by Midi signals, but they carry an InputAction object.
	 * "action signals" are either ON, OFF, or VALUECHANGE.
	 * to track action status, and check wether action was just triggered or is still on,
	 * actions have phases (see InputAction).
	 **/	
	public class Input
	{
		protected var _ce:CitrusEngine;
		protected var _enabled:Boolean = true;
		protected var _initialized:Boolean;
		
		protected var _controllers:Vector.<InputController>;
		protected var _actions:Vector.<InputAction>;
		
		public var triggersEnabled:Boolean = true;
		
		public var actionTriggeredON:Signal;
		public var actionTriggeredOFF:Signal;
		public var actionTriggeredVALUECHANGE:Signal;
		
		//easy access to the default keyboard
		public var keyboard:Keyboard;
		
		public function Input()
		{
			_controllers = new Vector.<InputController>();
			_actions = new Vector.<InputAction>();
			
			actionTriggeredON = new Signal();
			actionTriggeredOFF = new Signal();
			actionTriggeredVALUECHANGE = new Signal();
			
			actionTriggeredON.add(doActionON);
			actionTriggeredOFF.add(doActionOFF);
			actionTriggeredVALUECHANGE.add(doActionVALUECHANGE);
			
			_ce = CitrusEngine.getInstance();
		
		}
		
		public function initialize():void
		{
			if (_initialized)
				return;
			
			//default keyboard
			keyboard = new Keyboard("keyboard", 0);
			
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
		
		public function hasDone(actionName:String, channel:uint = 0):Boolean
		{
			var a:InputAction;
			for each (a in _actions)
				if (a.name == actionName && a.channel == channel && a.phase > InputAction.ON)
					return true;
			return false;
		}
		
		public function isDoing(actionName:String, channel:uint = 0):Boolean
		{
			var a:InputAction;
			for each (a in _actions)
				if (a.name == actionName && a.channel == channel && a.phase < InputAction.END)
					return true;
			return false;
		}
		
		public function justDid(actionName:String, channel:uint = 0):Boolean
		{
			var a:InputAction;
			for each (a in _actions)
				if (a.name == actionName && a.channel == channel && a.phase < InputAction.ON)
					return true;
			return false;
		}
		
		public function getActionValue(actionName:String, channel:uint = 0):Number
		{
			var a:InputAction;
			for each (a in _actions)
				if (actionName == a.name && channel == a.channel && a.value)
					return a.value;
			return 0;
		}
		
		/**
		 * Adds a new action of phase 0 if it does not exist.
		 * if it does exist however, it is reset to phase 0.
		 */
		private function doActionON(action:InputAction):void
		{
			if (!triggersEnabled)
				return;
			var a:InputAction;
			for each (a in _actions)
				if (a.eq(action))
				{
					a.phase = InputAction.BEGIN;
					return;
				}
			action.phase = InputAction.BEGIN;
			_actions[_actions.length] = action;
		}
		
		/**
		 * Sets action to phase 3. will be advanced to phase 4 in next update, and finally will be removed
		 * on the update after that.
		 */
		private function doActionOFF(action:InputAction):void
		{
			if (!triggersEnabled)
				return;
			var a:InputAction;
			for each (a in _actions)
				if (a.eq(action))
				{
					a.phase = InputAction.END;
					return;
				}
		}
		
		/**
		 * Changes the value property of an action, or adds action to list if it doesn't exist.
		 * a continuous controller, can simply trigger ActionVALUECHANGE and never have to trigger ActionON.
		 * this will take care adding the new action to the list, setting its phase to 0 so it will respond
		 * to justDid, and then only the value will be changed. - however your continous controller DOES have
		 * to end the action by triggering ActionOFF.
		 */
		private function doActionVALUECHANGE(action:InputAction):void
		{
			if (!triggersEnabled)
				return;
			var a:InputAction;
			for each (a in _actions)
			{
				if (a.eq(action))
				{
					a.phase = InputAction.ON;
					a.value = action.value;
					return;
				}
			}
			action.phase = InputAction.BEGIN;
			_actions[_actions.length] = action;
		}
		
		/**
		 * Input.update is called in the end of your state update.
		 * keep this in mind while you create new controllers - it acts only after everything else.
		 * update first updates all registered controllers then finally
		 * advances actions phases by one if not phase 2 (phase two can only be voluntarily advanced by
		 * doActionOFF.) and removes actions of phase 4 (this happens one frame after doActionOFF was called.)
		 */
		public function update():void
		{
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
				if (_actions[i].phase > InputAction.END)
					_actions.splice(i as uint, 1);
				else if (_actions[i].phase !== InputAction.ON)
					_actions[i].phase++;
			}
		
		}
		
		public function removeController(controller:InputController):void
		{
			var i:int = _controllers.lastIndexOf(controller);
			removeActionsOf(controller);
			_controllers.splice(i, 1);
		}
		
		public function removeActionsOf(controller:InputController):void
		{
			var i:String;
			for (i in _actions)
				if (_actions[i].controller == controller)
					_actions.splice(i as uint, 1);
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
					a.phase = action.phase;
					a.value = action.value;
					return;
				}
			}
			_actions[_actions.length] = action;
		}
		
		/**
		 *  getActionsSnapshot returns a Vector of all actions in current frame.
		 */
		public function getActionsSnapshot():Vector.<Object>
		{
			var snapshot:Vector.<Object> = new Vector.<Object>;
			for each (var a:Object in _actions)
			{
				snapshot.push(new InputAction(a.name, a.controller, a.channel, a.value, a.phase));
			}
			return snapshot;
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
			
			actionTriggeredON.removeAll();
			actionTriggeredOFF.removeAll();
			actionTriggeredVALUECHANGE.removeAll();
		}
		
		/**
		 * Limited backwards compatibilty for justPressed and isDown .
		 * /!\ only works with defined key actions in the default keyboard instance
		 * (up, down, right, left, up, spacebar)
		 * ultimately, you'll have to convert to the new system :)
		 */
		public function justPressed(keyCode:uint):Boolean
		{
			var keyboard:Keyboard = getControllerByName("keyboard") as Keyboard;
			var action:Object = keyboard.getActionByKey(keyCode);
			if (action)
				return justDid(action.name);
			else
			{
				trace("Warning: you are still using justPressed(keyCode:int) for keyboard input and might get unexpected results...");
				trace("Please use the new justDid(actionName:String, channel:uint) method and convert your code to the Input/InputController Action system !");
				return false;
			}
		}
		
		public function isDown(keyCode:uint):Boolean
		{
			var keyboard:Keyboard = getControllerByName("keyboard") as Keyboard;
			var action:Object = keyboard.getActionByKey(keyCode);
			if (action)
				return isDoing(action.name);
			else
			{
				trace("Warning: you are still using justPressed(keyCode:int) for keyboard input and might get unexpected results...");
				trace("Please use the new isDoing(actionName:String, channel:uint) method and convert your code to the Input/InputController Action system !");
				return false;
			}
		}
	
	}

}