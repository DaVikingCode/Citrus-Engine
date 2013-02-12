package citrus.math {
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class MathUtils {
		
		public static function DistanceBetweenTwoPoints(x1:Number, x2:Number, y1:Number, y2:Number):Number {
			
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		public static function RotateAroundInternalPoint(object:DisplayObject, pointToRotateAround:Point, rotation:Number):void {
			
			// Thanks : http://blog.open-design.be/2009/02/05/rotate-a-movieclipdisplayobject-around-a-point/
			
			var m:Matrix = object.transform.matrix;
			
			var point:Point = pointToRotateAround;
			point = m.transformPoint(point);
			
			RotateAroundExternalPoint(object, point, rotation);
		}
		
		public static function RotateAroundExternalPoint(object:DisplayObject, pointToRotateAround:Point, rotation:Number):void {
			
			var m:Matrix = object.transform.matrix;
			
			m.translate(-pointToRotateAround.x, -pointToRotateAround.y);
			m.rotate(rotation * (Math.PI / 180));
			m.translate(pointToRotateAround.x, pointToRotateAround.y);
			
			object.transform.matrix = m;
		}
		
		/**
		 * Rotates a flash Point around Origin (like MathVector.rotate() )
		 * @param	p flash.geom.Point
		 * @param	a angle in radians
		 * @return	returns a new rotated point.
		 */
		public static  function rotatePoint(p:Point, a:Number):Point
		{
			var c:Number = Math.cos(a);
			var s:Number = Math.sin(a);
			return new Point(p.x * c + p.y * s, -p.x * s + p.y * c);
		}
		
		/**
		 * Get the linear equation from two points.
		 * @return an object, m is the slope and b a constant term.
		 */
		public static function lineEquation(p0:Point, p1:Point):Object{
			
			var a:Number = (p1.y - p0.y) / (p1.x - p0.x);
			var b:Number = p0.y - a * p0.x;
			
			return {m:a, b:b}; 
		}
		
		/**
		 * Linear interpolation function
		 * @param	a start value
		 * @param	b end value
		 * @param	ratio interpolation amount
		 * @return
		 */
		public static function lerp(a:Number,b:Number,ratio:Number):Number
		{
			return a + (b - a) * ratio;
		}
		
		/**
		 * Creates the axis aligned bounding box for a rotated rectangle.
		 * @param w width of the rotated rectangle
		 * @param h height of the rotated rectangle
		 * @param a angle of rotation around the topLeft point in radian
		 * @return flash.geom.Rectangle
		 */
		public static function createAABB(x:Number, y:Number, w:Number, h:Number, a:Number = 0):Rectangle {
			
			var aabb:Rectangle = new Rectangle(x, y, w, h);
			
			if (a == 0)
				return aabb;
				
			var c:Number = Math.cos(a);
			var s:Number = Math.sin(a);
			var cpos:Boolean;
			var spos:Boolean;
			
			if (s < 0) { s = -s; spos = false; } else { spos = true; }
			if (c < 0) { c = -c; cpos = false; } else { cpos = true; }
			
			aabb.width = h * s + w * c;
			aabb.height = h * c + w * s;
			
			if (cpos)
				if (spos)
					aabb.x -= h * s;
				else
					aabb.y -= w * s;
			else if (spos)
			{
				aabb.x -= w * c + h * s;
				aabb.y -= h * c;
			}
			else
			{
				aabb.x -= w * c;
				aabb.y -= w * s + h * c;
			}
			
			return aabb;
		}
		
		/**
		 * Creates the axis aligned bounding box for a rotated rectangle
		 * and returns offsetX , offsetY which is simply the x and y position of 
		 * the aabb relative to the rotated rectangle.
		 * @param w width of the rotated rectangle
		 * @param h height of the rotated rectangle
		 * @param a angle of rotation around the topLeft point in radian
		 * @return {rect:flash.geom.Rectangle,offsetX:Number,offsetY:Number}
		 */
		public static function createAABBData(x:Number, y:Number, w:Number, h:Number, a:Number = 0):Object {
			
			var aabb:Rectangle = new Rectangle(x, y, w, h);
			var offX:Number = 0;
			var offY:Number = 0;
			
			if (a == 0)
				return { offsetX:0, offsetY:0, rect:aabb };
				
			var c:Number = Math.cos(a);
			var s:Number = Math.sin(a);
			var cpos:Boolean;
			var spos:Boolean;
			
			if (s < 0) { s = -s; spos = false; } else { spos = true; }
			if (c < 0) { c = -c; cpos = false; } else { cpos = true; }
			
			aabb.width = h * s + w * c;
			aabb.height = h * c + w * s;
			
			if (cpos)
				if (spos)
					offX -= h * s;
				else
					offY -= w * s;
			else if (spos)
			{
				offX -= w * c + h * s;
				offY -= h * c;
			}
			else
			{
				offX -= w * c;
				offY -= w * s + h * c;
			}
			
			aabb.x += offX;
			aabb.y += offY;
			
			return { offsetX:offX, offsetY:offY, rect:aabb };
		}
	}
}
