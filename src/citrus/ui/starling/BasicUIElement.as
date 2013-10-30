package citrus.ui.starling 
{
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class BasicUIElement extends DisplayObjectContainer
	{
		protected var _parentLayout:BasicUILayout;
		protected var _content:DisplayObject;
		protected var _position:String;
		
		public function BasicUIElement(parent:BasicUILayout,content:DisplayObject) 
		{
			_parentLayout = parent;
			this.content = content;
		}
		
		public function resetPosition():void
		{
			if (_parentLayout)
			{
				var rect:Rectangle = _parentLayout.rect;
				switch(_position)
				{
					case BasicUILayout.TOP_LEFT:
						_content.alignPivot(HAlign.LEFT, VAlign.TOP);
						_content.x = rect.left;
						_content.y = rect.top;
						break;
					case BasicUILayout.TOP_CENTER:
						_content.alignPivot(HAlign.CENTER, VAlign.TOP);
						_content.x = rect.x + rect.width*.5;
						_content.y = rect.top;
						break;
					case BasicUILayout.TOP_RIGHT:
						_content.alignPivot(HAlign.RIGHT, VAlign.TOP);
						_content.x = rect.right;
						_content.y = rect.top;
						break;
					
					case BasicUILayout.MIDDLE_LEFT:
						_content.alignPivot(HAlign.LEFT, VAlign.CENTER);
						_content.x = rect.left;
						_content.y = rect.y + rect.height*.5;
						break;
					case BasicUILayout.MIDDLE_CENTER:
						_content.alignPivot(HAlign.CENTER, VAlign.CENTER);
						_content.x = rect.x + rect.width*.5;
						_content.y = rect.y + rect.height*.5;
						break;
					case BasicUILayout.MIDDLE_RIGHT:
						_content.alignPivot(HAlign.RIGHT, VAlign.CENTER);
						_content.x = rect.right;
						_content.y = rect.y + rect.height*.5;
						break;
						
					case BasicUILayout.BOTTOM_LEFT:
						_content.alignPivot(HAlign.LEFT, VAlign.BOTTOM);
						_content.x = rect.left;
						_content.y = rect.bottom;
						break;
					case BasicUILayout.BOTTOM_CENTER:
						_content.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
						_content.x = rect.x + rect.width*.5;
						_content.y = rect.bottom;
						break;
					case BasicUILayout.BOTTOM_RIGHT:
						_content.alignPivot(HAlign.RIGHT, VAlign.BOTTOM);
						_content.x = rect.right;
						_content.y = rect.bottom;
						break;
				}
			}
		}
		
		public function set position(value:String):void
		{
			_position = value;
			resetPosition();
		}
		
		public function get position():String
		{
			return _position;
		}
		
		public function set content(value:DisplayObject):void
		{
			if (_content)
				_content.dispose();
				
			_content = value;
			
			addChild(_content);
		}
		
		public function get content():DisplayObject
		{
			return _content;
		}
		
		override public function dispose():void
		{
			_parentLayout = null;
			super.dispose();
		}
		
	}

}