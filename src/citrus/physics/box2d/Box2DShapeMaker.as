package citrus.physics.box2d 
{

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	
	/**
	 * This class helps to define some complex shapes using vertices.
	 */
	public class Box2DShapeMaker 
	{
		public static function BeveledRect(width:Number, height:Number, bevel:Number):b2PolygonShape
		{
			var halfWidth:Number = width * 0.5;
			var halfHeight:Number = height * 0.5;
			
			var shape:b2PolygonShape = new b2PolygonShape();
			var vertices:Array = [];
			vertices.push(new b2Vec2( -halfWidth + bevel, -halfHeight));
			vertices.push(new b2Vec2( halfWidth - bevel, -halfHeight));
			vertices.push(new b2Vec2( halfWidth, -halfHeight + bevel));
			vertices.push(new b2Vec2( halfWidth, halfHeight - bevel));
			vertices.push(new b2Vec2( halfWidth - bevel, halfHeight));
			vertices.push(new b2Vec2( -halfWidth + bevel, halfHeight));
			vertices.push(new b2Vec2( -halfWidth, halfHeight - bevel));
			vertices.push(new b2Vec2( -halfWidth, -halfHeight + bevel));
			shape.SetAsArray(vertices);
			
			return shape;
		}
		
		public static function Rect(width:Number, height:Number):b2PolygonShape
		{
			var shape:b2PolygonShape = new b2PolygonShape();
			shape.SetAsBox(width * 0.5, height * 0.5);
			
			return shape;
		}
		
		public static function Circle(width:Number, height:Number):b2CircleShape
		{
			var radius:Number = (width + height) * 0.25;
			var shape:b2CircleShape = new b2CircleShape();
			shape.SetRadius(radius);
			
			return shape;
		}
	}

}