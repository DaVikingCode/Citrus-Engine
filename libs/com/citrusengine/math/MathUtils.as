package com.citrusengine.math {

	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class MathUtils {
		
		public static function RotateAroundInternalPoint(object:DisplayObject, pointToRotateAround:Point, rotation:Number):void {
			
			// Thanks : http://blog.open-design.be/2009/02/05/rotate-a-movieclipdisplayobject-around-a-point/
			
			// get matrix object from your MovieClip (mc)
			var m:Matrix = object.transform.matrix;
			
			// set the point around which you want to rotate your MovieClip (relative to the MovieClip position)
			var point:Point = pointToRotateAround;
			
			// get the position of the MovieClip related to its origin and the point around which it needs to be rotated
			point = m.transformPoint(point);
			// set it
			m.translate(-point.x, -point.y);
			
			// rotate
			m.rotate(rotation * (Math.PI / 180));
			
			// and get back to its "normal" position
			m.translate(point.x, point.y);
			
			// finally, to set the MovieClip position, use this
			object.transform.matrix = m;		
		}
	}
}
