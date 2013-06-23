package citrus.objects.vehicle.nape {

	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Hills;
	import citrus.physics.nape.NapeUtils;

	import nape.callbacks.InteractionCallback;
	import nape.phys.Material;
	import nape.shape.Polygon;

	import org.osflash.signals.Signal;
	
	/**
	 * In some games, like <a href="http://snuggletruck.com/">Snuggle Truck</a>, you carry some objects in your car and you've to reach 
	 * the end of the race with many of them. That's what a nugget is, a whatever item you want that you ahve to save!
	 */
	public class Nugget extends NapePhysicsObject {
		
		/**
		 * Dispatches when a nugget falls from the car.
		 */
		public var onNuggetLost:Signal;
		
		protected var _driver:Driver;
		protected var _lost:Boolean = false;

		public function Nugget(name:String, params:Object = null) {
			
			_beginContactCallEnabled = true;
			updateCallEnabled = true;

			super(name, params);
			
			onNuggetLost = new Signal(Nugget);
		}
		
		override public function destroy():void {
			
			onNuggetLost.removeAll();
			
			super.destroy();
		}
		
		override protected function createMaterial():void {
			
			_material = new Material(0.0, 0.2, 0.3, 4, 0.01);
		}

		override protected function createShape():void {

			_shape = new Polygon(Polygon.rect(0, 0, 12, 12), _material);
			_body.shapes.add(_shape);
			_body.align();
		}

		override public function handleBeginContact(callback:InteractionCallback):void {
			
			super.handleBeginContact(callback);
			
			if (!_lost && NapeUtils.CollisionGetOther(this, callback) is Hills) {
					
				_lost = true;
				
				onNuggetLost.dispatch(this);
			}
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (!_driver)
				_driver = _ce.state.getFirstObjectByType(Driver) as Driver;
			
			if (_lost && _driver.x > x + _ce.stage.stageWidth)
				kill = true;
		}

		public function get lost():Boolean {
			return _lost;
		}
	}

}