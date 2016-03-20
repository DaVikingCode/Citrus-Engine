package citrus.physics.simple 
{

	import citrus.math.MathVector;
	import citrus.objects.CitrusSprite;
	
	public class SimpleCollision 
	{
		public static const BEGIN:uint = 0;
		public static const PERSIST:uint = 1;
		
		public var self:CitrusSprite;
		public var other:CitrusSprite;
		public var normal:MathVector;
		public var impact:Number;
		public var type:uint;
		
		public function SimpleCollision(self:CitrusSprite, other:CitrusSprite, normal:MathVector, impact:Number, type:uint) 
		{
			this.self = self;
			this.other = other;
			this.normal = normal;
			this.impact = impact;
			this.type = type;
		}
	}

}