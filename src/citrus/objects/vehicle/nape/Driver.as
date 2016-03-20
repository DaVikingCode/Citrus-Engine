package citrus.objects.vehicle.nape {

	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Hills;
	import citrus.physics.nape.NapeUtils;

	import nape.callbacks.InteractionCallback;
	import nape.phys.Material;

	import org.osflash.signals.Signal;

	/**
	 * Normally, in a car there is a driver right? This guy will prevent nuggets to fall (take a look on the physics debug view) 
	 * as well as helping you to detect if your car crashed.
	 */
	public class Driver extends NapePhysicsObject {
		
		/**
		 * If the driver touches the ground, this Signal is dispatched. Often it means that you crashed.
		 */
		public var onGroundTouched:Signal;
		
		public var material:Material = new Material(0, 2, 2, 2.2, 0.01);

		public function Driver(name:String, params:Object = null) {
			
			_beginContactCallEnabled = true;
			
			super(name, params);
			
			onGroundTouched = new Signal();
		}
			
		override public function destroy():void {
			
			onGroundTouched.removeAll();
			
			super.destroy();
		}
		
		override protected function createMaterial():void {
			
			_material = material;
		}

		override public function handleBeginContact(callback:InteractionCallback):void {
			
			super.handleBeginContact(callback);
			
			if (NapeUtils.CollisionGetOther(this, callback) is Hills)
				onGroundTouched.dispatch();
		}

	}
}
