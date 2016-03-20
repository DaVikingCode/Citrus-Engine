package citrus.input.controllers.gamepad.controls
{
	import citrus.input.controllers.gamepad.Gamepad;
	import citrus.input.InputController;
	import citrus.math.MathVector;
	
	public class StickController extends InputController implements Icontrol
	{
		protected var _gamePad:Gamepad;
		
		protected var _hAxis:String;
		protected var _vAxis:String;
		
		protected var _prevRight:Number = 0;
		protected var _prevLeft:Number = 0;
		protected var _prevUp:Number = 0;
		protected var _prevDown:Number = 0;
		
		protected var _vec:MathVector;
		
		public var upAction:String;
		public var downAction:String;
		public var leftAction:String;
		public var rightAction:String;
		
		protected var _downActive:Boolean = false;
		protected var _upActive:Boolean = false;
		protected var _leftActive:Boolean = false;
		protected var _rightActive:Boolean = false;
		protected var _stickActive:Boolean = false;
		
		public var invertX:Boolean;
		public var invertY:Boolean;
		public var threshold:Number = 0.1;
		public var precision:int = 100;
		public var digital:Boolean = false;
		
		/**
		 * StickController is an abstraction of the stick controls of a gamepad. This InputController will see its axis values updated
		 * via its corresponding gamepad object and send his own actions to the Input system.
		 * 
		 * It should not be instantiated manually.
		 * 
		 * @param	name
		 * @param	hAxis left to right
		 * @param	vAxis up to down
		 * @param	up action name
		 * @param	right action name
		 * @param	down action name
		 * @param	left action name
		 * @param	invertX
		 * @param	invertY
		 */
		public function StickController(name:String, parentGamePad:Gamepad,hAxis:String,vAxis:String, up:String = null, right:String = null, down:String = null, left:String = null, invertX:Boolean = false, invertY:Boolean = false)
		{
			super(name);
			_gamePad = parentGamePad;
			upAction = up;
			downAction = down;
			leftAction = left;
			rightAction = right;
			_hAxis = hAxis;
			_vAxis = vAxis;
			this.invertX = invertX;
			this.invertY = invertY;
			_vec = new MathVector();
		}
		
		public function hasControl(id:String):Boolean
		{
			return (id == _hAxis || id == _vAxis);
		}
		
		public function updateControl(control:String, value:Number):void
		{
			value = ((value * precision) >> 0) / precision;
			
			value = (value <= threshold && value >= -threshold) ? 0 : value;
			
			if (control == _vAxis)
			{
				_prevUp = up;
				_prevDown = down;
				
				_vec.y = (digital ?  value >> 0 : value) * (invertY ? -1 : 1);
				
				if (downAction && _prevDown != down)
				{
						if (_downActive && (_prevDown > down || down == 0))
						{
							triggerOFF(downAction, 0, null, _gamePad.defaultChannel);
							_downActive = false;
						}
						if (down > 0)
						{
							triggerCHANGE(downAction, down, null, _gamePad.defaultChannel);
							_downActive = true;
						}
				}
				
				if (upAction && _prevUp != up)
				{
						if (_upActive && (_prevUp > up || up == 0))
						{
							triggerOFF(upAction, 0, null, _gamePad.defaultChannel);
							_upActive = false;
						}
						if (up > 0)
						{
							triggerCHANGE(upAction, up, null, _gamePad.defaultChannel);
							_upActive = true;
						}
				}
			}
			else if (control == _hAxis)
			{
				_prevLeft = left;
				_prevRight = right;
			
				_vec.x = (digital ?  value >> 0 : value) * (invertX ? -1 : 1);
				
				if (leftAction && _prevLeft != left)
				{
						if (_leftActive && _prevLeft > left || left == 0)
						{
							triggerOFF(leftAction, 0, null, _gamePad.defaultChannel);
							_leftActive = false;
						}
						if (left > 0)
						{
							triggerCHANGE(leftAction, left, null, _gamePad.defaultChannel);
							_leftActive = true;
						}
				}
				
				if (rightAction && _prevRight != right)
				{
						if (_rightActive && _prevRight > right || right == 0)
						{
							triggerOFF(rightAction, 0, null, _gamePad.defaultChannel);
							_rightActive = false;
						}
						if (right > 0)
						{
							triggerCHANGE(rightAction, right, null, _gamePad.defaultChannel);
							_rightActive = true;
						}
				}
			}
			
			if(_gamePad.triggerActivity)
				stickActive = _vec.length == 0 ? false : true;
		
		}
		
		protected function set stickActive(val:Boolean):void
		{
			if (val == _stickActive)
				return;
			else
			{
				if (val)
					triggerCHANGE(name, 1, null, Gamepad.activityChannel);
				else
					triggerOFF(name, 0, null, Gamepad.activityChannel);
				
				_stickActive = val;
			}
		}
		
		public function get y():Number
		{
			return _vec.y;
		}
		
		public function get x():Number
		{
			return _vec.x;
		}
		
		public function get up():Number
		{
			return -_vec.y;
		}
		
		public function get down():Number
		{
			return _vec.y;
		}
		
		public function get left():Number
		{
			return -_vec.x;
		}
		
		public function get right():Number
		{
			return _vec.x;
		}
		
		public function get length():Number
		{
			return _vec.length;
		}
		
		public function get angle():Number
		{
			return _vec.angle;
		}
		
		public function get hAxis():String
		{
			return _hAxis;
		}
		
		public function get vAxis():String
		{
			return _vAxis;
		}
		
		public function get gamePad():Gamepad
		{
			return _gamePad;
		}
		
		override public function destroy():void
		{
			_vec = null;
			super.destroy();
		}
	
	}

}