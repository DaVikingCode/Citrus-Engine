package com.citrusengine.objects.platformer.simple {

	import flash.ui.Keyboard;

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
			
			velocity.y = gravity;
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);

			var moveKeyPressed:Boolean = false;

			if (_ce.input.isDoing("left",inputChannel)) {
				velocity.x -= acceleration;
				moveKeyPressed = true;
			}

			if (_ce.input.isDoing("right",inputChannel)) {
				velocity.x += acceleration;
				moveKeyPressed = true;
			}

			if (velocity.x > (maxVelocity))
				velocity.x = maxVelocity;
			else if (velocity.x < (-maxVelocity))
				velocity.x = -maxVelocity;
		}
	}
}
