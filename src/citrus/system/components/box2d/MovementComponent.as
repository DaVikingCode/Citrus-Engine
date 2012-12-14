package citrus.system.components.box2d {

	import Box2D.Common.Math.b2Vec2;

	import citrus.system.Component;

	/**
	 * The Box2D movement component, we've to know the Box2D physics component to be able to move it.
	 */
	public class MovementComponent extends Component {
		
		protected var _physicsComponent:Box2DComponent;
		
		protected var _velocity:b2Vec2;

		public function MovementComponent(name:String, params:Object = null) {
			super(name, params);
		}
			
		override public function initialize(poolObjectParams:Object = null):void {
			
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
