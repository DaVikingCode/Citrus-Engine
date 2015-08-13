package dragonBones.objects
{
	import flash.geom.Matrix;
	import dragonBones.utils.TransformUtil;

	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/
	public class DBTransform
	{
		/**
		 * Position on the x axis.
		 */
		public var x:Number;
		/**
		 * Position on the y axis.
		 */
		public var y:Number;
		/**
		 * Skew on the x axis.
		 */
		public var skewX:Number;
		/**
		 * skew on the y axis.
		 */
		public var skewY:Number;
		/**
		 * Scale on the x axis.
		 */
		public var scaleX:Number;
		/**
		 * Scale on the y axis.
		 */
		public var scaleY:Number;
		/**
		 * The rotation of that DBTransform instance.
		 */
		public function get rotation():Number
		{
			return skewX;
		}
		public function set rotation(value:Number):void
		{
			skewX = skewY = value;
		}
		/**
		 * Creat a new DBTransform instance.
		 */
		public function DBTransform()
		{
			x = 0;
			y = 0;
			skewX = 0;
			skewY = 0;
			scaleX = 1
			scaleY = 1;
		}
		/**
		 * Copy all properties from this DBTransform instance to the passed DBTransform instance.
		 * @param node
		 */
		public function copy(transform:DBTransform):void
		{
			x = transform.x;
			y = transform.y;
			skewX = transform.skewX;
			skewY = transform.skewY;
			scaleX = transform.scaleX;
			scaleY = transform.scaleY;
		}
		
		public function add(transform:DBTransform):void
		{
			x += transform.x;
			y += transform.y;
			skewX += transform.skewX;
			skewY += transform.skewY;
			scaleX *= transform.scaleX;
			scaleY *= transform.scaleY;
		}
		
		public function minus(transform:DBTransform):void
		{
			x -= transform.x;
			y -= transform.y;
			skewX -= transform.skewX;
			skewY -= transform.skewY;
			scaleX /= transform.scaleX;
			scaleY /= transform.scaleY;
		}
		
		public function divParent(transform:DBTransform, createNew:Boolean = false):DBTransform
		{
			var output:DBTransform = createNew ? new DBTransform() : this;
			var parentMatrix:Matrix = new Matrix();
			
			TransformUtil.transformToMatrix(transform, parentMatrix);
			var xtx:Number = x - parentMatrix.tx;
			var yty:Number = y - parentMatrix.ty;
			var adcb:Number = parentMatrix.a * parentMatrix.d - parentMatrix.c * parentMatrix.b;
			
			output.x = (xtx * parentMatrix.d - yty * parentMatrix.c)/adcb;
			output.y = (yty * parentMatrix.a - xtx * parentMatrix.b)/adcb;
			output.scaleX = scaleX / transform.scaleX;
			output.scaleY = scaleY / transform.scaleY;
			output.skewX = skewX - transform.skewX;
			output.skewY = skewY - transform.skewY;
			return output;
		}
		
		public function normalizeRotation():void
		{
			skewX = TransformUtil.normalizeRotation(skewX);	
			skewY = TransformUtil.normalizeRotation(skewY);	
		}
		
		/**
		 * Get a string representing all DBTransform property values.
		 * @return String All property values in a formatted string.
		 */
		public function toString():String
		{
			var string:String = "x:" + x + " y:" + y + " skewX:" + skewX + " skewY:" + skewY + " scaleX:" + scaleX + " scaleY:" + scaleY;
			return string;
		}
	}
}