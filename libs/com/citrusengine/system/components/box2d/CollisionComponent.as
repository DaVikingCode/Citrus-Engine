package com.citrusengine.system.components.box2d {

	import Box2DAS.Dynamics.ContactEvent;

	import com.citrusengine.system.Component;

	/**
	 * The Box2D collision component, extends it to handle collision.
	 */
	public class CollisionComponent extends Component {

		public function CollisionComponent(name:String, params:Object = null) {
			
			super(name, params);
		}

		public function handlePreSolve(e:ContactEvent):void {
			
		}

		public function handleBeginContact(e:ContactEvent):void {
			
		}

		public function handleEndContact(e:ContactEvent):void {
			
		}
	}
}
