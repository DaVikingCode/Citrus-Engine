package citrus.ui.starling.basic 
{
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class BasicUILayout
	{
		protected var _parentLayout:BasicUILayout;
		protected var _frame:Rectangle;
		protected var _elements:Vector.<BasicUIElement>;
		
		protected var _padding:Number = 0;
		
		public function BasicUILayout(parentLayout:BasicUILayout,frame:Rectangle) 
		{
			_parentLayout = parentLayout;
			_frame = frame;
			_elements = new Vector.<BasicUIElement>();
		}
		
		public function add(content:*, position:String):BasicUIElement
		{
			var element:BasicUIElement;
			
			if (content is BasicUIElement)
			{
				element = content; 
				element.position = position;
			}
			else if(content is DisplayObject)
				element = new BasicUIElement(content, position);
			else
				throw new ArgumentError(String(this) + " add() content is not valid.");
				
			_elements.push(element);
			parentDisplay.addChild(element);
			element.parentLayout = this;
			refreshElement(element);
			return element;
		}
		
		public function refresh(element:BasicUIElement = null):void
		{
			if (element)
			{
				refreshElement(element);
			}
			else
			{
				for each(element in _elements)
					refreshElement(element);
			}
		}
		
		internal function refreshElement(element:BasicUIElement):void
		{
			element.resetContentPosition();
			var rect:Rectangle = _parentLayout.frame;
				switch(element.position)
				{
					case BasicUILayout.TOP_LEFT:
						element.alignPivot(HAlign.LEFT, VAlign.TOP);
						element.x = rect.left;
						element.y = rect.top;
						break;
					case BasicUILayout.TOP_CENTER:
						element.alignPivot(HAlign.CENTER, VAlign.TOP);
						element.x = rect.x + rect.width*.5;
						element.y = rect.top;
						break;
					case BasicUILayout.TOP_RIGHT:
						element.alignPivot(HAlign.RIGHT, VAlign.TOP);
						element.x = rect.right;
						element.y = rect.top;
						break;
					
					case BasicUILayout.MIDDLE_LEFT:
						element.alignPivot(HAlign.LEFT, VAlign.CENTER);
						element.x = rect.left;
						element.y = rect.y + rect.height*.5;
						break;
					case BasicUILayout.MIDDLE_CENTER:
						element.alignPivot(HAlign.CENTER, VAlign.CENTER);
						element.x = rect.x + rect.width*.5;
						element.y = rect.y + rect.height*.5;
						break;
					case BasicUILayout.MIDDLE_RIGHT:
						element.alignPivot(HAlign.RIGHT, VAlign.CENTER);
						element.x = rect.right;
						element.y = rect.y + rect.height*.5;
						break;
						
					case BasicUILayout.BOTTOM_LEFT:
						element.alignPivot(HAlign.LEFT, VAlign.BOTTOM);
						element.x = rect.left;
						element.y = rect.bottom;
						break;
					case BasicUILayout.BOTTOM_CENTER:
						element.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
						element.x = rect.x + rect.width*.5;
						element.y = rect.bottom;
						break;
					case BasicUILayout.BOTTOM_RIGHT:
						element.alignPivot(HAlign.RIGHT, VAlign.BOTTOM);
						element.x = rect.right;
						element.y = rect.bottom;
						break;
				}
		}
		
		public function get parentDisplay():DisplayObjectContainer
		{
			var parent:* = _parentLayout;
			while (parent)
			{
				parent = parent.parentLayout;
				if (parent["container"] is DisplayObjectContainer)
					return parent["container"];
			}
			return null;
		}
		
		public function get rootLayout():BasicUILayout
		{
			var parent:* = _parentLayout;
			while (parent)
				parent = parent.parentLayout;
			return parent;
		}
		
		public function get parentLayout():BasicUILayout
		{
			return _parentLayout;
		}
		
		public function setFrame(xa:Number = 0, ya:Number = 0, wa:Number = 0, ha:Number = 0):void
		{
			_frame.setTo(xa + _padding, ya + _padding, wa - 2*_padding, ha - 2*_padding);
			refresh();
		}
		
		public function get frame():Rectangle
		{
			return _frame;
		}
		
		public function get padding():Number
		{
			return _padding;
		}
		
		public function set padding(value:Number):void
		{
			_padding = value;
			setFrame(_frame.x, _frame.y, _frame.width, _frame.height);
		}
		
		public function destroy():void
		{
			var element:BasicUIElement;
			for each(element in _elements)
			{
				element.destroy();
				parentDisplay.removeChild(element,true);
			}
			_elements.length = 0;
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