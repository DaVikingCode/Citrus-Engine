package awayphysics.collision.shapes {
	import flash.geom.Vector3D;
	
	public class AWPBoxShape extends AWPCollisionShape {
		
		private var _dimensions:Vector3D;
		
		public function AWPBoxShape(width : Number = 100, height : Number = 100, depth : Number = 100) {
			_dimensions = new Vector3D(width, height, depth);
			pointer = bullet.createBoxShapeMethod(width / _scaling, height / _scaling, depth / _scaling);
			super(pointer, 0);
		}
		
		public function get dimensions():Vector3D {
			return new Vector3D(_dimensions.x * m_localScaling.x, _dimensions.y * m_localScaling.y, _dimensions.z * m_localScaling.z);
		}
	}
}