package dragonBones.objects
{
	/**
	 * TweenNode provides transformation for a tween object.
	 */
	public class TweenNode extends Node
	{
		private static const DOUBLE_PI:Number = Math.PI * 2;
		
		public var tweenRotate:int;
		
		public function TweenNode(x:Number = 0, y:Number = 0, skewX:Number = 0, skewY:Number = 0, scaleX:Number = 1, scaleY:Number = 1)
		{
			super(x, y, skewX, skewY, scaleX, scaleY);
		}
		
		public function subtract(from:Node, to:Node):void
		{
			x = to.x - from.x;
			y = to.y - from.y;
			scaleX = to.scaleX - from.scaleX;
			scaleY = to.scaleY - from.scaleY;
			skewX = to.skewX - from.skewX;
			skewY = to.skewY - from.skewY;
			
			skewX %= DOUBLE_PI;
			if (skewX > Math.PI)
			{
				skewX -= DOUBLE_PI;
			}
			if (skewX < -Math.PI)
			{
				skewX += DOUBLE_PI;
			}
			skewY %= DOUBLE_PI;
			if (skewY > Math.PI)
			{
				skewY -= DOUBLE_PI;
			}
			if (skewY < -Math.PI)
			{
				skewY += DOUBLE_PI;
			}
			var tweenNode:TweenNode = to as TweenNode;
			if (tweenNode && tweenNode.tweenRotate)
			{
				skewX += tweenNode.tweenRotate * DOUBLE_PI;
				skewY += tweenNode.tweenRotate * DOUBLE_PI;
			}
		}
	}
}