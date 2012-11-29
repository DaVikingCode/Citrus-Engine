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
		public var z:Number;
		
		public function get rotation():Number
		{
			return skewY;
		}
		public function set rotation(value:Number):void
		{
			skewX = skewY = value;
		}
		
		public function Node(_x:Number = 0, _y:Number = 0, _skewX:Number = 0, _skewY:Number = 0, _scaleX:Number = 1, _scaleY:Number = 1)
		{
			x = _x || 0;
			y = _y || 0;
			skewX = _skewX || 0;
			skewY = _skewY || 0;
			scaleX = _scaleX;
			scaleY = _scaleY;
			
			z = 0;
		}
		
		public function copy(node:Node):void
		{
			x = node.x;
			y = node.y;
			scaleX = node.scaleX;
			scaleY = node.scaleY;
			skewX = node.skewX;
			skewY = node.skewY;
			z = node.z;
		}
		
		public function toString():String {
			var _str:String = "";
			_str += "x:" + x + " y:" + y + " skewX:" + skewX + " skewY:" + skewY + " scaleX:" + scaleX + " scaleY:" + scaleY;
			return _str;
		}
	}
}