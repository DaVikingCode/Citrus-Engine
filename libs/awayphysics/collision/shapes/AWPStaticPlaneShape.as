package awayphysics.collision.shapes {
	import flash.geom.Vector3D;

	public class AWPStaticPlaneShape extends AWPCollisionShape {
		
		private var _normal:Vector3D;
		private var _constant:Number;
		
		public function AWPStaticPlaneShape(normal : Vector3D = null, constant : Number = 0) {
			if (!normal) {
				normal = new Vector3D(0, 1, 0);
			}
			_normal = normal;
			_constant = constant;
			
			pointer = bullet.createStaticPlaneShapeMethod(normal.x, normal.y, normal.z, constant / _scaling);
			super(pointer, 8);
		}
		
		public function get normal():Vector3D {
			return _normal;
		}
		
		public function get constant():Number {
			return _constant;
		}
	}
}