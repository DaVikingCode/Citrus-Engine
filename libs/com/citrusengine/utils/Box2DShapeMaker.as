package com.citrusengine.utils 
{
	import Box2DAS.Collision.Shapes.b2CircleShape;
	import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Common.V2;
	public class Box2DShapeMaker 
	{
		public static function BeveledRect(width:Number, height:Number, bevel:Number):b2PolygonShape
		{
			var halfWidth:Number = width * 0.5;
			var halfHeight:Number = height * 0.5;
			
			var shape:b2PolygonShape = new b2PolygonShape();
			var vertices:Vector.<V2> = new Vector.<V2>();
			vertices.push(new V2( -halfWidth + bevel, -halfHeight));
			vertices.push(new V2( halfWidth - bevel, -halfHeight));
			vertices.push(new V2( halfWidth, -halfHeight + bevel));
			vertices.push(new V2( halfWidth, halfHeight - bevel));
			vertices.push(new V2( halfWidth - bevel, halfHeight));
			vertices.push(new V2( -halfWidth + bevel, halfHeight));
			vertices.push(new V2( -halfWidth, halfHeight - bevel));
			vertices.push(new V2( -halfWidth, -halfHeight + bevel));
			shape.Set(vertices);
			
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
			shape.m_radius = radius;
			
			return shape;
		}
	}

}