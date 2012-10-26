package awayphysics.collision.shapes {
	public class AWPConeShape extends AWPCollisionShape {
		
		private var _radius:Number;
		private var _height:Number;
		
		public function AWPConeShape(radius : Number = 50, height : Number = 100) {
			
			_radius = radius;
			_height = height;
			
			pointer = bullet.createConeShapeMethod(radius / _scaling, height / _scaling);
			super(pointer, 4);
		}
		
		public function get radius():Number {
			return _radius * m_localScaling.x;
		}
		
		public function get height():Number {
			return _height * m_localScaling.y;
		}
	}
}