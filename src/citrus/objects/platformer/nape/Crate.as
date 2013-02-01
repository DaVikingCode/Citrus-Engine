package citrus.objects.platformer.nape {

	import citrus.objects.NapePhysicsObject;

	/**
	 * An object made for Continuous Collision Detection. It should only be used for very fast, small moving dynamic bodies.
	 */
	public class Crate extends NapePhysicsObject {

		public function Crate(name:String, params:Object = null) {
			super(name, params);
		}

		override protected function createBody():void {
			
			super.createBody();
			
			_body.isBullet = true;
		}
		
		override protected function createMaterial():void {
			
			super.createMaterial();
			
			_material.density = 0.3;
			_material.elasticity = 0;
		}

	}
}
