package citrus.ui.starling 
{
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	
	
	/**
	 * A very basic 9 grid layout manager. 
	 */
	public class BasicUILayout extends DisplayObjectContainer
	{
		protected var _rect:Rectangle;
		protected var _elements:Vector.<BasicUIElement>;
		
		public function BasicUILayout(parentContainer:DisplayObjectContainer,rect:Rectangle) 
		{
			super();
			parentContainer.addChild(this);
			_rect = rect;
			_elements = new Vector.<BasicUIElement>();
		}
		
		public function addElement(content:DisplayObject,position:String):void
		{
			var element:BasicUIElement = new BasicUIElement(this, content);
			addChild(element);
			element.x = element.y = 0;
			element.position = position;
			_elements.push(element);
		}
		
		public function removeElementByContent(content:DisplayObject):DisplayObject
		{
			var i:String;
			var element:BasicUIElement;
			for (i in _elements)
			{
				element = _elements[i];
				if (element.content == content)
				{
					_elements.splice(int(i), 1);
					removeChild(element,true);
					break;
				}
			}
			return content;
		}
		
		public function removeElementsByPosition(position:String):void
		{
			var i:String;
			var element:BasicUIElement;
			for (i in _elements)
			{
				element = _elements[i];
				if (element.position == position)
				{
					_elements.splice(int(i), 1);
					removeChild(element,true);
				}
			}
		}
		
		public function refreshPositions():void
		{
			var element:BasicUIElement;
			for each(element in _elements)
			{
				element.x = element.y = 0;
				element.resetPosition();
			}
		}
		
		public function set rect(value:Rectangle):void
		{
			_rect = value;
			refreshPositions();
		}
		
		public function get rect():Rectangle
		{
			return _rect;
		}
		
		override public function dispose():void
		{
			_elements.length = 0;
			removeEventListeners();
			removeChildren(0,-1,true);
			super.dispose();
		}
		
		public static const TOP_LEFT:String = "TOP_LEFT";
		public static const TOP_CENTER:String = "TOP_CENTER";
		public static const TOP_RIGHT:String = "TOP_RIGHT";
		public static const MIDDLE_LEFT:String = "MIDDLE_LEFT";
		public static const MIDDLE_CENTER:String = "MIDDLE_CENTER";
		public static const MIDDLE_RIGHT:String = "MIDDLE_RIGHT";
		public static const BOTTOM_LEFT:String = "BOTTOM_LEFT";
		public static const BOTTOM_CENTER:String = "BOTTOM_CENTER";
		public static const BOTTOM_RIGHT:String = "BOTTOM_RIGHT";
		
	}

}