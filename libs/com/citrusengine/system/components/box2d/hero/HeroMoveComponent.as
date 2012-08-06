package com.citrusengine.system.components.box2d.hero {

	import com.citrusengine.system.components.InputComponent;
	import Box2DAS.Common.V2;

	import com.citrusengine.system.components.box2d.MoveComponent;

	/**
	 * @author Aymeric
	 */
	public class HeroMoveComponent extends MoveComponent {
		
		public var acceleration:Number = 1;
		
		public var onGround:Boolean = false;
		
		protected var _inputComponent:InputComponent;

		public function HeroMoveComponent(name:String, params:Object = null) {
			super(name, params);
		}
			
		override public function initialize():void {
			
			super.initialize();
			
			_inputComponent = entity.components["input"];
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);

			if (_physicsComponent) {
					
				if (_inputComponent.rightKeyIsDown) {

					_velocity = V2.add(new V2(2, 0), new V2(2, 0));
				}
				
				if (_inputComponent.leftKeyIsDown) {
					
					_velocity = V2.subtract(new V2(2, 0), new V2(4, 0));
				}
				
				_physicsComponent.body.SetLinearVelocity(_velocity);
			}
		}
	}
}
