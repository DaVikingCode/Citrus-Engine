package citrus.objects {

	import citrus.physics.nape.INapePhysicsObject;
	import citrus.physics.nape.Nape;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.view.ISpriteView;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.dynamics.InteractionFilter;
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.Vec2;
	import nape.geom.Vec2List;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.shape.ValidationResult;


	/**
	 * You should extend this class to take advantage of Nape. This class provides template methods for defining
	 * and creating Nape bodies, fixtures, shapes, and joints. If you are not familiar with Nape, you should first
	 * learn about it via the <a href="http://napephys.com/help/manual.html">Nape Manual</a>.
	 */	
	public class NapePhysicsObject extends APhysicsObject implements ISpriteView, INapePhysicsObject {
		
		public static const PHYSICS_OBJECT:CbType = new CbType();
		
		protected var _nape:Nape;
		protected var _bodyType:BodyType;
		protected var _body:Body;
		protected var _material:Material;
		protected var _shape:Shape;
		
		protected var _width:Number = 30;
		protected var _height:Number = 30;
		
		protected var _beginContactCallEnabled:Boolean = false;
		protected var _endContactCallEnabled:Boolean = false;
		
		/**
		 * Used to define vertices' x and y points.
		 */
		public var points:Array;

		/**
		 * Creates an instance of a NapePhysicsObject. Natively, this object does not default to any graphical representation,
		 * so you will need to set the "view" property in the params parameter.
		 */	
		public function NapePhysicsObject(name:String, params:Object = null) {
			
			super(name, params);
		}
			
		/**
		 * All your init physics code must be added in this method, no physics code into the constructor. It's automatically called when the object is added to the state.
		 * <p>You'll notice that the NapePhysicsObject's initialize method calls a bunch of functions that start with "define" and "create".
		 * This is how the Nape objects are created. You should override these methods in your own NapePhysicsObject implementation
		 * if you need additional Nape functionality. Please see provided examples of classes that have overridden
		 * the NapePhysicsObject.</p>
		 */	
		override public function addPhysics():void {
			
			_nape = _ce.state.getFirstObjectByType(Nape) as Nape;
			
			if (!_nape)
				throw new Error("Cannot create a NapePhysicsObject when a Nape object has not been added to the state.");
			
			//Override these to customize your Nape initialization. Things must be done in this order.
			defineBody();
			createBody();
			createMaterial();
			createShape();
			createFilter();
			createConstraint();
		}
		
		override public function destroy():void {	
			_nape.space.bodies.remove(_body);
			_body.userData.myData = null;
			_body = null;
			_material = null;
			_shape = null;
			_nape = null;
			super.destroy();
		}
		
		public function handlePreContact(callback:PreCallback):PreFlag {
			return PreFlag.ACCEPT;
		}
		
		/**
		 * Override this method to handle the begin contact collision.
		 */
		public function handleBeginContact(callback:InteractionCallback):void {
		}
		
		/**
		 * Override this method to handle the end contact collision.
		 */
		public function handleEndContact(callback:InteractionCallback):void {
		}
		
		/**
		 * This method will often need to be overridden to provide additional definition to the Nape body object. 
		 */
		protected function defineBody():void {
			
			_bodyType = BodyType.DYNAMIC;
		}
		
		/**
		 * This method will often need to be overridden to customize the Nape body object. 
		 */
		protected function createBody():void {
			
			_body = new Body(_bodyType, Vec2.weak(_x, _y));
			_body.userData.myData = this;
			
			_body.rotate(Vec2.weak(_x, _y), _rotation);
		}
		
		/**
		 * This method will often need to be overridden to customize the Nape material object. 
		 */
		protected function createMaterial():void {
			
			_material = new Material(0.65, 0.57, 1.2, 1, 0);
		}
		
		/**
		 * This method will often need to be overridden to customize the Nape shape object.
		 * The PhysicsObject creates a rectangle by default if the radius it not defined, but you can replace this method's
		 * definition and instead create a custom shape, such as a line or circle.
		 */	
		protected function createShape():void {
			
			// Used by the Tiled Map Editor software, if we defined a polygon/polyline
			if (points && points.length > 1) {
				
				var verts:Vec2List = new Vec2List();

				for each (var point:Object in points)
					verts.push(Vec2.weak(point.x as Number, point.y as Number));

				var geomPoly:GeomPoly = new GeomPoly(verts);
				var polygon:Polygon = new Polygon(geomPoly, _material);
				var validation:ValidationResult = polygon.validity();

				if (validation == ValidationResult.VALID)
					_shape = polygon;
					
				else if (validation == ValidationResult.CONCAVE) {
					
					var convex:GeomPolyList = geomPoly.convexDecomposition();
					convex.foreach(function(p:GeomPoly):void {
						_body.shapes.add(new Polygon(p));
					});
					
					return;
					
				} else
					throw new Error("Invalid polygon/polyline");
				
			} else {
			
				if (_radius != 0)
					_shape = new Circle(_radius, null, _material);
				else
					_shape = new Polygon(Polygon.box(_width, _height), _material);
			}
			
			_body.shapes.add(_shape);
		}
		
		/**
		 * This method will often need to be overridden to customize the Nape filter object. 
		 */
		protected function createFilter():void {
			
			_body.setShapeFilters(new InteractionFilter(PhysicsCollisionCategories.Get("Level"), PhysicsCollisionCategories.GetAll()));
		}
		
		/**
		 * This method will often need to be overridden to customize the Nape constraint object. 
		 */
		protected function createConstraint():void {
			
			_body.space = _nape.space;			
			_body.cbTypes.add(PHYSICS_OBJECT);
		}
		
		public function get x():Number
		{
			if (_body)
				return _body.position.x;
			else
				return _x;
		}
		
		public function set x(value:Number):void
		{
			_x = value;
			
			if (_body)
			{
				var pos:Vec2 = _body.position;
				pos.x = _x;
				_body.position = pos;
			}
		}
			
		public function get y():Number
		{
			if (_body)
				return _body.position.y;
			else
				return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
			
			if (_body)
			{
				var pos:Vec2 = _body.position;
				pos.y = _y;
				_body.position = pos;
			}
		}
		
		public function get z():Number {
			return 0;
		}
		
		public function get rotation():Number
		{
			if (_body)
				return _body.rotation * 180 / Math.PI;
			else
				return _rotation * 180 / Math.PI;
		}
		
		public function set rotation(value:Number):void
		{
			_rotation = value * Math.PI / 180;
			
			if (_body)
				_body.rotation = _rotation;
		}
		
		/**
		 * This can only be set in the constructor parameters. 
		 */		
		public function get width():Number
		{
			return _width;
		}
		
		public function set width(value:Number):void
		{
			_width = value;
			
			if (_initialized && !hideParamWarnings)
				trace("Warning: You cannot set " + this + " width after it has been created. Please set it in the constructor.");
		}
		
		/**
		 * This can only be set in the constructor parameters. 
		 */	
		public function get height():Number
		{
			return _height;
		}
		
		public function set height(value:Number):void
		{
			_height = value;
			
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
			return _radius;
		}
		
		/**
		 * The object has a radius or a width and height. It can't have both.
		 */
		[Inspectable(defaultValue="0")]
		public function set radius(value:Number):void
		{
			_radius = value;
			
			if (_initialized)
			{
				trace("Warning: You cannot set " + this + " radius after it has been created. Please set it in the constructor.");
			}
		}
		
		/**
		 * A direct reference to the Nape body associated with this object.
		 */
		public function get body():Body {
			return _body;
		}
		
		override public function getBody():*
		{
			return _body;
		}
		
		public function get velocity():Array {
			return [_body.velocity.x, _body.velocity.y, 0];
		}
		
		public function set velocity(value:Array):void {
			_body.velocity.setxy(value[0], value[1]);
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
		public function set endContactCallEnabled(endContactCallEnabled:Boolean):void {
			_endContactCallEnabled = endContactCallEnabled;
		}
	}
}
