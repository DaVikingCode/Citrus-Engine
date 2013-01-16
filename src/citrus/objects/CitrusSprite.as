package citrus.objects
{
	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.math.MathVector;
	import citrus.view.ISpriteView;
	import citrus.view.SpriteDebugArt;

	import org.osflash.signals.Signal;

	import flash.utils.Dictionary;

	/**
	 * This is the primary class for creating graphical game objects.
	 * You should override this class to create a visible game object such as a Spaceship, Hero, or Backgrounds. This is the equivalent
	 * of the Flash Sprite. It has common properties that are required for properly displaying and
	 * positioning objects. You can also add your logic to this sprite.
	 * 
	 * <p>With a CitrusSprite, there is only simple collision and velocity logic. If you'd like to take advantage of Box2D or Nape physics,
	 * you should extend the APhysicsObject class instead.</p>
	 */	
	public class CitrusSprite extends CitrusObject implements ISpriteView
	{
		public var collisions:Dictionary = new Dictionary();
		
		public var onCollide:Signal = new Signal(CitrusSprite, CitrusSprite, MathVector, Number);
		public var onPersist:Signal = new Signal(CitrusSprite, CitrusSprite, MathVector);
		public var onSeparate:Signal = new Signal(CitrusSprite, CitrusSprite);
		
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _width:Number = 30;
		protected var _height:Number = 30;
		protected var _velocity:MathVector = new MathVector();
		protected var _parallax:Number = 1;
		protected var _rotation:Number = 0;
		protected var _group:uint = 0;
		protected var _visible:Boolean = true;
		protected var _view:* = SpriteDebugArt;
		protected var _inverted:Boolean = false;
		protected var _animation:String = "";
		protected var _offsetX:Number = 0;
		protected var _offsetY:Number = 0;
		protected var _registration:String = "topLeft";
			
		public function CitrusSprite(name:String, params:Object = null)
		{
			_ce = CitrusEngine.getInstance();
			
			super(name, params);
		}
		
		override public function destroy():void
		{
			onCollide.removeAll();
			onPersist.removeAll();
			onSeparate.removeAll();
			collisions = null;
			
			super.destroy();
		}
		
		/**
		 * No physics here, return <code>null</code>.
		 */ 
		public function getBody():* {
			return null;
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			_x = value;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
		}
		
		public function get z():Number {
			return 0;
		}
		
		public function get width():Number
		{
			return _width;
		}
		
		public function set width(value:Number):void
		{
			_width = value;
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function set height(value:Number):void
		{
			_height = value;
		}
		
		public function get depth():Number {
			return 0;
		}
		
		public function get velocity():Array {
			return [_velocity.x, _velocity.y, 0];
		}
		
		public function set velocity(value:Array):void {
			
			_velocity.x = value[0];
			_velocity.y = value[1];
		}
		
		public function get parallax():Number
		{
			return _parallax;
		}
		
		[Inspectable(defaultValue="1")]
		public function set parallax(value:Number):void
		{
			_parallax = value;
		}
		
		public function get rotation():Number
		{
			return _rotation;
		}
		
		public function set rotation(value:Number):void
		{
			_rotation = value;
		}
		
		/**
		 * The group is similar to a z-index sorting. Default is 0, 1 is over.
		 */
		public function get group():uint
		{
			return _group;
		}
		
		[Inspectable(defaultValue="0")]
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
		public function get inverted():Boolean
		{
			return _inverted;
		}
		
		public function set inverted(value:Boolean):void
		{
			_inverted = value;
		}
		
		public function get animation():String
		{
			return _animation;
		}
		
		public function set animation(value:String):void
		{
			_animation = value;
		}
		
		public function get offsetX():Number
		{
			return _offsetX;
		}
		
		[Inspectable(defaultValue="0")]
		public function set offsetX(value:Number):void
		{
			_offsetX = value;
		}
		
		public function get offsetY():Number
		{
			return _offsetY;
		}
		
		[Inspectable(defaultValue="0")]
		public function set offsetY(value:Number):void
		{
			_offsetY = value;
		}
		
		public function get registration():String
		{
			return _registration;
		}
		
		[Inspectable(defaultValue="topLeft",enumeration="center,topLeft")]
		public function set registration(value:String):void
		{
			_registration = value;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			x += (_velocity.x * timeDelta);
			y += (_velocity.y * timeDelta);
		}
	}
}