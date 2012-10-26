package starling.extensions.utils {

	import starling.display.Quad;
	import starling.display.Sprite;

	/**
	 * @author Leandro Barreto 2012
	 * @version 1.0
	 */
	public class Line extends Sprite {
		
		private var baseQuad:Quad;
		private var _thickness:Number = 1;
		private var _color:uint = 0x000000;

		public function Line()
		{
			baseQuad = new Quad(1, _thickness, _color);
			addChild(baseQuad);
		}
 
		public function lineTo(toX:int, toY:int):void
		{
			baseQuad.width = Math.round(Math.sqrt((toX*toX)+(toY*toY)));
			baseQuad.rotation = Math.atan2(toY, toX);
		}
 
		public function set thickness(t:Number):void
		{
			var currentRotation:Number = baseQuad.rotation;
			baseQuad.rotation = 0;
			baseQuad.height = _thickness = t;
			baseQuad.rotation = currentRotation;
		}
 
		public function get thickness():Number
		{
			return _thickness;
		}
 
		public function set color(c:uint):void
		{
			baseQuad.color = _color = c;
		}
 
		public function get color():uint
		{
			return _color;
		}
	}
}
