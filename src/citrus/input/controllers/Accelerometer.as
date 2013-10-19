package citrus.input.controllers 
{

	import citrus.input.InputController;

	import flash.events.AccelerometerEvent;
	import flash.geom.Vector3D;
	import flash.sensors.Accelerometer;
	import flash.utils.Dictionary;
	
	public class Accelerometer extends InputController
	{
		protected var _accel: flash.sensors.Accelerometer;
		
		//current accel
		protected var _a:Vector3D = new Vector3D();
		//target accel
		protected var _t:Vector3D = new Vector3D();
		
		//rotation
		protected var _rot:Vector3D = new Vector3D();
		//previous rotation
		protected var _prevRot:Vector3D = new Vector3D();
		
		//only start calculating when received first events from device.
		protected var receivedFirstAccelUpdate:Boolean = false;
		
		/**
		 * Angle inside which no action is triggered, representing the "center" or the "idle position".
		 * the more this angle is big, the more the device needs to be rotated to start triggering actions.
		 */
		public var idleAngleZ:Number = Math.PI / 8;
		
		/**
		 * Angle inside which no action is triggered, representing the "center" or the "idle position".
		 * the more this angle is big, the more the device needs to be rotated to start triggering actions.
		 */
		public var idleAngleX:Number = Math.PI / 6;
		
		/**
		 * Set this to offset the Z rotation calculations :
		 */
		public var offsetZAngle:Number = 0;
		
		/**
		 * Set this to offset the Y rotation calculations :
		 */
		public var offsetYAngle:Number = 0;
		
		/**
		 * Set this to offset the X rotation calculations :
		 */
		public var offsetXAngle:Number = -Math.PI/2 + Math.PI/4;
		
		/**
		 * easing of the accelerometer's X value.
		 */
		public var easingX:Number = 0.5;
		/**
		 * easing of the accelerometer's Y value.
		 */
		public var easingY:Number = 0.5;
		/**
		 * easing of the accelerometer's Z value.
		 */
		public var easingZ:Number = 0.5;
		
		/**
		 * action name for the rotation on the X axis.
		 */
		public static const ROT_X:String = "rotX";
		/**
		 * action name for the rotation on the Y axis.
		 */
		public static const ROT_Y:String = "rotY";
		/**
		 * action name for the rotation on the Z axis.
		 */
		public static const ROT_Z:String = "rotZ";
		
		/**
		 * action name for the raw accelerometer X value.
		 */
		public static const RAW_X:String = "rawX";
		/**
		 * action name for the raw accelerometer Y value.
		 */
		public static const RAW_Y:String = "rawY";
		/**
		 * action name for the raw accelerometer Z value.
		 */
		public static const RAW_Z:String = "rawZ";
		
		/**
		 * action name for the  X angular velocity value.
		 */
		public static const VEL_X:String = "velX";
		/**
		 * action name for the  Y angular velocity value.
		 */
		public static const VEL_Y:String = "velY";
		/**
		 * action name for the  Z angular velocity value.
		 */
		public static const VEL_Z:String = "velZ";
		
		/**
		 * send the new raw values on each frame.
		 */
		public var triggerRawValues:Boolean = false;
		/**
		 * send the new rotation values on each frame in radian.
		 */
		public var triggerAxisRotation:Boolean = false;
		
		/**
		 * if true, on each update values will be computed to send custom Actions (such as left right up down by default)
		 */
		public var triggerActions:Boolean = false;
		
		/**
		 * if true, on each update values will be computed to send the angular velocity of the device
		 */
		public var triggerVelocity:Boolean = false;
		
		/**
		 * helps prevent too much calls to triggerON/OFF by keeping track of what action is on/off
		 */
		protected var actions:Dictionary;
		
		public function Accelerometer(name:String,params:Object = null) 
		{
			super(name, params);
			
			_updateEnabled = true;
			
			if (! flash.sensors.Accelerometer.isSupported)
			{
				trace(this, "Accelerometer is not supported");
				enabled = false;
			}
			else
			{
				_accel = new  flash.sensors.Accelerometer();
				_accel.addEventListener(AccelerometerEvent.UPDATE, onAccelerometerUpdate);
			}
			
		}
		
		/*
		 * This updates the target values of acceleration which will be eased on each frame through the update function.
		 */
		public function onAccelerometerUpdate(e:AccelerometerEvent):void
		{
			_t.x = e.accelerationX;
			_t.y = e.accelerationY;
			_t.z = e.accelerationZ;
			
			receivedFirstAccelUpdate = true;
		}
		
		override public function update():void
		{
			if (!receivedFirstAccelUpdate)
				return;
			
			//ease values
			_a.x += (_t.x -_a.x) * easingX;
			_a.y += (_t.y -_a.y) * easingY;
			_a.z += (_t.z -_a.z) * easingZ;
			
			_rot.x = Math.atan2(_a.y, _a.z) + offsetXAngle;
			_rot.y = Math.atan2(_a.x, _a.z) + offsetYAngle;
			_rot.z = Math.atan2(_a.x, _a.y) + offsetZAngle;
			
			if (triggerRawValues)
			{
				triggerCHANGE(RAW_X, _a.x);
				triggerCHANGE(RAW_Y, _a.y);
				triggerCHANGE(RAW_Z, _a.z);
			}	
			
			if (triggerAxisRotation)
			{
				triggerCHANGE(ROT_X, _rot.x);
				triggerCHANGE(ROT_Y, _rot.y);
				triggerCHANGE(ROT_Z, _rot.z);
			}
			
			if (triggerVelocity)
			{
				triggerCHANGE(VEL_X, (_rot.x - _prevRot.x) * _ce.stage.frameRate);
				triggerCHANGE(VEL_Y, (_rot.y - _prevRot.y) * _ce.stage.frameRate);
				triggerCHANGE(VEL_Z, (_rot.z - _prevRot.z) * _ce.stage.frameRate);
			}
			
			if (triggerActions)
				customActions();
				
			_prevRot.x = _rot.x;
			_prevRot.y = _rot.y;
			_prevRot.z = _rot.z;
			
		}
		
		/**
		 * Override this function to customize actions based on orientation
		 * by default, if triggerActions is set to true, customActions will be called
		 * in which default actions such as left/right/up/down will be triggered
		 * based on the actual rotation of the device:
		 * in landscape mode, pivoting the device to the right will trigger a right action for example.
		 * to make it available in portrait mode, the offsetZAngle can help rotate that calculation by 90° or more
		 * depeding on your screen orientation...
		 * 
		 * this was mostly tested on a fixed landscape orientation setting.
		 */
		protected function customActions():void
		{
			if (!actions)
			{
				actions = new Dictionary();
				actions["left"] = false;
				actions["right"] = false;
				actions["down"] = false;
				actions["up"] = false;
				actions["jump"] = false;
			}
			
			//in idle position on Z
			if (_rot.z < idleAngleZ && _rot.z > - idleAngleZ)
			{
				if (actions.left)
				{
					triggerOFF("left", 0);
					actions.left = false;
				}
				if (actions.right)
				{
					triggerOFF("right", 0);
					actions.right = false;
				}
			}
			else
			{
				//going right
				if (_rot.z < 0 && _rot.z > -Math.PI/2)
				{
					if (!actions.right)
					{
						triggerON("right", 1);
						actions.right = true;
					}
				}
				
				//going left
				if (_rot.z > 0 && _rot.z < Math.PI / 2)
				{
					if (!actions.left)
					{
						triggerON("left", 1);
						actions.left = true;
					}
				}
			}
			
			//in idle position on X
			if (_rot.x < idleAngleX && _rot.x > - idleAngleX)
			{
				if (actions.jump)
				{
					triggerOFF("jump", 0);
					actions.jump = false;
				}
				if (actions.up)
				{
					triggerOFF("up", 0);
					actions.up = false;
				}
				if (actions.down)
				{
					triggerOFF("down", 0);
					actions.down = false;
				}
			}
			else
			{
				//going up
				if (_rot.x < 0 && _rot.x > -Math.PI/2)
				{
					if (!actions.jump)
					{
						triggerON("jump", 1);
						actions.jump = true;
					}
					if (!actions.up)
					{
						triggerON("up", 1);
						actions.up = true;
					}
				}
				
				//going down
				if (_rot.x > 0 && _rot.x < Math.PI / 2)
				{
					if (!actions.down)
					{
						triggerON("down", 1);
						actions.down = true;
					}
				}
			}
			
			
		}
		
		/*
		 * Acceleration Vector
		 */
		public function get acceleration():Vector3D { return _a; }
		
		/*
		 * Rotation Vector
		 */
		public function get rotation():Vector3D { return _rot; }
		
	}

}