package com.citrusengine.objects.platformer.simple {

	public class Hero extends DynamicObject {
		
		public var gravity:Number = 50;

		public var acceleration:Number = 10;
		public var maxVelocity:Number = 80;
		
		/**
		 * Defines which input Channel to listen to.
		 */
		[Inspectable(defaultValue = "0")]
		public var inputChannel:uint = 0;

		public function Hero(name:String, params:Object = null) {
			
			super(name, params);
		}
			
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize(poolObjectParams);
			
			_velocity.y = gravity;
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);

			var moveKeyPressed:Boolean = false;

			if (_ce.input.isDoing("left",inputChannel)) {
				_velocity.x -= acceleration;
				moveKeyPressed = true;
			}

			if (_ce.input.isDoing("right",inputChannel)) {
				_velocity.x += acceleration;
				moveKeyPressed = true;
			}

			if (_velocity.x > (maxVelocity))
				_velocity.x = maxVelocity;
			else if (_velocity.x < (-maxVelocity))
				_velocity.x = -maxVelocity;
		}
	}
}
