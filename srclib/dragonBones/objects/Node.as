package dragonBones.objects
{
	
	/**
	 * Node provides a base class for any object that has a transformation.
	 */
	public class Node
	{
		public var x:Number;
		public var y:Number;
		public var scaleX:Number;
		public var scaleY:Number;
		public var skewX:Number;
		public var skewY:Number;
		public var pivotX:Number;
		public var pivotY:Number;
		public var z:Number;
		
		public function get rotation():Number
		{
			return skewX;
		}
		public function set rotation(value:Number):void
		{
			skewX = skewY = value;
		}
		
		public function Node()
		{
			setValues();
		}
		
		public function setValues(x:Number = 0, y:Number = 0, skewX:Number = 0, skewY:Number = 0, scaleX:Number = 0, scaleY:Number = 0, pivotX:Number = 0, pivotY:Number = 0, z:int = 0):void
		{
			this.x = x || 0;
			this.y = y || 0;
			this.skewX = skewX || 0;
			this.skewY = skewY || 0;
			this.scaleX = scaleX || 0;
			this.scaleY = scaleY || 0;
			
			this.pivotX = pivotX || 0;
			this.pivotY = pivotY || 0;
			this.z = z;
		}
		
		public function copy(node:Node):void
		{
			x = node.x;
			y = node.y;
			scaleX = node.scaleX;
			scaleY = node.scaleY;
			skewX = node.skewX;
			skewY = node.skewY;
			pivotX = node.pivotX;
			pivotY = node.pivotY;
			z = node.z;
		}
		
		public function toString():String 
		{
			var string:String = "x:" + x + " y:" + y + " skewX:" + skewX + " skewY:" + skewY + " scaleX:" + scaleX + " scaleY:" + scaleY;
			return string;
		}
	}
}