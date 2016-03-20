package citrus.objects.vehicle.nape {

	import citrus.objects.NapePhysicsObject;

	import nape.phys.Material;

	/**
	 * A wheel of the car. You may change its material.
	 */
	public class Wheel extends NapePhysicsObject {

		public var material:Material = new Material(0.15, 1, 2, 3, 2);

		public function Wheel(name:String, params:Object = null) {
			super(name, params);
		}

		override protected function createMaterial():void {

			_material = material;
		}
	}
}
