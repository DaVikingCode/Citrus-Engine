package citrus.objects.vehicle.nape {

	import citrus.objects.CitrusSprite;
	import citrus.objects.NapePhysicsObject;

	import nape.constraint.DistanceJoint;
	import nape.constraint.LineJoint;
	import nape.constraint.MotorJoint;
	import nape.constraint.WeldJoint;
	import nape.geom.Vec2;
	import nape.phys.Material;
	import nape.shape.Polygon;

	import flash.geom.Point;
	
	/**
	 * This car class is a perfect example to show how to combine several physics objects and make a complex object with the Citrus Engine. 
	 * We advice to make it running with the Hills class to create an endless driver game.
	 * It has a chassis (this class) which will create two weels, add a driver, some nuggets (objects to save) and you can even add some particles to make an exhaust pipe! 
	 * Everything is overrideable to make it fully customizable. Note it may run on Starling or the display list.
	 * 
	 * Thanks <a href="http://studio3wg.com/">studio3wg/</a> to let us share this package with the world :)
	 */
	public class Car extends NapePhysicsObject {
		
		/**
		 * Determines if the car has 4WD or just the front wheel.
		 */
		public var isSuv:Boolean = true;
		
		public var material:Material = new Material(0, 2, 2, 3, 0.01);
		public var driverMaterial:Material = new Material(0, 2, 2, 2.2, 0.01);
		public var wheelsMaterial:Material = new Material(0.15,1, 2,3, 2);

		public var motorSpeed:Number = 0;
		public var motorAccel:Number = 0.05;
		public var maxSpeed:Number = 14;
		public var angularVel:Number = 0.5;
		
		/**
		 * Like in a <a href="http://www.adamatomic.com/canabalt/">Canabalt</a> game, the vehicle max speed will always increase.
		 */
		public var constantAccel:Number = 0.001;

		public var raceDamper:Number = 30;
		public var heightDamper:Number = 30;
		public var distanceChassisPivot:Number = 20;

		public var posBackWheel:Number = -37;
		public var posFrontWheel:Number = 37;
		public var posDriver:Point = new Point(30, 30);
		public var damper:Number = 0.28;
		public var frequency:Number = 1;
		
		public var backWheelArt:*;
		public var frontWheelArt:*;
		public var wheelsGroup:uint = 1;
		public var wheelsRadius:Number = 20;
		
		public var particleArt:*;
		protected var _particle:CitrusSprite;
		
		public var nmbrNuggets:uint = 0;
		protected var _nuggets:Vector.<Nugget>;

		protected var _backWheel:Wheel;
		protected var _frontWheel:Wheel;
		protected var _driver:Driver;

		protected var _lineJoint1:LineJoint;
		protected var _lineJoint2:LineJoint;
		protected var _distanceJoint1:DistanceJoint;
		protected var _distanceJoint2:DistanceJoint;
		protected var _motorJoint1:MotorJoint;
		protected var _motorJoint2:MotorJoint;
		
		protected var _launched:Boolean = true;

		public function Car(name:String, params:Object = null) {
			
			updateCallEnabled = true;
			
			super(name, params);
		}
			
		override public function addPhysics():void {
			super.addPhysics();
			
			_addDriver();
			_addWheels();
			_linkCarToWheels();
			_addMotors();
			_addJointsToSpace();
			_addParticle();
			_addNuggets();
		}
			
		override public function destroy():void {
			
			_ce.state.remove(_driver);
			_ce.state.remove(_frontWheel);
			_ce.state.remove(_backWheel);
			
			if (_particle)
				_ce.state.remove(_particle);
				
			if (_nuggets) {
				
				for each (var nugget:Nugget in _nuggets)
					_ce.state.remove(nugget);
				
				_nuggets.length = 0;
			}
			
			super.destroy();
		}

		protected function _addDriver():void {

			_driver = new Driver("driver", {material:driverMaterial});
			_ce.state.add(_driver);

			var driverJoint:WeldJoint = new WeldJoint(_body, _driver.body, new Vec2(posDriver.x, -posDriver.y), new Vec2(0, 0));
			driverJoint.space = _nape.space;
		}

		protected function _addWheels():void {

			_frontWheel = new Wheel("front wheel", {view:frontWheelArt, group:wheelsGroup, material:wheelsMaterial, radius:wheelsRadius, x:x + posFrontWheel, y:y + distanceChassisPivot});
			_ce.state.add(_frontWheel);

			_lineJoint1 = new LineJoint(_body, _frontWheel.body, new Vec2(posFrontWheel, distanceChassisPivot), new Vec2(0, 0), new Vec2(0, 1), distanceChassisPivot, distanceChassisPivot + heightDamper);
			_lineJoint1.ignore = true;

			_backWheel = new Wheel("back wheel", {view:backWheelArt, group:wheelsGroup, material:wheelsMaterial, radius:wheelsRadius, x:x + posBackWheel, y:y + distanceChassisPivot});
			_ce.state.add(_backWheel);

			_lineJoint2 = new LineJoint(_body, _backWheel.body, new Vec2(posBackWheel, distanceChassisPivot), new Vec2(0, 0), new Vec2(0, 1), distanceChassisPivot, distanceChassisPivot + heightDamper);
			_lineJoint2.ignore = true;
		}

		protected function _linkCarToWheels():void {

			_distanceJoint1 = new DistanceJoint(_body, _frontWheel.body, new Vec2(posFrontWheel, distanceChassisPivot), new Vec2(), distanceChassisPivot + heightDamper, distanceChassisPivot + raceDamper);
			_distanceJoint1.stiff = false;
			_distanceJoint1.frequency = frequency;
			_distanceJoint1.damping = damper;

			_distanceJoint2 = new DistanceJoint(_body, _backWheel.body, new Vec2(posBackWheel, distanceChassisPivot), new Vec2(), distanceChassisPivot + heightDamper, distanceChassisPivot + raceDamper);
			_distanceJoint2.stiff = false;
			_distanceJoint2.frequency = frequency;
			_distanceJoint2.damping = damper;
		}

		protected function _addMotors():void {

			_motorJoint1 = new MotorJoint(_nape.space.world, _backWheel.body, 0);
			_motorJoint2 = new MotorJoint(_nape.space.world, _frontWheel.body, 0);
		}

		protected function _addJointsToSpace():void {

			_lineJoint1.space = _nape.space;
			_lineJoint2.space = _nape.space;
			_distanceJoint1.space = _nape.space;
			_distanceJoint2.space = _nape.space;
			_motorJoint1.space = _nape.space;
			_motorJoint2.space = _nape.space;

			_body.rotate(new Vec2(0, 0), (0.55 * Math.PI / 180));
		}
		
		protected function _addParticle():void {
			
			if (particleArt) {
				_particle = new CitrusSprite("particle", {view:particleArt});
				_ce.state.add(_particle);
			}
		}
		
		protected function _addNuggets():void {
			
			if (nmbrNuggets > 0) {
				
				_nuggets = new Vector.<Nugget>();
				var nugget:Nugget;
				for (var i:uint = 0; i < nmbrNuggets; ++i) {
					
					nugget = new Nugget("nugget" + i, {x:_x, y:_y - _body.bounds.height});
					_nuggets.push(nugget);
					_ce.state.add(nugget);
				}
			}
		}

		override protected function createMaterial():void {
			_material = material;
		}

		override protected function createShape():void {

			var _tab:Array = [];
			var vertices:Array = [];

			vertices.push(Vec2.weak(39, 82));
			vertices.push(Vec2.weak(20, 82));
			vertices.push(Vec2.weak(35, 149));
			vertices.push(Vec2.weak(48, 135));

			_tab.push(vertices);
			vertices = [];

			vertices.push(Vec2.weak(134, 83));
			vertices.push(Vec2.weak(122, 135));
			vertices.push(Vec2.weak(133, 148));
			vertices.push(Vec2.weak(150, 83));

			_tab.push(vertices);
			vertices = [];

			vertices.push(Vec2.weak(35, 149));
			vertices.push(Vec2.weak(133, 148));
			vertices.push(Vec2.weak(122, 135));
			vertices.push(Vec2.weak(48, 135));

			_tab.push(vertices);

			for (var i:uint = 0; i < _tab.length; ++i) {

				var polygonShape:Polygon = new Polygon(_tab[i]);
				_shape = polygonShape;
				_body.shapes.add(_shape);

			}

			_body.translateShapes(Vec2.weak(-90, -90));
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			if (launched) {
				
				motorSpeed += motorAccel;
				maxSpeed += constantAccel;
				
				if (motorSpeed > maxSpeed)
					motorSpeed = maxSpeed;
				
				if (isSuv)
					_motorJoint1.rate = _motorJoint2.rate = motorSpeed;
				else
					_motorJoint2.rate = motorSpeed;
			
				if (_ce.input.isDoing("left"))
					_body.angularVel = -angularVel;
				
				if (_ce.input.isDoing("right"))
					_body.angularVel = angularVel;
			}
			
			if (_particle) {
				
				_particle.x = x - width;
				_particle.y = y + height;
			}
			
		}

		public function get launched():Boolean {
			return _launched;
		}

		public function set launched(value:Boolean):void {
			_launched = value;
			
			if (_launched)
				_motorJoint1.active = _motorJoint2.active = true;
			else {
				_motorJoint1.active = _motorJoint2.active = false;
				motorSpeed = 0;
			}
		}

		public function get nuggets():Vector.<Nugget> {
			return _nuggets;
		}
	}
}
