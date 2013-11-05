package citrus.ui.starling.basic 
{
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	/**
	 * wraps a display object.
	 */
	public class BasicUIElement extends DisplayObjectContainer
	{
		internal var parentLayout:BasicUILayout;
		protected var _content:DisplayObject;
		protected var _position:String;
		protected var _rect:Rectangle = new Rectangle();
		protected var _margin:Number = 0;
		
		protected var _contentScale:Number = BasicUI.defaultContentScale;
		
		public function BasicUIElement(content:DisplayObject,position:String = null) 
		{
			_content = content;
			_position = position;
			
			addChild(_content);
			resetContentPosition();
		}
		
		internal function resetContentPosition():void
		{
			_content.scaleX = _content.scaleY = _contentScale;
			_content.pivotX = _content.pivotY = 0;
			_content.x = _margin;
			_content.y = _margin;
			_rect.setTo(0, 0, _content.width + 2 * _margin, _content.height + 2 * _margin);
		}
		
		override public function alignPivot(hAlign:String = "center", vAlign:String = "center"):void
		{
			switch(hAlign)
			{
				case HAlign.LEFT:
					pivotX = 0;
					break;
				case HAlign.CENTER:
					pivotX = rect.width * .5;
					break;
				case HAlign.RIGHT:
					pivotX = rect.width;
					break;
			}
			
			switch(vAlign)
			{
				case VAlign.TOP:
					pivotY = 0;
					break;
				case VAlign.CENTER:
					pivotY = rect.height * .5;
					break;
				case VAlign.BOTTOM:
					pivotY = rect.height;
					break;
			}
		}
		
		override public function get x():Number
		{
			return _rect.x;
		}
		
		override public function get y():Number
		{
			return _rect.y;
		}
		
		override public function get width():Number
		{
			return _rect.width;
		}
		
		override public function get height():Number
		{
			return _rect.height;
		}
		
		public function get rect():Rectangle
		{
			return _rect.clone();
		}
		
		public function get position():String
		{
			return _position;
		}
		
		public function set position(value:String):void
		{
			_position = value;
			if (parentLayout)
				parentLayout.refreshElement(this);
		}
		
		public function get contentScale():Number
		{
			return _contentScale;
		}
		
		public function set contentScale(value:Number):void
		{
			if (value == _contentScale)
				return;
			if (value < 0)
			value = 0.1;
			
			_contentScale = value;
			resetContentPosition();
		}
		
		public function destroy():void
		{
			parentLayout = null;
			_rect = null;
			if (_content)
			{
				removeChild(_content, true);
				_content = null;
			}
		}
		
	}

}