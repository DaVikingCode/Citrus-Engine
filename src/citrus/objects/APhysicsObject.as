package citrus.objects {

	import citrus.core.CitrusObject;

	import flash.display.MovieClip;

	/**
	 * An abstract template used by every physics object.
	 */
	public class APhysicsObject extends CitrusObject {
		
		protected var _view:* = MovieClip;
		protected var _inverted:Boolean = false;
		protected var _parallax:Number = 1;
		protected var _animation:String = "";
		protected var _visible:Boolean = true;
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _z:Number = 0;
		protected var _rotation:Number = 0;
		protected var _radius:Number = 0;

		private var _group:uint = 0;
		private var _offsetX:Number = 0;
		private var _offsetY:Number = 0;
		private var _registration:String = "center";

		public function APhysicsObject(name:String, params:Object = null) {
			super(name, params);
		}
		
		/**
		 * This function will add the physics stuff to the object. It's automatically called when the object is added to the state.
		 */
		public function addPhysics():void {
		}
		
		/**
		 * You should override this method to extend the functionality of your physics object. This is where you will 
		 * want to do any velocity/force logic. 
		 */		
		override public function update(timeDelta:Number):void
		{
		}
		
		/**
		 * Destroy your physics objects!
		 */
		override public function destroy():void {
			super.destroy();
		}
		
		/**
		 * Used for abstraction on body. There is also a getter on the body defined by each engine to keep body's type.
		 */
		public function getBody():* {
			return null;
		}
		
		/**
		 * The view can be a class, a string to a file, or a display object. It must be supported by the view you target.
		 */
		public function get view():*
		{
			return _view;
		}
		
		[Inspectable(defaultValue="",format="File",type="String")]
		public function set view(value:*):void
		{
			_view = value;
		}
		
		/**
		 * Used to invert the view on the y-axis, number of animations friendly!
		 */
		public function get inverted():Boolean {
			return _inverted;
		}
		
		/**
		 * Animations management works the same way than label whether it uses MovieClip, SpriteSheet or whatever.
		 */
		public function get animation():String {
			return _animation;
		}
		
		/**
		 * You can easily change if an object is visible or not. It hasn't any impact on physics computation.
		 */
		public function get visible():Boolean {
			return _visible;
		}

		public function set visible(value:Boolean):void {
			_visible = value;
		}
		
		/**
		 * You can set up a parallax, no impact on physics.
		 */
		public function get parallax():Number {
			return _parallax;
		}

		[Inspectable(defaultValue="1")]
		public function set parallax(value:Number):void {
			_parallax = value;
		}
		
		/**
		 * The group is similar to a z-index sorting. Default is 0, 1 is over.
		 */
		public function get group():uint {
			return _group;
		}
		
		[Inspectable(defaultValue="0")]
		public function set group(value:uint):void {
			_group = value;
		}
		
		/**
		 * offsetX allows to move graphics on x axis compared to their initial point.
		 */
		public function get offsetX():Number {
			return _offsetX;
		}

		[Inspectable(defaultValue="0")]
		public function set offsetX(value:Number):void {
			_offsetX = value;
		}
		
		/**
		 * offsetY allows to move graphics on y axis compared to their initial point.
		 */
		public function get offsetY():Number {
			return _offsetY;
		}

		[Inspectable(defaultValue="0")]
		public function set offsetY(value:Number):void {
			_offsetY = value;
		}
		
		/**
		 * Flash registration point is topLeft, whereas physics engine use mostly center.
		 * You can change the registration point thanks to this property.
		 */
		public function get registration():String {
			return _registration;
		}

		[Inspectable(defaultValue="center",enumeration="center,topLeft")]
		public function set registration(value:String):void {
			_registration = value;
		}
	}
}
