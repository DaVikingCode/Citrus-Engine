package com.citrusengine.system.components.box2d {

	import Box2DAS.Common.V2;

	import com.citrusengine.system.Component;

	/**
	 * @author Aymeric
	 */
	public class MoveComponent extends Component {
		
		protected var _physicsComponent:Box2DComponent;
		
		protected var _velocity:V2;

		public function MoveComponent(name:String, params:Object = null) {
			super(name, params);
		}
			
		override public function initialize():void {
			
			super.initialize();
			
			_physicsComponent = entity.components["physics"];
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (_physicsComponent) {
				
				_velocity = _physicsComponent.body.GetLinearVelocity();
			}
		}

	}
}
