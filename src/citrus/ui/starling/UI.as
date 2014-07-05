package citrus.ui.starling
{
	import starling.events.Event;
	import starling.display.DisplayObject;
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	import starling.display.Sprite;
	import flash.geom.Rectangle;
	import starling.display.DisplayObjectContainer;
	/**
	 * @author Michelangelo Capraro (m&#64;mcapraro.com)
	 */
	public class UI
	{
		public static const TOP_LEFT:String = "TOP_LEFT";
		public static const TOP_CENTER:String = "TOP_CENTER";
		public static const TOP_RIGHT:String = "TOP_RIGHT";
		public static const MIDDLE_LEFT:String = "MIDDLE_LEFT";
		public static const MIDDLE_CENTER:String = "MIDDLE_CENTER";
		public static const MIDDLE_RIGHT:String = "MIDDLE_RIGHT";
		public static const BOTTOM_LEFT:String = "BOTTOM_LEFT";
		public static const BOTTOM_CENTER:String = "BOTTOM_CENTER";
		public static const BOTTOM_RIGHT:String = "BOTTOM_RIGHT";

		public static var defaultContentScale:Number = 1;
		
		
		internal var container:DisplayObjectContainer;
		
		private var _padding:Number = 0;

		private var _parentContainer:DisplayObjectContainer;
		private var _uiBounds:Rectangle;
		private var _elements:Vector.<UIElement>;
		private var _needsRefresh:Vector.<UIElement>;
		private var listeningToEnterFrame:Boolean;
		
		public function UI(parentContainer:DisplayObjectContainer, bounds:Rectangle) 
		{
			container = new Sprite();
			
			_parentContainer = parentContainer;
			_uiBounds = new Rectangle(0,0,0,0);
			_elements = new Vector.<UIElement>();
			parentContainer.addChild(container);
			_needsRefresh = new Vector.<UIElement>();
			
			setFrame(bounds);
		}

		public function add(content:*, position:String):UIElement
		{				
			var element:UIElement;
			if (content is UIElement) {
				element = content;
			} else if (content is DisplayObject) {
				element = new UIElement(content, position);
			} else { 
				throw new ArgumentError(String(this) + " add() content is not valid.");
			}
			
			_elements.push(element);
			element.position = position;
			element.onRefresh.add(onRefresh);
			
			container.addChild(element.content);
			refreshElement(element);
			return element;
		}


		private function onRefresh(element:UIElement):void
		{
			trace("UI: onRefresh called [" + element + "]");
			refresh(element);
		}
				
		/**
		 * only run when items need refreshing
		 */
		private function onEnterFrame(event:Event):void
		{
			doRefresh();
			_parentContainer.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			listeningToEnterFrame = false;
		}
		
		/**
		 * this refreshes the collection of elements. this only happens on a frame update
		 */
		public function refresh(element:UIElement = null):void
		{			
			if (element) {
				refreshElement(element);
			} else {
				for each(element in _elements) {
					refreshElement(element);
				}
			}
		}

		internal function refreshElement(element:UIElement = null):void
		{
			if (_needsRefresh.indexOf(element) == -1) _needsRefresh.push(element);
			
			if (!listeningToEnterFrame) {
				_parentContainer.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				listeningToEnterFrame = true;
			}
		}
		
		private function doRefresh():void
		{
			trace("UI: doRefresh() called");
			for each(var element:UIElement in _needsRefresh) {
				
				element.resetContentPosition();
				
				switch(element.position)
				{
					case TOP_LEFT:
						element.alignPivot(HAlign.LEFT, VAlign.TOP);
						element.x = _uiBounds.left;
						element.y = _uiBounds.top;
						break;
					case TOP_CENTER:
						element.alignPivot(HAlign.CENTER, VAlign.TOP);
						element.x = _uiBounds.x + _uiBounds.width*.5;
						element.y = _uiBounds.top;
						break;
					case TOP_RIGHT:
						element.alignPivot(HAlign.RIGHT, VAlign.TOP);
						element.x = _uiBounds.right;
						element.y = _uiBounds.top;
						break;
					
					case MIDDLE_LEFT:
						element.alignPivot(HAlign.LEFT, VAlign.CENTER);
						element.x = _uiBounds.left;
						element.y = _uiBounds.y + _uiBounds.height*.5;
						break;
					case MIDDLE_CENTER:
						element.alignPivot(HAlign.CENTER, VAlign.CENTER);
						element.x = _uiBounds.x + _uiBounds.width*.5;
						element.y = _uiBounds.y + _uiBounds.height*.5;
						break;
					case MIDDLE_RIGHT:
						element.alignPivot(HAlign.RIGHT, VAlign.CENTER);
						element.x = _uiBounds.right;
						element.y = _uiBounds.y + _uiBounds.height*.5;
						break;
						
					case BOTTOM_LEFT:
						element.alignPivot(HAlign.LEFT, VAlign.BOTTOM);
						element.x = _uiBounds.left;
						element.y = _uiBounds.bottom;
						break;
					case BOTTOM_CENTER:
						element.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
						element.x = _uiBounds.x + _uiBounds.width*.5;
						element.y = _uiBounds.bottom;
						break;
					case BOTTOM_RIGHT:
						element.alignPivot(HAlign.RIGHT, VAlign.BOTTOM);
						element.x = _uiBounds.right;
						element.y = _uiBounds.bottom;
						break;
				}
			}
		}
		
		public function setFrame(newFrame:Rectangle):void
		{
			_uiBounds.setTo(newFrame.x + _padding, newFrame.y + _padding, newFrame.width - 2*_padding, newFrame.height - 2*_padding);
			refresh();
		}
		
		public function get bounds():Rectangle
		{
			return _uiBounds;
		}
		
		public function get padding():Number
		{
			return _padding;
		}
		
		public function set padding(value:Number):void
		{
			_padding = value;
			setFrame(_uiBounds);
		}
		
		public function destroy():void
		{
			var element:UIElement;
			for each(element in _elements)
			{
				container.removeChild(element.content, true);

				element.onRefresh.removeAll();
				element.destroy();
			}
			_elements.length = 0;
			container.removeFromParent();
			container = null;

		}
		
		public function get alpha():Number 
		{
			return container.alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			container.alpha = value;
		}
		


	}
}
