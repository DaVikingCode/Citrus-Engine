package citrus.input.controllers
{
	
	import citrus.input.controllers.gamepad.AxisControl2;
	import citrus.input.controllers.gamepad.ButtonControl;
	import citrus.input.InputController;
	import flash.events.Event;
	import flash.events.GameInputEvent;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	import flash.utils.Dictionary;
	
	/**
	 * Generic class to manage gamepad InputControllers.
	 * 
	 * if there are more than one GameInput device plugged in, each will have its own Input channel assigned
	 * according to the order they were plugged in (see _devices and handleDeviceAttached)
	 * all controller should work as long as they have the same layout and each button/axis have the same ID.
	 * 
	 * TODO: really check multiple controller support cause it has not been yet. test how the channels get set up as well.
	 * 
	 * example :
	 * <code>
	 * var gamepad:GenericGamepad = new GenericGamepad("Gamepad");
	 * 
	 * gamepad.addMultiAxis("Lpad", ["AXIS_1", "AXIS_0"]); //default will be AXIS_1 -> up/down, AXIS_0 -> right/left
	 * gamepad.addMultiAxis("Rpad", ["AXIS_4", "AXIS_2"]);
	 * 
	 * //the following buttons will have their action be the same as their name (L1,R1...)
	 * gamepad.addButton("L1","BUTTON_13");
	 * gamepad.addButton("R1", "BUTTON_14");
	 * gamepad.addButton("L2", "BUTTON_15");
	 * gamepad.addButton("R2", "BUTTON_16");
	 * 
	 * //define actions for multiaxes other than up/right/down/left :
	 * gamepad.setMultiAxisActions("Rpad", "lookUp", "lookRight", "lookDown", "lookLeft");
	 * 
	 * //we can still define specific action names - or change them later on a key config menu for example with
	 * gamepad.setButtonAction("L1", "strafeLeft");
	 * gamepad.setButtonAction("R1", "strafeRight");
	 * </code>
	 */
	public class GenericGamepad extends InputController
	{
		
		private var gameInput:GameInput;
		private var _device:GameInputDevice;
		private var _deviceEnabled:Boolean = false;
		private var control:GameInputControl;
		
		/**
		 * stores devices and the channel we'll use to send the actions in the Input system.
		 * temporary solution to multiple gamepads support.
		 * Object : {device:GameDevice, channel:uint}
		 */
		protected var _devices:Vector.<Object>;
		protected var _lastChannelTaken:uint = 0;
		
		/**
		 *  GameControl.id => ButtonControl
		 */
		protected var _buttons:Dictionary;
		/**
		 *  GameControl.id => AxisControl2
		 */
		protected var _multiaxis:Dictionary;
		
		public function GenericGamepad(name:String, params:Object = null)
		{
			super(name, params);
			
			_devices = new Vector.<Object>;
			
			_buttons = new Dictionary();
			_multiaxis = new Dictionary();
			
			gameInput = new GameInput();
			gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, handleDeviceAttached);
			gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, handleDeviceRemoved);
		}
		
		protected function handleDeviceRemoved(event:GameInputEvent):void
		{
			trace(name, "Device is removed\n");
			_device = event.device;
			
			if (_lastChannelTaken == _devices.length)
				_lastChannelTaken--;
			
			var controllerDef:Object;
			var j:String;
			for (j in _devices)
			{
				controllerDef = _devices[j];
				
				if (_device == controllerDef.device)
				{
					destroyDevice(_device);
					_devices.splice(int(j), 1);
					_input.stopActionsOf(this,controllerDef.channel);
					break;
				}
			}
		}
		
		protected function destroyDevice(d:GameInputDevice):void
		{
			var _controls:Vector.<String> = new Vector.<String>;
			var control:GameInputControl;
			var i:uint;
			for (i = 0; i < _device.numControls; i++)
			{
				control = _device.getControlAt(i);
				control.removeEventListener(Event.CHANGE, onChange);
				_controls[i] = control.id;
			}
			_device.enabled = false;
			//_device.stopCachingSamples();
		}
		
		protected function handleDeviceAttached(e:GameInputEvent):void
		{
			_device = e.device;
			
			GameInputControlName.initialize(_device);
			
			if (_devices.length < _lastChannelTaken)
				_devices.push({device: _device, channel: _lastChannelTaken - _devices.length});
			else
				_devices.push({device: _device, channel: _lastChannelTaken++});
			
			var _controls:Vector.<String> = new Vector.<String>;
			var control:GameInputControl;
			var i:uint;
			
			_device.enabled = true;
			
			for (i = 0; i < _device.numControls; i++)
			{
				control = _device.getControlAt(i);
				control.addEventListener(Event.CHANGE, onChange);
				_controls[i] = control.id;
			}
			
			_device.startCachingSamples(30, _controls);
		}
		
		/**
		 * adds a multiaxis control,
		 * default actions are "up","right","down","left"
		 * use null in the arguments to use default.
		 * @param	name
		 * @param	axis array of the GameControl id for axis, either two entries for up/down and right/left or four for each direction
		 * @param	normalized
		 */
		public function addMultiAxis(name:String, axis:Array, up:String = null, right:String = null, down:String = null, left:String = null, normalized:Boolean = false):void
		{
			if (axis.length == 2)
			{
				var mAxis2:AxisControl2 = new AxisControl2(name, axis, up ? up : "up", right ? right : "right", down ? down : "down", left ? left : "left", normalized);
				var axisId:String;
				for each (axisId in axis)
				{
					_multiaxis[axisId] = mAxis2;
				}
			}
		}
		
		/**
		 * Attach a button GameControl to an action.
		 * @param	name name of the button (will be the action name if action is null
		 * @param	control_id the GameControl id.
		 * @param	action
		 */
		public function addButton(name:String, control_id:String, action:String = null):void
		{
			_buttons[control_id] = new ButtonControl(name, control_id, action ? action : name);
		}
		
		/**
		 * set actions for a multi axis control added through addMultiAxis()
		 * use null for actions you don't want to change.
		 */
		public function setMultiAxisActions(name:String, up:String, right:String, down:String, left:String):void
		{
			var i:String;
			var axisControl:AxisControl2;
			for (i in _multiaxis)
			{
				axisControl = _multiaxis[i] as AxisControl2;
				if (axisControl.name == name)
				{
					if (up)
						axisControl.upAction = up;
					if (right)
						axisControl.rightAction = right;
					if (down)
						axisControl.downAction = down;
					if (left)
						axisControl.leftAction = left;
					break;
				}
			}
		}
		
		/**
		 * define action name for a button.
		 * @param	name button name (button should've been added via addButton()
		 * @param	action
		 */
		public function setButtonAction(name:String, action:String):void
		{
			var i:String;
			var buttonControl:ButtonControl;
			for (i in _buttons)
			{
				buttonControl = _buttons[i] as ButtonControl;
				if (buttonControl.name == name)
				{
					buttonControl.action = action;
					break;
				}
			}
		}
		
		protected function onChange(e:Event):void
		{
			
			control = e.target as GameInputControl;
			
			var channel:uint = 0;
			var controllerDef:Object;
			for each(controllerDef in _devices)
				if (controllerDef.device == control.device)
				{
					channel = controllerDef.channel;
					break;
				}
			
			defaultChannel = channel;			
			
			if (control.id in _buttons)
			{
				var buttonControl:ButtonControl = _buttons[control.id] as ButtonControl;
				var value:Number = control.value;
				if (value > 0)
					triggerCHANGE(buttonControl.action, value, null);
				else
					triggerOFF(buttonControl.action, value, null);
				return;
			}
			
			if (control.id in _multiaxis)
			{
				var maxis:AxisControl2 = _multiaxis[control.id] as AxisControl2;
				var val:Number = maxis.length;
				
				maxis.updateAxis(control.id, control.value);
				
				if (maxis.length < 0.1)
				{
					triggerOFF(maxis.upAction, 0);
					triggerOFF(maxis.rightAction, 0);
					triggerOFF(maxis.downAction, 0);
					triggerOFF(maxis.leftAction, 0);
				}
				else
				{
					triggerOFF(maxis.upAction, 0);
					triggerOFF(maxis.rightAction, 0);
					triggerOFF(maxis.downAction, 0);
					triggerOFF(maxis.leftAction, 0);
					
					if (maxis.down > 0)
						triggerCHANGE(maxis.downAction, val);
					if (maxis.up < 0)
						triggerCHANGE(maxis.upAction, val);
					if (maxis.left < 0)
						triggerCHANGE(maxis.leftAction, val);
					if (maxis.right > 0)
						triggerCHANGE(maxis.rightAction, val);
				}
			}
		}
		
		override public function destroy():void
		{
			
			super.destroy();
			
			_input.stopActionsOf(this);
			
			var controllerDef:Object;
			var i:String;
			for (i in _devices)
			{
				controllerDef = _devices[i];
				destroyDevice(controllerDef.device);
				_devices.splice(int(i), 1);
				_devices[i] = null;
			}
			_devices.length = 0;
			
			gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, handleDeviceAttached);
			gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, handleDeviceRemoved);
		
		}
	
	}
}