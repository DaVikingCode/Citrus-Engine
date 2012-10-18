package com.citrusengine.objects {

	import Box2DAS.Collision.Shapes.b2CircleShape;
	import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Collision.Shapes.b2Shape;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2BodyDef;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2FixtureDef;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.physics.PhysicsCollisionCategories;
	import com.citrusengine.view.ISpriteView;

	import flash.display.MovieClip;
	
	/**
	 * You should extend this class to take advantage of Box2D. This class provides template methods for defining
	 * and creating Box2D bodies, fixtures, shapes, and joints. If you are not familiar with Box2D, you should first
	 * learn about it via the <a href="http://www.box2d.org/manual.html">Box2D Manual</a>.
	 */	
	public class Box2DPhysicsObject extends APhysicsObject implements ISpriteView
	{
		protected var _box2D:Box2D;
		protected var _bodyDef:b2BodyDef;
		protected var _shape:b2Shape;
		protected var _fixtureDef:b2FixtureDef;
		protected var _fixture:b2Fixture;
		
		protected var _width:Number = 1;
		protected var _height:Number = 1;
		protected var _view:* = MovieClip;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, view:*):Box2DPhysicsObject
		{
			if (!view)
				view = MovieClip;
			return new Box2DPhysicsObject(name, { x: x, y: y, width: width, height: height, view: view } );
		}
		
		/**
		 * Creates an instance of a Box2DPhysicsObject. Natively, this object does not default to any graphical representation,
		 * so you will need to set the "view" property in the params parameter.
		 */		
		public function Box2DPhysicsObject(name:String, params:Object=null)
		{			
			_ce = CitrusEngine.getInstance();
			_box2D = _ce.state.getFirstObjectByType(Box2D) as Box2D;
			
			super(name, params);
		}
		
		/**
		 * All your init physics code must be added in this method, no physics code into the constructor.
		 * <p>You'll notice that the Box2DPhysicsObject's initialize method calls a bunch of functions that start with "define" and "create".
		 * This is how the Box2D objects are created. You should override these methods in your own Box2DPhysicsObject implementation
		 * if you need additional Box2D functionality. Please see provided examples of classes that have overridden
		 * the Box2DPhysicsObject.</p>
		 */
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize(poolObjectParams);
			
			if (!_box2D)
			{
				throw new Error("Cannot create a Box2DPhysicsObject when a Box2D object has not been added to the state.");
				return;
			}
			
			//Override these to customize your Box2D initialization. Things must be done in this order.
			defineBody();
			createBody();
			createShape();
			defineFixture();
			createFixture();
			defineJoint();
			createJoint();
		}
		
		override public function destroy():void
		{
			_body.destroy();
			_fixtureDef.destroy();
			_shape.destroy();
			_bodyDef.destroy();
			
			super.destroy();
		}
		
		/**
		 * You should override this method to extend the functionality of your physics object. This is where you will 
		 * want to do any velocity/force logic. 
		 */		
		override public function update(timeDelta:Number):void
		{
		}
		
		public function get x():Number
		{
			if (_body)
				return _body.GetPosition().x * _box2D.scale;
			else
				return _x * _box2D.scale;
		}
		
		public function set x(value:Number):void
		{
			_x = value / _box2D.scale;
			
			if (_body)
			{
				var pos:V2 = _body.GetPosition();
				pos.x = _x;
				_body.SetTransform(pos, _body.GetAngle());
			}
		}
			
		public function get y():Number
		{
			if (_body)
				return _body.GetPosition().y * _box2D.scale;
			else
				return _y * _box2D.scale;
		}
		
		public function set y(value:Number):void
		{
			_y = value / _box2D.scale;
			
			if (_body)
			{
				var pos:V2 = _body.GetPosition();
				pos.y = _y;
				_body.SetTransform(pos, _body.GetAngle());
			}
		}
		
		public function get z():Number {
			return 0;
		}
		
		public function get rotation():Number
		{
			if (_body)
				return _body.GetAngle() * 180 / Math.PI;
			else
				return _rotation * 180 / Math.PI;
		}
		
		public function set rotation(value:Number):void
		{
			_rotation = value * Math.PI / 180;
			
			if (_body)
				_body.SetTransform(_body.GetPosition(), _rotation); 
		}
		
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
		 * This can only be set in the constructor parameters. 
		 */		
		public function get width():Number
		{
			return _width * _box2D.scale;
		}
		
		public function set width(value:Number):void
		{
			_width = value / _box2D.scale;
			
			if (_initialized)
			{
				trace("Warning: You cannot set " + this + " width after it has been created. Please set it in the constructor.");
			}
		}
		
		/**
		 * This can only be set in the constructor parameters. 
		 */	
		public function get height():Number
		{
			return _height * _box2D.scale;
		}
		
		public function set height(value:Number):void
		{
			_height = value / _box2D.scale;
			
			if (_initialized)
			{
				trace("Warning: You cannot set " + this + " height after it has been created. Please set it in the constructor.");
			}
		}
		
		public function get depth():Number {
			return 0;
		}
		
		/**
		 * This can only be set in the constructor parameters. 
		 */	
		public function get radius():Number
		{
			return _radius * _box2D.scale;
		}
		
		/**
		 * The object has a radius or a width & height. It can't have both.
		 */
		[Inspectable(defaultValue="0")]
		public function set radius(value:Number):void
		{
			_radius = value / _box2D.scale;
			
			if (_initialized)
			{
				trace("Warning: You cannot set " + this + " radius after it has been created. Please set it in the constructor.");
			}
		}
		
		/**
		 * A direction reference to the Box2D body associated with this object.
		 */
		override public function get body():*
		{
			return _body;
		}
		
		/**
		 * This method will often need to be overriden to provide additional definition to the Box2D body object. 
		 */		
		protected function defineBody():void
		{
			_bodyDef = new b2BodyDef();
			_bodyDef.type = b2Body.b2_dynamicBody;
			_bodyDef.position.v2 = new V2(_x, _y);
			_bodyDef.angle = _rotation;
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D body object. 
		 */	
		protected function createBody():void
		{
			_body = _box2D.world.CreateBody(_bodyDef);
			_body.SetUserData(this);
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D shape object.
		 * The PhysicsObject creates a rectangle by default if the radius it not defined, but you can replace this method's
		 * definition and instead create a custom shape, such as a line or circle.
		 */	
		protected function createShape():void
		{
			if (_radius != 0) {
				_shape = new b2CircleShape();
				b2CircleShape(_shape).m_radius = _radius;
			} else {
				_shape = new b2PolygonShape();
				b2PolygonShape(_shape).SetAsBox(_width / 2, _height / 2);
			}
		}
		
		/**
		 * This method will often need to be overriden to provide additional definition to the Box2D fixture object. 
		 */	
		protected function defineFixture():void
		{
			_fixtureDef = new b2FixtureDef();
			_fixtureDef.shape = _shape;
			_fixtureDef.density = 1;
			_fixtureDef.friction = 0.6;
			_fixtureDef.restitution = 0.3;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("Level");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAll();
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D fixture object. 
		 */	
		protected function createFixture():void
		{
			_fixture = _body.CreateFixture(_fixtureDef);
		}
		
		/**
		 * This method will often need to be overriden to provide additional definition to the Box2D joint object.
		 * A joint is not automatically created, because joints require two bodies. Therefore, if you need to create a joint,
		 * you will also need to create additional bodies, fixtures and shapes, and then also instantiate a new b2JointDef
		 * and b2Joint object.
		 */	
		protected function defineJoint():void
		{
			
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D joint object. 
		 * A joint is not automatically created, because joints require two bodies. Therefore, if you need to create a joint,
		 * you will also need to create additional bodies, fixtures and shapes, and then also instantiate a new b2JointDef
		 * and b2Joint object.
		 */		
		protected function createJoint():void
		{

		}

	}
}