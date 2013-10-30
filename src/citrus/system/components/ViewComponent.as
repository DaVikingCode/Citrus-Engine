package citrus.system.components {

	import citrus.system.Component;
	import citrus.view.ICitrusArt;
	import citrus.view.ISpriteView;

	import org.osflash.signals.Signal;

	import flash.display.MovieClip;

	/**
	 * The view component, it manages everything to set the view.
	 * Extend it to handle animation.
	 */
	public class ViewComponent extends Component implements ISpriteView {
		
		public var onAnimationChange:Signal;

		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _rotation:Number = 0;
		protected var _inverted:Boolean = false;
		protected var _parallaxX:Number = 1;
		protected var _parallaxY:Number = 1;
		protected var _animation:String = "";
		protected var _visible:Boolean = true;
		protected var _touchable:Boolean = false;
		protected var _view:* = MovieClip;
		
		private var _group:uint = 0;
		private var _offsetX:Number = 0;
		private var _offsetY:Number = 0;
		private var _registration:String = "center";

		public function ViewComponent(name:String, params:Object = null) {
			super(name, params);
			
			onAnimationChange = new Signal();
		}
		
		/**
		 * called when the art is created (and loaded if loading is required)
		 * @param	citrusArt the art
		 */
		public function handleArtReady(citrusArt:ICitrusArt):void
		{
			
		}
		
		/**
		 * called when the art changes. the argument is the art with its previous content
		 * so that you can remove event listeners from it for example.
		 * @param	citrusArt the art
		 */
		public function handleArtChanged(oldArt:ICitrusArt):void
		{
			
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
		}
			
		override public function destroy():void {
			
			onAnimationChange.removeAll();
			
			super.destroy();
		}
		
		public function getBody():* {
			return null;
		}
		
		public function get x():Number {
			return _x;
		}

		public function set x(value:Number):void {
			_x = value;
		}

		public function get y():Number {
			return _y;
		}

		public function set y(value:Number):void {
			_y = value;
		}
		
		public function get z():Number {
			return 0;
		}
		
		public function get width():Number {
			return 0;
		}
		
		public function get height():Number {
			return 0;
		}
		
		public function get depth():Number {
			return 0;
		}
		
		public function get velocity():Array {
			return null;
		}

		public function get rotation():Number {
			return _rotation;
		}

		public function set rotation(value:Number):void {
			_rotation = value;
		}

		public function get parallaxX():Number {
			return _parallaxX;
		}

		public function set parallaxX(value:Number):void {
			_parallaxX = value;
		}
		
		public function get parallaxY():Number {
			return _parallaxY;
		}

		public function set parallaxY(value:Number):void {
			_parallaxY = value;
		}
		
		public function get group():uint
		{
			return _group;
		}
		
		public function set group(value:uint):void
		{
			_group = value;
		}
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
		}
		
		public function get touchable():Boolean
		{
			return _touchable;
		}
		
		public function set touchable(value:Boolean):void
		{
			_touchable = value;
		}
		
		public function get view():*
		{
			return _view;
		}
		
		public function set view(value:*):void
		{
			_view = value;
		}
		
		public function get animation():String
		{
			return _animation;
		}
		
		public function get inverted():Boolean
		{
			return _inverted;
		}
		
		public function get offsetX():Number
		{
			return _offsetX;
		}
		
		public function set offsetX(value:Number):void
		{
			_offsetX = value;
		}
		
		public function get offsetY():Number
		{
			return _offsetY;
		}
		
		public function set offsetY(value:Number):void
		{
			_offsetY = value;
		}
		
		public function get registration():String
		{
			return _registration;
		}
		
		public function set registration(value:String):void
		{
			_registration = value;
		}
	}
}
