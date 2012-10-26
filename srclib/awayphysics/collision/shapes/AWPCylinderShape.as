package awayphysics.collision.shapes {
	public class AWPCylinderShape extends AWPCollisionShape {
		
		private var _radius:Number;
		private var _height:Number;
		
		public function AWPCylinderShape(radius : Number = 50, height : Number = 100) {
			
			_radius = radius;
			_height = height;
			
			pointer = bullet.createCylinderShapeMethod(radius * 2 / _scaling, height / _scaling, radius * 2 / _scaling);
			super(pointer, 2);
		}
		
		public function get radius():Number {
			return _radius * m_localScaling.x;
		}
		
		public function get height():Number {
			return _height * m_localScaling.y;
		}
	}
}