package citrus.objects {

	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Mat22;
	import Box2D.Common.Math.b2Transform;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import citrus.core.CitrusEngine;
	import citrus.physics.box2d.Box2D;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.view.ISpriteView;

	
	/**
	 * You should extend this class to take advantage of Box2D. This class provides template methods for defining
	 * and creating Box2D bodies, fixtures, shapes, and joints. If you are not familiar with Box2D, you should first
	 * learn about it via the <a href="http://www.box2d.org/manual.html">Box2D Manual</a>.
	 */	
	public class Box2DPhysicsObject extends APhysicsObject implements ISpriteView, IBox2DPhysicsObject
	{
		protected var _box2D:Box2D;
		protected var _bodyDef:b2BodyDef;
		protected var _body:b2Body;
		protected var _shape:b2Shape;
		protected var _fixtureDef:b2FixtureDef;
		protected var _fixture:b2Fixture;
		
		protected var _width:Number = 1;
		protected var _height:Number = 1;
		
		protected var _beginContactCallEnabled:Boolean = false;
		protected var _endContactCallEnabled:Boolean = false;
		protected var _preContactCallEnabled:Boolean = false;
		protected var _postContactCallEnabled:Boolean = false;
		
		/**
		 * Used to define vertices' x and y points.
		 */
		public var points:Array;
		protected var _vertices:Array;
		
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
		 * All your init physics code must be added in this method, no physics code into the constructor. It's automatically called when the object is added to the state.
		 * <p>You'll notice that the Box2DPhysicsObject's initialize method calls a bunch of functions that start with "define" and "create".
		 * This is how the Box2D objects are created. You should override these methods in your own Box2DPhysicsObject implementation
		 * if you need additional Box2D functionality. Please see provided examples of classes that have overridden
		 * the Box2DPhysicsObject.</p>
		 */
		override public function addPhysics():void {
			
			if (!_box2D)
				throw new Error("Cannot create a Box2DPhysicsObject when a Box2D object has not been added to the state.");
			
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
			_box2D.world.DestroyBody(_body);
			_body.SetUserData(null);
			_shape = null;
			_bodyDef = null;
			_fixtureDef = null;
			_fixture = null;
			_box2D = null;
			super.destroy();
		}
		
		/**
		 * This method will often need to be overridden to provide additional definition to the Box2D body object. 
		 */		
		protected function defineBody():void
		{
			_bodyDef = new b2BodyDef();
			_bodyDef.type = b2Body.b2_dynamicBody;
			_bodyDef.position = new b2Vec2(_x, _y);
			_bodyDef.angle = _rotation;
		}
		
		/**
		 * This method will often need to be overridden to customize the Box2D body object. 
		 */	
		protected function createBody():void
		{
			_body = _box2D.world.CreateBody(_bodyDef);
			_body.SetUserData(this);
		}
		
		/**
		 * This method will often need to be overridden to customize the Box2D shape object.
		 * The PhysicsObject creates a rectangle by default if the radius it not defined, but you can replace this method's
		 * definition and instead create a custom shape, such as a line or circle.
		 */	
		protected function createShape():void
		{
			if (_radius != 0) {
				_shape = new b2CircleShape();
				b2CircleShape(_shape).SetRadius(_radius);
			} else {
				_shape = new b2PolygonShape();
				b2PolygonShape(_shape).SetAsBox(_width / 2, _height / 2);
			}
		}
		
		/**
		 * This method will often need to be overridden to provide additional definition to the Box2D fixture object. 
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
			
			// Used by the Tiled Map Editor software, if we defined a polygon/polyline
			if (points && points.length > 1) {
				
				_createVerticesFromPoint();
				
				var polygonShape:b2PolygonShape;
				var verticesLength:uint = _vertices.length;
				for (var i:uint = 0; i < verticesLength; ++i) {
					polygonShape = new b2PolygonShape();
					polygonShape.SetAsArray(_vertices[i]);
					_fixtureDef.shape = polygonShape;
	
					_body.CreateFixture(_fixtureDef);
				}
			}
		}
		
		/**
		 * This method will often need to be overridden to customize the Box2D fixture object. 
		 */	
		protected function createFixture():void
		{
			_fixture = _body.CreateFixture(_fixtureDef);
		}
		
		/**
		 * This method will often need to be overridden to provide additional definition to the Box2D joint object.
		 * A joint is not automatically created, because joints require two bodies. Therefore, if you need to create a joint,
		 * you will also need to create additional bodies, fixtures and shapes, and then also instantiate a new b2JointDef
		 * and b2Joint object.
		 */	
		protected function defineJoint():void
		{
			
		}
		
		/**
		 * This method will often need to be overridden to customize the Box2D joint object. 
		 * A joint is not automatically created, because joints require two bodies. Therefore, if you need to create a joint,
		 * you will also need to create additional bodies, fixtures and shapes, and then also instantiate a new b2JointDef
		 * and b2Joint object.
		 */		
		protected function createJoint():void
		{

		}
		
		/**
		 * Override this method to handle the begin contact collision.
		 */
		public function handleBeginContact(contact:b2Contact):void {
			
		}
		
		/**
		 * Override this method to handle the end contact collision.
		 */
		public function handleEndContact(contact:b2Contact):void {
			
		}
		
		/**
		 * Override this method if you want to perform some actions before the collision (deactivate).
		 */
		public function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void {
			
		}
		
		/**
		 * Override this method if you want to perform some actions after the collision.
		 */
		public function handlePostSolve(contact:b2Contact, impulse:b2ContactImpulse):void {
			
		}
		
		protected function _createVerticesFromPoint():void {
			
			_vertices = [];
			var vertices:Array = [];

			var len:uint = points.length;
			for (var i:uint = 0; i < len; ++i) {
				vertices.push(new b2Vec2(points[i].x / _box2D.scale, points[i].y / _box2D.scale));
			}
			_vertices.push(vertices);
			vertices = [];
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
				var pos:b2Vec2 = _body.GetPosition();
				pos.x = _x;
				_body.SetTransform(new b2Transform(pos, b2Mat22.FromAngle(_body.GetAngle())));
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
				var pos:b2Vec2 = _body.GetPosition();
				pos.y = _y;
				_body.SetTransform(new b2Transform(pos, b2Mat22.FromAngle(_body.GetAngle())));
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
			{
				var tr:b2Transform = _body.GetTransform();
				tr.R = b2Mat22.FromAngle(_rotation);
				_body.SetTransform(tr);
			}
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
			
			if (_initialized && !hideParamWarnings)
				trace("Warning: You cannot set " + this + " width after it has been created. Please set it in the constructor.");
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
			
			if (_initialized && !hideParamWarnings)
				trace("Warning: You cannot set " + this + " height after it has been created. Please set it in the constructor.");
		}
		
		/**
		 * No depth in a 2D Physics world.
		 */
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
		 * The object has a radius or a width and height. It can't have both.
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
		 * A direct reference to the Box2D body associated with this object.
		 */
		public function get body():b2Body {
			return _body;
		}
		
		override public function getBody():*
		{
			return _body;
		}
		
		public function get velocity():Array {
			return [_body.GetLinearVelocity().x, _body.GetLinearVelocity().y, 0];
		}
		
		public function set velocity(value:Array):void {
			_body.SetLinearVelocity(new b2Vec2(value[0], value[1]));
		}
		
		/**
		 * This flag determines if the <code>handleBeginContact</code> method is called or not. Default is false, it saves some performances.
		 */
		public function get beginContactCallEnabled():Boolean {
			return _beginContactCallEnabled;
		}
		
		/**
		 * Enable or disable the <code>handleBeginContact</code> method to be called. It doesn't change physics behavior.
		 */
		public function set beginContactCallEnabled(beginContactCallEnabled:Boolean):void {
			_beginContactCallEnabled = beginContactCallEnabled;
		}
		
		/**
		 * This flag determines if the <code>handleEndContact</code> method is called or not. Default is false, it saves some performances.
		 */
		public function get endContactCallEnabled():Boolean {
			return _endContactCallEnabled;
		}
		
		/**
		 * Enable or disable the <code>handleEndContact</code> method to be called. It doesn't change physics behavior.
		 */
		public function set endContactCallEnabled(value:Boolean):void {
			_endContactCallEnabled = value;
		}
		
		/**
		 * This flag determines if the <code>handlePreSolve</code> method is called or not. Default is false, it saves some performances.
		 */
		public function get preContactCallEnabled():Boolean {
			return _preContactCallEnabled;
		}
		
		/**
		 * Enable or disable the <code>handlePreSolve</code> method to be called. It doesn't change physics behavior.
		 */
		public function set preContactCallEnabled(value:Boolean):void {
			_preContactCallEnabled = value;
		}
		
		/**
		 * This flag determines if the <code>handlePostSolve</code> method is called or not. Default is false, it saves some performances.
		 */
		public function get postContactCallEnabled():Boolean {
			return _postContactCallEnabled;
		}
		
		/**
		 * Enable or disable the <code>handlePostSolve</code> method to be called. It doesn't change physics behavior.
		 */
		public function set postContactCallEnabled(value:Boolean):void {
			_postContactCallEnabled = value;
		}
		
	}
}