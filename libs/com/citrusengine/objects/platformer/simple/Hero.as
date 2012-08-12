package com.citrusengine.objects.platformer.simple {

	import flash.ui.Keyboard;

	public class Hero extends DynamicObject {
		
		public var gravity:Number = 50;

		public var acceleration:Number = 10;
		public var maxVelocity:Number = 80;

		public function Hero(name:String, params:Object = null) {
			
			super(name, params);
		}
			
		override public function initialize():void {
			
			super.initialize();
			
			velocity.y = gravity;
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);

			var moveKeyPressed:Boolean = false;

			if (_ce.input.isDown(Keyboard.LEFT)) {
				velocity.x -= acceleration;
				moveKeyPressed = true;
			}

			if (_ce.input.isDown(Keyboard.RIGHT)) {
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
