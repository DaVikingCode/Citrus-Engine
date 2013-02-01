package citrus.input.controllers {

	import citrus.input.InputController;

	public class AVirtualButton extends InputController
	{
		//Common graphic properties
		protected var _x:int;
		protected var _y:int;
		
		protected var _margin:int = 130;
		
		protected var _visible:Boolean = true;
		
		protected var _buttonradius:int = 50;
		
		public var buttonAction:String = "button";
		public var buttonChannel:int = -1;
		
		public function AVirtualButton(name:String, params:Object = null)
		{
			super(name, params);
			
			_x = _x ? _x : _ce.stage.stageWidth - (_margin + 3*_buttonradius) ;
			_y = _y ? _y : _ce.stage.stageHeight - 3*_buttonradius;
			
			initGraphics();
		}
		
		/**
		 * Override this for specific drawing
		 */
		protected function initGraphics():void
		{
			trace("Warning: " + this + " does not render any graphics!");
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
		}
		
		public function set buttonradius(value:int):void
		{
			if (!_initialized)
				_buttonradius = value;
			else
				trace("Warning: You cannot set " + this + " buttonradius after it has been created. Please set it in the constructor.");
		}
		
		public function set margin(value:int):void
		{
			if (!_initialized)
				_margin = value;
			else
				trace("Warning: You cannot set " + this + " margin after it has been created. Please set it in the constructor.");
		}
		
		public function get margin():int
		{
			return _margin;
		}
		
		public function set x(value:int):void
		{
			if (!_initialized)
				_x = value;
			else
				trace("Warning: you can only set " + this + " x through graphic.x after instanciation.");
		}
		
		public function set y(value:int):void
		{
			if (!_initialized)
				_y = value;
			else
				trace("Warning: you can only set " + this + " y through graphic.y after instanciation.");
		}
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function get buttonradius():int
		{
			return _buttonradius;
		}
	
	}

}