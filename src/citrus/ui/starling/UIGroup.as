package citrus.ui.starling
{
	import starling.display.Sprite;
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	import org.osflash.signals.Signal;
	import citrus.ui.starling.UIElement;

	import starling.display.DisplayObject;

	/**
	 * @author Michelangelo Capraro (m&#64;mcapraro.com)
	 */
	public class UIGroup extends UIElement
	{

		public static const HORIZONTAL:String = "HORIZONTAL";
		public static const VERTICAL:String = "VERTICAL";

		protected var _padding:Number = 10;
		protected var _elements:Array;
		private var _orientation:String;
		private var _hAlign:String;
		private var _vAlign:String;
		private var _width:Number;
		private var _height:Number;
		
		public function UIGroup(orientation:String = HORIZONTAL, items:Array = null)
		{			
			super(new Sprite(), position);
			
			_elements = new Array();
			_orientation = orientation;
			_width = _height = 0;
			
			_hAlign = HAlign.LEFT;
			_vAlign = VAlign.TOP;
			
			if (items != null) {
				for (var i:int = 0; i < items.length; i++) {
					add(items[i]);
				}
			}
			
			onRefresh = new Signal(UIGroup);
			
			resetContentPosition();
		}
		
		public function add(content:*):UIElement
		{
			var element:UIElement;
			if (content is UIElement) {
				element = content;
			} else if (content is DisplayObject) {
				element = new UIElement(content);
			} else { 
				throw new ArgumentError(String(this) + " add() content is not valid.");
			}
			
			Sprite(_content).addChild(element.content);		
			_elements.push(element);
			refresh();
			return element;
		}
		
		public function remove(element:UIElement):UIElement
		{
			var elms:Array = _elements.splice(_elements.indexOf(element), 1);
			(_content as Sprite).removeChild(UIElement(elms[0]).content, true);
			refresh();
			return elms[0];
		}
		
		
		override internal function resetContentPosition():void
		{
			_content.pivotX = _content.pivotY = 0;
			positionElements();
			super.resetContentPosition();
		}

		private function positionElements():void
		{
			if (_elements == null) return;
			if (_elements.length > 0) {
				var offsetX:Number = 0;
				var offsetY:Number = 0;
				
				var element:UIElement;
				
				for (var i:int = 0; i < _elements.length; i++) {
					
					element = _elements[i];
					element.content.x = offsetX;
					element.content.y = offsetY;
					
					if (_orientation == HORIZONTAL) {
						offsetX = offsetX + element.content.width + _padding;
					
					} else if (_orientation == VERTICAL) {
						offsetY = offsetY + element.content.height + _padding;
					}
				}
				
			}
		}
		
		override public function destroy():void
		{
			Sprite(_content).removeChildren(0, -1, true);
			_content = null;
			_elements.length = 0;
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
