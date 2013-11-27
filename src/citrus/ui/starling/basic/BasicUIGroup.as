package citrus.ui.starling.basic
{
	import starling.display.Sprite;
	import citrus.ui.starling.basic.BasicUIElement;

	import starling.display.DisplayObject;

	/**
	 * @author Michelangelo Capraro (m&#64;mcapraro.com)
	 */
	public class BasicUIGroup extends BasicUIElement
	{
		public static const HORIZONTAL:String = "HORIZONTAL";
		public static const VERTICAL:String = "VERTICAL";

		protected var _padding:Number = 10;
		protected var _elements:Array;
		private var _orientation:String;

		public function BasicUIGroup(orientation:String = HORIZONTAL, position:String = null)
		{
			super(new Sprite(), position);
			
			_elements = new Array();
			_orientation = orientation;
		}
		
		public function add(content:*):BasicUIElement
		{
			var element:BasicUIElement;
			
			if (content is BasicUIElement) {
				element = content; 
				
			} else if (content is DisplayObject) {
				element = new BasicUIElement(content, position);
			} else {
				throw new ArgumentError(String(this) + " add() content is not valid.");
			}
			
			if (_elements.length > 0) {
				var lastElement:DisplayObject = _elements[_elements.length - 1] as DisplayObject;
				if (_orientation == HORIZONTAL) {
					element.x = lastElement.x + lastElement.width + _padding;
				
				} else if (_orientation == VERTICAL) {
					element.y = lastElement.y + lastElement.height + _padding;					
				}
			}
			
			_elements.push(element);
			(_content as Sprite).addChild(element);
			return element;
			
		}
		
		
		override public function destroy():void
		{
			_elements.length = 0;
			super.destroy();
		}

		public function get padding():Number
		{
			return _padding;
		}

		public function set padding(padding:Number):void
		{
			_padding = padding;
		}
	}
}
