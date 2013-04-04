package citrus.input.controllers 
{

	import citrus.input.InputController;

	import flash.events.AccelerometerEvent;
	import flash.sensors.Accelerometer;
	
	public class Accelerometer extends InputController
	{
		private var _accel: flash.sensors.Accelerometer;
		
		private var _aX:Number = 0;
		private var _aY:Number = 0;
		private var _aZ:Number = 0;
		
		private var _taX:Number = 0;
		private var _taY:Number = 0;
		private var _taZ:Number = 0;
		
		/**
		 * easing of the accelerometer's X value.
		 */
		public var easingX:Number = 0.3;
		/**
		 * easing of the accelerometer's Y value.
		 */
		public var easingY:Number = 0.3;
		/**
		 * easing of the accelerometer's Z value.
		 */
		public var easingZ:Number = 0.3;
		
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
		 * send the new raw values on each frame.
		 */
		public var triggerRawValues:Boolean = false;
		/**
		 * send the new rotation values on each frame in radian.
		 */
		public var triggerAxisRotation:Boolean = true;
		
		public function Accelerometer(name:String,params:Object) 
		{
			super(name, params);
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
			_taX = e.accelerationX;
			_taY = e.accelerationY;
			_taZ = e.accelerationZ;
		}
		
		override public function update():void
		{
			//ease values
			_aX += (_taX -_aX) * easingX;
			_aY += (_taY -_aY) * easingY;
			_aZ += (_taZ -_aZ) * easingZ;
			
			if (triggerRawValues)
			{
				triggerVALUECHANGE(RAW_X, _aX);
				triggerVALUECHANGE(RAW_Y, _aY);
				triggerVALUECHANGE(RAW_Z, _aZ);
			}	
			
			if (triggerAxisRotation)
			{
				triggerVALUECHANGE(ROT_X, Math.atan2(_aY, _aZ));
				triggerVALUECHANGE(ROT_Y, Math.atan2(_aX, _aZ));
				triggerVALUECHANGE(ROT_Z, Math.atan2(_aX, _aY));
			}
			
		}
		
	}

}