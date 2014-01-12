package citrus.ui.starling
{
	import org.osflash.signals.Signal;
	import starling.display.DisplayObject;
	import flash.geom.Rectangle;
	/**
	 * @author Michelangelo Capraro (m&#64;mcapraro.com)
	 */
	public class UIElement
	{
		protected var _content:DisplayObject;
		protected var _position:String;
		protected var _rect:Rectangle = new Rectangle();
		protected var _margin:Number = 0;
		
		protected var _contentScale:Number = UI.defaultContentScale;
		
		public var onRefresh:Signal;

		public function UIElement(content:DisplayObject, position:String = null) 
		{
			_content = content;
			_position = position;
			
			onRefresh = new Signal(UIElement);

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
		
		public function get position():String
		{
			return _position;
		}
		
		public function set position(value:String):void
		{
			_position = value;
			refresh();
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
			refresh();
		}

		protected function refresh():void
		{
			onRefresh.dispatch(this);
		}
				
		public function destroy():void
		{
			_rect = null;
			if (_content)
			{
				_content = null;
			}
		}

		
		public function get x():Number 
		{
			return _content.x;
		}
		
		public function set x(newX:Number):void 
		{
			_content.x = newX;
		}

		public function get y():Number 
		{
			return _content.y;
		}
		
		public function set y(newY:Number):void 
		{
			_content.y = newY;
		}

		public function alignPivot(hAlign:String, vAlign:String):void
		{
			_content.alignPivot(hAlign, vAlign);
		}

		public function get content():DisplayObject
		{
			return _content;
		}

		public function set content(content:DisplayObject):void
		{
			_content = content;
		}
		

	}
}
