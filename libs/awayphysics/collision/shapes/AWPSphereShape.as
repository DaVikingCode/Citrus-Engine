package awayphysics.collision.shapes {
	public class AWPSphereShape extends AWPCollisionShape {
		
		private var _radius:Number;
		
		public function AWPSphereShape(radius : Number = 50) {
			_radius = radius;
			
			pointer = bullet.createSphereShapeMethod(radius / _scaling);
			super(pointer, 1);
		}
		
		public function get radius():Number {
			return _radius * m_localScaling.x;
		}
	}
}