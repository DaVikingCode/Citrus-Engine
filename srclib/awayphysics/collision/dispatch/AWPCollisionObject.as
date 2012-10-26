package awayphysics.collision.dispatch {
	import away3d.containers.ObjectContainer3D;

	import awayphysics.AWPBase;
	import awayphysics.collision.shapes.AWPCollisionShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.events.AWPEvent;
	import awayphysics.math.AWPTransform;
	import awayphysics.math.AWPVector3;
	import awayphysics.math.AWPMath;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class AWPCollisionObject extends AWPBase implements IEventDispatcher {
		public static const ACTIVE_TAG : int = 1;
		public static const ISLAND_SLEEPING : int = 2;
		public static const WANTS_DEACTIVATION : int = 3;
		public static const DISABLE_DEACTIVATION : int = 4;
		public static const DISABLE_SIMULATION : int = 5;
		
		private var m_shape : AWPCollisionShape;
		private var m_skin : ObjectContainer3D;
		private var m_worldTransform : AWPTransform;
		private var m_anisotropicFriction : AWPVector3;
		
		private var _rays:Vector.<AWPRay>;
		
		private var _transform:Matrix3D = new Matrix3D();
		private var _originScale:Vector3D = new Vector3D(1, 1, 1);
		private var _dispatcher : EventDispatcher;

		public function AWPCollisionObject(shape : AWPCollisionShape, skin : ObjectContainer3D, ptr : uint = 0) {
			m_shape = shape;
			m_skin = skin;
			
			m_shape.retain();
			
			if(ptr>0){
				pointer = ptr;
				m_worldTransform = new AWPTransform(ptr + 4);
				m_anisotropicFriction = new AWPVector3(ptr + 164);
			}else{
				pointer = bullet.createCollisionObjectMethod(this, shape.pointer);
				
				m_worldTransform = new AWPTransform(pointer + 4);
				m_anisotropicFriction = new AWPVector3(pointer + 164);
			}
			
			if (m_skin) {
				_originScale.setTo(m_skin.scaleX, m_skin.scaleY, m_skin.scaleZ);
			}
			
			_rays = new Vector.<AWPRay>();
			_dispatcher = new EventDispatcher(this);
		}

		public function get shape() : AWPCollisionShape {
			return m_shape;
		}

		public function get skin() : ObjectContainer3D {
			return m_skin;
		}
		
		public function set skin(value:ObjectContainer3D):void {
			m_skin = value;
			_originScale.setTo(m_skin.scaleX, m_skin.scaleY, m_skin.scaleZ);
		}
		
		public function dispose():void {
			if (!cleanup) {
				cleanup	= true;
				removeAllRays();
				m_shape.dispose();
				bullet.disposeCollisionObjectMethod(pointer);
			}
		}

		/**
		 * update the transform of skin mesh
		 * called by dynamicsWorld
		 */
		public function updateTransform() : void {
			if (!m_skin) return;
			
			_transform.identity();
			var sc:Vector3D = m_shape.localScaling;
			_transform.appendScale(_originScale.x * sc.x, _originScale.y * sc.y, _originScale.z * sc.z);
			_transform.append(m_worldTransform.transform);
			
			m_skin.transform = _transform;
		}

		/**
		 * set the position in world coordinates
		 */
		public function set position(pos : Vector3D) : void {
			m_worldTransform.position = pos;
			updateTransform();
		}
		/**
		 * get the position in world coordinates
		 */
		public function get position() : Vector3D {
			return m_worldTransform.position;
		}
		
		/**
		 * set the position in x axis
		 */
		public function set x(v:Number):void {
			m_worldTransform.position = new Vector3D(v, m_worldTransform.position.y, m_worldTransform.position.z);
			updateTransform();
		}
		/**
		 * get the position in x axis
		 */
		public function get x():Number {
			return m_worldTransform.position.x;
		}
		
		/**
		 * set the position in y axis
		 */
		public function set y(v:Number):void {
			m_worldTransform.position = new Vector3D(m_worldTransform.position.x, v, m_worldTransform.position.z);
			updateTransform();
		}
		/**
		 * get the position in y axis
		 */
		public function get y():Number {
			return m_worldTransform.position.y;
		}
		
		/**
		 * set the position in z axis
		 */
		public function set z(v:Number):void {
			m_worldTransform.position = new Vector3D(m_worldTransform.position.x, m_worldTransform.position.y, v);
			updateTransform();
		}
		/**
		 * get the position in z axis
		 */
		public function get z():Number {
			return m_worldTransform.position.z;
		}

		/**
		 * set the euler angle in degrees
		 */
		public function set rotation(rot : Vector3D) : void {
			m_worldTransform.rotation = AWPMath.degrees2radiansV3D(rot);
			updateTransform();
		}
		/**
		 * get the euler angle in degrees
		 */
		public function get rotation() : Vector3D {
			return AWPMath.radians2degreesV3D(m_worldTransform.rotation);
		}
		
		/**
		 * set the angle of x axis in degree
		 */
		public function set rotationX(angle:Number):void {
			m_worldTransform.rotation = new Vector3D(angle * AWPMath.DEGREES_TO_RADIANS, m_worldTransform.rotation.y, m_worldTransform.rotation.z);
			updateTransform();
		}
		/**
		 * get the angle of x axis in degree
		 */
		public function get rotationX():Number {
			return m_worldTransform.rotation.x * AWPMath.RADIANS_TO_DEGREES;
		}
		
		/**
		 * set the angle of y axis in degree
		 */
		public function set rotationY(angle:Number):void {
			m_worldTransform.rotation = new Vector3D(m_worldTransform.rotation.x, angle * AWPMath.DEGREES_TO_RADIANS, m_worldTransform.rotation.z);
			updateTransform();
		}
		/**
		 * get the angle of y axis in degree
		 */
		public function get rotationY():Number {
			return m_worldTransform.rotation.y * AWPMath.RADIANS_TO_DEGREES;
		}
		
		/**
		 * set the angle of z axis in degree
		 */
		public function set rotationZ(angle:Number):void {
			m_worldTransform.rotation = new Vector3D(m_worldTransform.rotation.x, m_worldTransform.rotation.y, angle * AWPMath.DEGREES_TO_RADIANS);
			updateTransform();
		}
		/**
		 * get the angle of z axis in degree
		 */
		public function get rotationZ():Number {
			return m_worldTransform.rotation.z * AWPMath.RADIANS_TO_DEGREES;
		}
		
		/**
		 * set the scaling of collision shape
		 */
		public function set scale(sc:Vector3D):void {
			m_shape.localScaling = sc;
			updateTransform();
		}
		/**
		 * get the scaling of collision shape
		 */
		public function get scale():Vector3D {
			return m_shape.localScaling;
		}

		/**
		 * set the transform in world coordinates
		 */
		public function set transform(tr:Matrix3D) : void {
			m_worldTransform.transform = tr;
			m_shape.localScaling = tr.decompose()[2];
			updateTransform();
		}
		/**
		 * get the transform in world coordinates
		 */
		public function get transform():Matrix3D {
			return m_worldTransform.transform;
		}
		
		public function get worldTransform():AWPTransform {
			return m_worldTransform;
		}
		
		/**
		 * get the front direction in world coordinates
		 */
		public function get front():Vector3D {
			return m_worldTransform.basis.column3;
		}
		/**
		 * get the up direction in world coordinates
		 */
		public function get up():Vector3D {
			return m_worldTransform.basis.column2;
		}
		/**
		 * get the right direction in world coordinates
		 */
		public function get right():Vector3D {
			return m_worldTransform.basis.column1;
		}
		
		/**
		 * add a ray in local space
		 */
		public function addRay(from:Vector3D, to:Vector3D):void {
			var ptr:uint = bullet.addRayMethod(pointer, from.x/_scaling, from.y/_scaling, from.z/_scaling, to.x/_scaling, to.y/_scaling, to.z/_scaling);
			_rays.push(new AWPRay(from, to, ptr));
		}
		 /**
		  * remove a ray by index
		  */
		public function removeRay(index:uint):void {
			if(index<_rays.length){
				bullet.removeRayMethod(_rays[index].pointer);
				_rays.splice(index, 1);
			}
		}
		/**
		  * remove all rays in this collision object
		  */
		public function removeAllRays():void {
			while (_rays.length > 0){
				removeRay(0);
			}
			_rays.length = 0;
		}
		
		/**
		 * get all rays
		 */
		public function get rays():Vector.<AWPRay> {
			return _rays;
		}
		
		public function get anisotropicFriction() : Vector3D {
			return m_anisotropicFriction.v3d;
		}

		public function set anisotropicFriction(v : Vector3D) : void {
			m_anisotropicFriction.v3d = v;
			hasAnisotropicFriction = (v.x != 1 || v.y != 1 || v.z != 1) ? 1 : 0;
		}

		public function get friction() : Number {
			return memUser._mrf(pointer + 224);
		}

		public function set friction(v : Number) : void {
			memUser._mwf(pointer + 224, v);
		}

		public function get restitution() : Number {
			return memUser._mrf(pointer + 228);
		}

		public function set restitution(v : Number) : void {
			memUser._mwf(pointer + 228, v);
		}

		public function get hasAnisotropicFriction() : int {
			return memUser._mr32(pointer + 180);
		}

		public function set hasAnisotropicFriction(v : int) : void {
			memUser._mw32(pointer + 180, v);
		}

		public function get contactProcessingThreshold() : Number {
			return memUser._mrf(pointer + 184);
		}

		public function set contactProcessingThreshold(v : Number) : void {
			memUser._mwf(pointer + 184, v);
		}

		public function get collisionFlags() : int {
			return memUser._mr32(pointer + 204);
		}

		public function set collisionFlags(v : int) : void {
			memUser._mw32(pointer + 204, v);
		}

		public function get islandTag() : int {
			return memUser._mr32(pointer + 208);
		}

		public function set islandTag(v : int) : void {
			memUser._mw32(pointer + 208, v);
		}

		public function get companionId() : int {
			return memUser._mr32(pointer + 212);
		}

		public function set companionId(v : int) : void {
			memUser._mw32(pointer + 212, v);
		}

		public function get deactivationTime() : Number {
			return memUser._mrf(pointer + 220);
		}

		public function set deactivationTime(v : Number) : void {
			memUser._mwf(pointer + 220, v);
		}

		public function get activationState() : int {
			return memUser._mr32(pointer + 216);
		}

		public function set activationState(newState : int) : void {
			if (activationState != AWPCollisionObject.DISABLE_DEACTIVATION && activationState != AWPCollisionObject.DISABLE_SIMULATION) {
				memUser._mw32(pointer + 216, newState);
			}
		}

		public function forceActivationState(newState : int) : void {
			memUser._mw32(pointer + 216, newState);
		}

		public function activate(forceActivation : Boolean = false) : void {
			if (forceActivation || (collisionFlags != AWPCollisionFlags.CF_STATIC_OBJECT && collisionFlags != AWPCollisionFlags.CF_KINEMATIC_OBJECT)) {
				this.activationState = AWPCollisionObject.ACTIVE_TAG;
				this.deactivationTime = 0;
			}
		}

		public function get isActive() : Boolean {
			return (activationState != AWPCollisionObject.ISLAND_SLEEPING && activationState != AWPCollisionObject.DISABLE_SIMULATION);
		}
		
		/**
		 * reserved to distinguish Bullet's btCollisionObject, btRigidBody, btSoftBody, btGhostObject etc.
		 * the values defined by AWPCollisionObjectTypes
		 */
		public function get internalType() : int {
			return memUser._mr32(pointer + 232);
		}
		
		public function get hitFraction() : Number {
			return memUser._mrf(pointer + 240);
		}

		public function set hitFraction(v : Number) : void {
			memUser._mwf(pointer + 240, v);
		}
		
		public function get ccdSweptSphereRadius() : Number {
			return memUser._mrf(pointer + 244);
		}

		/**
		 * used to motion clamping
		 * refer to http://bulletphysics.org/mediawiki-1.5.8/index.php/Anti_tunneling_by_Motion_Clamping
		 */
		public function set ccdSweptSphereRadius(v : Number) : void {
			memUser._mwf(pointer + 244, v);
		}
		
		public function get ccdMotionThreshold() : Number {
			return memUser._mrf(pointer + 248);
		}

		/**
		 * used to motion clamping
		 * refer to http://bulletphysics.org/mediawiki-1.5.8/index.php/Anti_tunneling_by_Motion_Clamping
		 */
		public function set ccdMotionThreshold(v : Number) : void {
			memUser._mwf(pointer + 248, v);
		}

		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void {
			this.collisionFlags |= AWPCollisionFlags.CF_CUSTOM_MATERIAL_CALLBACK;
			_dispatcher.addEventListener(type, listener, useCapture, priority);
		}

		public function dispatchEvent(evt : Event) : Boolean {
			return _dispatcher.dispatchEvent(evt);
		}

		public function hasEventListener(type : String) : Boolean {
			return _dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void {
			this.collisionFlags &= (~AWPCollisionFlags.CF_CUSTOM_MATERIAL_CALLBACK);
			_dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger(type : String) : Boolean {
			return _dispatcher.willTrigger(type);
		}

		/**
		 * this function just called by alchemy
		 */
		public function collisionCallback(mpt : uint, obj : AWPCollisionObject) : void {
			var pt : AWPManifoldPoint = new AWPManifoldPoint(mpt);
			var event : AWPEvent = new AWPEvent(AWPEvent.COLLISION_ADDED);
			event.manifoldPoint = pt;
			event.collisionObject = obj;

			this.dispatchEvent(event);
		}
		/**
		 * this function just called by alchemy
		 */
		public function rayCastCallback(mpt : uint, obj : AWPCollisionObject) : void {
			var pt : AWPManifoldPoint = new AWPManifoldPoint(mpt);
			var event : AWPEvent = new AWPEvent(AWPEvent.RAY_CAST);
			event.manifoldPoint = pt;
			event.collisionObject = obj;

			this.dispatchEvent(event);
		}
	}
}