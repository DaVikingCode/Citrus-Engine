package awayphysics.car {

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.OBJParser;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.textures.BitmapTexture;

	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.shapes.AWPCompoundShape;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.vehicle.AWPRaycastVehicle;
	import awayphysics.dynamics.vehicle.AWPVehicleTuning;
	import awayphysics.dynamics.vehicle.AWPWheelInfo;

	import com.citrusengine.core.State;
	import com.citrusengine.objects.AwayPhysicsObject;
	import com.citrusengine.physics.awayphysics.AwayPhysics;
	import com.citrusengine.view.CitrusView;
	import com.citrusengine.view.away3dview.Away3DView;

	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	/**
	 * @author Aymeric, car demo coming from AwayPhysics examples
	 */
	public class CarGameState extends State {

		[Embed(source="/../embed/3D/carskin.jpg")]
		private const CarSkin:Class;

		private var _away3D:View3D;
		private var _awayPhysics:AwayPhysics;

		private var car:AWPRaycastVehicle;

		private var _light:PointLight;
		private var _lightPicker:StaticLightPicker;

		private var _engineForce:Number = 0;
		private var _breakingForce:Number = 0;
		private var _vehicleSteering:Number = 0;
		private var keyRight:Boolean = false;
		private var keyLeft:Boolean = false;

		public function CarGameState() {
			super();
		}

		override public function initialize():void {

			super.initialize();

			_away3D = (view as Away3DView).viewRoot;

			addChild(new AwayStats(_away3D));

			_awayPhysics = new AwayPhysics("AwayPhysics");
			// awayPhysics.visible = true;
			add(_awayPhysics);

			_light = new PointLight();
			_light.y = 5000;
			_away3D.scene.addChild(_light);
			_lightPicker = new StaticLightPicker([_light]);

			AssetLibrary.enableParser(OBJParser);

			// load scene model
			var _loader:Loader3D = new Loader3D();
			_loader.load(new URLRequest('3D/scene.obj'));
			_loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, _onSceneResourceComplete);

			// load car model
			_loader = new Loader3D();
			_loader.load(new URLRequest('3D/car.obj'));
			_loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, _onCarResourceComplete);

			_away3D.camera.lens.far = 20000;
			_away3D.camera.y = 2000;
			_away3D.camera.z = -2000;
			_away3D.camera.rotationX = 40;

			stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, _keyUpHandler);
		}
		
		// Make sure and call this override to specify Away3D view.
		override protected function createView():CitrusView {

			return new Away3DView(this);
		}

		override public function destroy():void {

			stage.removeEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler);
			stage.removeEventListener(KeyboardEvent.KEY_UP, _keyUpHandler);

			super.destroy();
		}

		private function _onSceneResourceComplete(event:LoaderEvent):void {

			var container:ObjectContainer3D = ObjectContainer3D(event.target);
			(view as Away3DView).container.addChild(container);

			var materia:ColorMaterial = new ColorMaterial(0xfa6c16);
			materia.lightPicker = _lightPicker;

			var sceneMesh:Mesh = Mesh(container.getChildAt(0));
			sceneMesh.geometry.scale(1000);
			sceneMesh.material = materia;

			var material:ColorMaterial = new ColorMaterial(0x252525);
			material.lightPicker = _lightPicker;

			// create triangle mesh shape
			var sceneShape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(sceneMesh.geometry);
			var sceneBody:AWPRigidBody = new AWPRigidBody(sceneShape, sceneMesh, 0);
			_awayPhysics.world.addRigidBody(sceneBody);

			// create rigidbodies
			var mesh:Mesh;
			var awayPhysicsObject:AwayPhysicsObject;
			var numx:uint = 10;
			var numy:uint = 5;
			var numz:uint = 1;
			for (var i:uint = 0; i < numx; ++i) {
				for (var j:uint = 0; j < numz; ++j) {
					for (var k:uint = 0; k < numy; ++k) {
						mesh = new Mesh(new CubeGeometry(200, 200, 200), material);
						awayPhysicsObject = new AwayPhysicsObject("awayPhysicsObject", {view:mesh, width:200, height:200, depth:200, x:-1500 + i * 200, y:200 + k * 200, z:1000 + j * 200});
						add(awayPhysicsObject);
						awayPhysicsObject.body.friction = 0.9;
					}
				}
			}
		}

		private function _onCarResourceComplete(event:LoaderEvent):void {

			var container:ObjectContainer3D = ObjectContainer3D(event.target);
			(view as Away3DView).container.addChild(container);
			var mesh:Mesh;

			var carMaterial:TextureMaterial = new TextureMaterial(new BitmapTexture(new CarSkin().bitmapData));
			carMaterial.lightPicker = _lightPicker;
			for (var i:uint = 0; i < container.numChildren; ++i) {
				mesh = Mesh(container.getChildAt(i));
				mesh.geometry.scale(100);
				mesh.material = carMaterial;
			}

			// create the chassis body
			var carShape:AWPCompoundShape = _createCarShape();
			var carBody:AWPRigidBody = new AWPRigidBody(carShape, container.getChildAt(4), 1200);
			carBody.activationState = AWPCollisionObject.DISABLE_DEACTIVATION;
			carBody.friction = 0.9;
			carBody.linearDamping = 0.1;
			carBody.angularDamping = 0.1;
			carBody.position = new Vector3D(0, 10, -1000);
			_awayPhysics.world.addRigidBody(carBody);

			// create vehicle
			var turning:AWPVehicleTuning = new AWPVehicleTuning();
			turning.frictionSlip = 2;
			turning.suspensionStiffness = 100;
			turning.suspensionDamping = 0.85;
			turning.suspensionCompression = 0.83;
			turning.maxSuspensionTravelCm = 20;
			turning.maxSuspensionForce = 10000;
			car = new AWPRaycastVehicle(turning, carBody);
			_awayPhysics.world.addVehicle(car);

			// add four wheels
			car.addWheel(container.getChildAt(0), new Vector3D(-110, 80, 170), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 40, 60, turning, true);
			car.addWheel(container.getChildAt(3), new Vector3D(110, 80, 170), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 40, 60, turning, true);
			car.addWheel(container.getChildAt(1), new Vector3D(-110, 90, -210), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 40, 60, turning, false);
			car.addWheel(container.getChildAt(2), new Vector3D(110, 90, -210), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 40, 60, turning, false);

			for (i = 0; i < car.getNumWheels(); ++i) {
				var wheel:AWPWheelInfo = car.getWheelInfo(i);
				wheel.wheelsDampingRelaxation = 4.5;
				wheel.wheelsDampingCompression = 4.5;
				wheel.suspensionRestLength1 = 20;
				wheel.rollInfluence = 0.01;
			}
		}

		private function _createCarShape():AWPCompoundShape {

			var boxShape1:AWPBoxShape = new AWPBoxShape(260, 60, 570);
			var boxShape2:AWPBoxShape = new AWPBoxShape(240, 70, 300);

			var carShape:AWPCompoundShape = new AWPCompoundShape();
			carShape.addChildShape(boxShape1, new Vector3D(0, 100, 0), new Vector3D());
			carShape.addChildShape(boxShape2, new Vector3D(0, 150, -30), new Vector3D());

			return carShape;
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);

			if (keyLeft) {
				_vehicleSteering -= 0.05;
				if (_vehicleSteering < -Math.PI / 6) {
					_vehicleSteering = -Math.PI / 6;
				}
			}
			if (keyRight) {
				_vehicleSteering += 0.05;
				if (_vehicleSteering > Math.PI / 6) {
					_vehicleSteering = Math.PI / 6;
				}
			}

			if (car) {
				// control the car
				car.applyEngineForce(_engineForce, 0);
				car.setBrake(_breakingForce, 0);
				car.applyEngineForce(_engineForce, 1);
				car.setBrake(_breakingForce, 1);
				car.applyEngineForce(_engineForce, 2);
				car.setBrake(_breakingForce, 2);
				car.applyEngineForce(_engineForce, 3);
				car.setBrake(_breakingForce, 3);

				car.setSteeringValue(_vehicleSteering, 0);
				car.setSteeringValue(_vehicleSteering, 1);
				_vehicleSteering *= 0.9;

				_away3D.camera.position = car.getRigidBody().position.add(new Vector3D(0, 2000, -2500));
				_away3D.camera.lookAt(car.getRigidBody().position);
			}
		}

		private function _keyDownHandler(kEvt:KeyboardEvent):void {

			switch(kEvt.keyCode) {

				case Keyboard.UP:
					_engineForce = 8000;
					_breakingForce = 0;
					break;

				case Keyboard.DOWN:
					_engineForce = -8000;
					_breakingForce = 0;
					break;

				case Keyboard.LEFT:
					keyLeft = true;
					keyRight = false;
					break;

				case Keyboard.RIGHT:
					keyRight = true;
					keyLeft = false;
					break;

				case Keyboard.SPACE:
					_breakingForce = 80;
					_engineForce = 0;
					break;
			}
		}

		private function _keyUpHandler(kEvt:KeyboardEvent):void {

			switch(kEvt.keyCode) {

				case Keyboard.UP:
					_engineForce = 0;
					break;

				case Keyboard.DOWN:
					_engineForce = 0;
					break;

				case Keyboard.LEFT:
					keyLeft = false;
					break;

				case Keyboard.RIGHT:
					keyRight = false;
					break;

				case Keyboard.SPACE:
					_breakingForce = 0;
					break;
			}
		}

	}
}
