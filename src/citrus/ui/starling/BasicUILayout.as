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
		protected var _margin:Number = 0;
		protected var _elements:Vector.<BasicUIElement>;
		
		public function BasicUILayout(parentContainer:DisplayObjectContainer,rect:Rectangle) 
		{
			super();
			parentContainer.addChild(this);
			_rect = rect;
			_elements = new Vector.<BasicUIElement>();
		}
		
		public function addElement(content:DisplayObject,position:String):BasicUIElement
		{
			var element:BasicUIElement = new BasicUIElement(this, content);
			addChild(element);
			element.x = element.y = 0;
			element.position = position;
			_elements.push(element);
			return element;
		}
		
		public function removeElement(element:BasicUIElement):BasicUIElement
		{
			var index:int = _elements.indexOf(element);
			if (index > -1)
			{
				removeChild(_elements[index], true);
				_elements.splice(index, 1);
			}
			return element;
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
		
		public function getElementByContent(content:DisplayObject):BasicUIElement
		{
			var element:BasicUIElement;
			for each (element in _elements)
				if (element.content == content)
					return element;
			return null;
		}
		
		public function getElementsByPosition(position:String):Vector.<BasicUIElement>
		{
			var elements:Vector.<BasicUIElement> = new Vector.<BasicUIElement>();
			
			var element:BasicUIElement;
			for each (element in _elements)
				if (element.position == position)
					elements.push(element);
			return elements;
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
			_rect.setTo(value.x + _margin,value.y + _margin, value.width - 2*_margin, value.height - 2*_margin);
			refreshPositions();
		}
		
		public function get rect():Rectangle
		{
			return _rect;
		}
		
		public function set margin(val:Number):void
		{
			_margin = val;
			rect = _rect;
		}
		
		public function get margin():Number
		{
			return _margin;
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