package Box2DAS.Dynamics {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Controllers.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.utils.*;
	
	/// A rigid body. These are created via b2World::CreateBody.
	public class b2Body extends b2Base {
		
		/// b2Body(const b2BodyDef* bd, b2World* world);
		public function b2Body(w:b2World, d:b2BodyDef = null) {
			d ||= b2Def.body;
			_ptr = lib.b2World_CreateBody(this, w._ptr, d._ptr);
			m_xf = new b2Transform(_ptr + 12);
			m_sweep = new b2Sweep(_ptr + 36);
			m_linearVelocity = new b2Vec2(_ptr + 72);
			m_force = new b2Vec2(_ptr + 84);
			m_userData = d.userData;
			m_next = w.m_bodyList;
			if(m_next) {
				m_next.m_prev = this;
			}
			w.m_bodyList = this;
			m_world = w;
		}
		
		public function IsStatic():Boolean {
			return m_type == b2Body.b2_staticBody;
		}
		
		public function IsDynamic():Boolean {
			return m_type == b2Body.b2_dynamicBody;
		}
		
		public function IsKinematic():Boolean {
			return m_type == b2Body.b2_kinematicBody;
		}
		
		/// Set the type of this body. This may alter the mass and velocity.
		/// void SetType(b2BodyType type);
		public function SetType(type:int):void {
			lib.b2Body_SetType(_ptr, type);
		}
		
		/// Get the type of this body.
		/// b2BodyType GetType() const;
		public function GetType():int {
			return m_type;
		}
		
		public override function destroy():void {
			for(var je:b2JointEdge = GetJointList(); je; je = je.next) {
				var j:b2Joint = je.joint;
				m_world.SayGoodbyeJoint(j);
				j._ptr = 0;
				if(j.m_prev) {
					j.m_prev.m_next = j.m_next;
				}
				if(j.m_next) {
					j.m_next.m_prev = j.m_prev;
				}
				if(m_world.m_jointList == j) {
					m_world.m_jointList = j.m_next;
				}
			}
			for(var f:b2Fixture = m_fixtureList; f; f = f.m_next) {
				m_world.SayGoodbyeFixture(f);
				f.m_shape._ptr = 0;
				f._ptr = 0;
			}
			for(var c:* in m_controllers) {
				(c as b2Controller).RemoveBody(this);
			}
			lib.b2World_DestroyBody(m_world._ptr, _ptr);
			if(m_prev) {
				m_prev.m_next = m_next;
			}
			else {
				m_world.m_bodyList = m_next;
			}
			if(m_next) {
				m_next.m_prev = m_prev;
			}
			super.destroy();
		}

		/// Creates a fixture and attach it to this body. Use this function if you need
		/// to set some fixture parameters, like friction. Otherwise you can create the
		/// fixture directly from a shape.
		/// This function automatically updates the mass of the body.
		/// @param def the fixture definition.
		/// @warning This function is locked during callbacks.		
		/// b2Fixture* CreateFixture(const b2FixtureDef* def);
		public function CreateFixture(def:b2FixtureDef):b2Fixture {
			return new b2Fixture(this, def);
		}
	
		/// Creates a fixture from a shape and attach it to this body.
		/// This is a convenience function. Use b2FixtureDef if you need to set parameters
		/// like friction, restitution, user data, or filtering.
		/// This function automatically updates the mass of the body.
		/// @param shape the shape to be cloned.
		/// @param density the shape density (set to zero for static bodies).
		/// @warning This function is locked during callbacks.
		/// b2Fixture* CreateFixture(const b2Shape* shape, float32 density = 0.0f);
		public function CreateFixtureShape(shape:b2Shape, density:Number):b2Fixture {
			var def:b2FixtureDef = new b2FixtureDef();
			def.shape = shape;
			def.density = density;
			return CreateFixture(def);
		}
		
		/// Destroy a fixture. This removes the fixture from the broad-phase and
		/// therefore destroys any contacts associated with this fixture. All fixtures
		/// attached to a body are implicitly destroyed when the body is destroyed.
		/// @param fixture the fixture to be removed.
		/// @warning This function is locked during callbacks.
		/// void DestroyFixture(b2Fixture* fixture);
		public function DestroyFixture(fixture:b2Fixture):void {
			fixture.destroy();
		}
		
		/// Set the position of the body's origin and rotation.
		/// This breaks any contacts and wakes the other bodies.
		/// @param position the world position of the body's local origin.
		/// @param angle the world rotation in radians.
		/// void SetTransform(const b2Vec2& position, float32 angle);
		public function SetTransform(position:V2, angle:Number):void {
			lib.b2Body_SetTransform(_ptr, position.x, position.y, angle);
		}
	
		/// Get the body transform for the body's origin.
		/// @return the world transform of the body's origin.
		/// const b2Transform& GetTransform() const;
		public function GetTransform():XF {
			return m_xf.xf;
		}
		
		/// Get the world body origin position.
		/// @return the world position of the body's origin.
		/// const b2Vec2& GetPosition() const;
		public function GetPosition():V2 {
			return m_xf.position.v2;
		}
		
		/// Get the angle in radians.
		/// @return the current world rotation angle in radians.
		/// float32 GetAngle() const;
		public function GetAngle():Number {
			return m_sweep.a;
		}
		
		/// Get the world position of the center of mass.
		/// const b2Vec2& GetWorldCenter() const;
		public function GetWorldCenter():V2 {
			return m_sweep.c.v2;
		}
		
		/// Get the local position of the center of mass.
		/// const b2Vec2& GetLocalCenter() const;
		public function GetLocalCenter():V2 {
			return m_sweep.localCenter.v2;
		}
		
		/// Set the linear velocity of the center of mass.
		/// @param v the new linear velocity of the center of mass.
		/// void SetLinearVelocity(const b2Vec2& v);
		public function SetLinearVelocity(v:V2):void {
			m_linearVelocity.v2 = v;
		}
		
		/// Get the linear velocity of the center of mass.
		/// @return the linear velocity of the center of mass.
		/// b2Vec2 GetLinearVelocity() const;
		public function GetLinearVelocity():V2 {
			return m_linearVelocity.v2;
		}
		
		/// Set the angular velocity.
		/// @param omega the new angular velocity in radians/second.
		/// void SetAngularVelocity(float32 omega);
		public function SetAngularVelocity(omega:Number):void {
			m_angularVelocity = omega;
		}
		
		/// Get the angular velocity.
		/// @return the angular velocity in radians/second.
		/// float32 GetAngularVelocity() const;
		public function GetAngularVelocity():Number {
			return m_angularVelocity;
		}
		
		/// Apply a force at a world point. If the force is not
		/// applied at the center of mass, it will generate a torque and
		/// affect the angular velocity. This wakes up the body.
		/// @param force the world force vector, usually in Newtons (N).
		/// @param point the world position of the point of application.
		/// void ApplyForce(const b2Vec2& force, const b2Vec2& point);
		public function ApplyForce(force:V2, point:V2):void {
			SetAwake(true);
			m_force.x += force.x;
			m_force.y += force.y;
			m_torque += V2.subtract(point, m_sweep.c.v2).cross(force);
		}
		
		/// Apply a torque. This affects the angular velocity
		/// without affecting the linear velocity of the center of mass.
		/// This wakes up the body.
		/// @param torque about the z-axis (out of the screen), usually in N-m.
		/// void ApplyTorque(float32 torque);
		public function ApplyTorque(torque:Number):void {
			SetAwake(true);
			m_torque += torque;
		}
		
		/// Apply an impulse at a point. This immediately modifies the velocity.
		/// It also modifies the angular velocity if the point of application
		/// is not at the center of mass. This wakes up the body.
		/// @param impulse the world impulse vector, usually in N-seconds or kg-m/s.
		/// @param point the world position of the point of application.
		/// void ApplyImpulse(const b2Vec2& impulse, const b2Vec2& point);
		public function ApplyImpulse(impulse:V2, point:V2):void {
			SetAwake(true);
			m_linearVelocity.x += m_invMass * impulse.x;
			m_linearVelocity.y += m_invMass * impulse.y;
			m_angularVelocity += m_invI * V2.subtract(point, m_sweep.c.v2).cross(impulse);
		}
		
		/// Get the total mass of the body.
		/// @return the mass, usually in kilograms (kg).
		/// float32 GetMass() const;
		public function GetMass():Number {
			return m_mass;
		}
	
		/// Get the central rotational inertia of the body.
		/// @return the rotational inertia, usually in kg-m^2.
		/// float32 GetInertia() const;
		public function GetInertia():Number {
			return m_I;
		}
		
		/// Get the mass data of the body. The rotational inertia is relative
		/// to the center of mass.
		/// @return a struct containing the mass, inertia and center of the body.
		/// void GetMassData(b2MassData* data) const;
		public function GetMassData(data:b2MassData):void {
			lib.b2Body_GetMassData(_ptr, data._ptr);
		}
		
		/// Set the mass properties to override the mass properties of the fixtures.
		/// Note that this changes the center of mass position. You can make the body
		/// static by using zero mass.
		/// Note that creating or destroying fixtures can also alter the mass.
		/// @warning The supplied rotational inertia is assumed to be relative to the center of mass.
		/// @param massData the mass properties.
		/// void SetMassData(const b2MassData* data);
		public function SetMassData(data:b2MassData):void {
			lib.b2Body_SetMassData(_ptr, data._ptr);
		}
	
		/// This resets the mass properties to the sum of the mass properties of the fixtures.
		/// This normally does not need to be called unless you called SetMassData to override
		/// the mass and you later want to reset the mass.
		/// void ResetMass();
		public function ResetMassData():void {
			lib.b2Body_ResetMassData(_ptr);
		}
		
		/// Get the world coordinates of a point given the local coordinates.
		/// @param localPoint a point on the body measured relative the the body's origin.
		/// @return the same point expressed in world coordinates.
		/// b2Vec2 GetWorldPoint(const b2Vec2& localPoint) const;
		public function GetWorldPoint(localPoint:V2):V2 {
			return m_xf.xf.multiply(localPoint);
		}
		
		/// Get the world coordinates of a vector given the local coordinates.
		/// @param localVector a vector fixed in the body.
		/// @return the same vector expressed in world coordinates.
		/// b2Vec2 GetWorldVector(const b2Vec2& localVector) const;
		public function GetWorldVector(localVector:V2):V2 {
			return m_xf.R.m22.multiplyV(localVector);
		}
		
		/// Gets a local point relative to the body's origin given a world point.
		/// @param a point in world coordinates.
		/// @return the corresponding local point relative to the body's origin.
		/// b2Vec2 GetLocalPoint(const b2Vec2& worldPoint) const;
		public function GetLocalPoint(worldPoint:V2):V2 {
			return m_xf.xf.multiplyT(worldPoint);
		}
		
		/// Gets a local vector given a world vector.
		/// @param a vector in world coordinates.
		/// @return the corresponding local vector.
		/// b2Vec2 GetLocalVector(const b2Vec2& worldVector) const;
		public function GetLocalVector(worldVector:V2):V2 {
			return m_xf.R.m22.multiplyVT(worldVector);
		}
		
		/// Get the world linear velocity of a world point attached to this body.
		/// @param a point in world coordinates.
		/// @return the world velocity of a point.
		/// b2Vec2 GetLinearVelocityFromWorldPoint(const b2Vec2& worldPoint) const;
		public function GetLinearVelocityFromWorldPoint(worldPoint:V2):V2 {
			return m_linearVelocity.v2.add(V2.crossNV(m_angularVelocity, V2.subtract(worldPoint, m_sweep.c.v2)));
		}
		
		/// Get the world velocity of a local point.
		/// @param a point in local coordinates.
		/// @return the world velocity of a point.
		/// b2Vec2 GetLinearVelocityFromLocalPoint(const b2Vec2& localPoint) const;
		public function GetLinearVelocityFromLocalPoint(localPoint:V2):V2 {
			return GetLinearVelocityFromWorldPoint(GetWorldPoint(localPoint));
		}
		
		/// Get the linear damping of the body.
		/// float32 GetLinearDamping() const;
		public function GetLinearDamping():Number {
			return m_linearDamping;
		}
			
		/// Set the linear damping of the body.
		/// void SetLinearDamping(float32 linearDamping);
		public function SetLinearDamping(linearDamping:Number):void {
			m_linearDamping = linearDamping;
		}
		
		/// Get the angular damping of the body.
		/// float32 GetAngularDamping() const;
		public function GetAngularDamping():Number {
			return m_angularDamping;
		}
		
		/// Set the angular damping of the body.
		/// void SetAngularDamping(float32 angularDamping);
		public function SetAngularDamping(angularDamping:Number):void {
			m_angularDamping = angularDamping;
		}
		
		/// Should this body be treated like a bullet for continuous collision detection?
		/// void SetBullet(bool flag);
		public function SetBullet(flag:Boolean):void {
			if (flag) {
				m_flags |= e_bulletFlag;
			}
			else {
				m_flags &= ~e_bulletFlag;
			}
		}
		
		/// Is this body treated like a bullet for continuous collision detection?
		/// bool IsBullet() const;
		public function IsBullet():Boolean {
			return (m_flags & e_bulletFlag) == e_bulletFlag;
		}
		
		/// You can disable sleeping on this body.
		/// void AllowSleeping(bool flag);
		public function SetSleepingAllowed(flag:Boolean):void {
			if (flag) {
				m_flags |= e_autoSleepFlag;
			}
			else {
				m_flags &= ~e_autoSleepFlag;
				SetAwake(true);
			}
		}

		/// Is this body allowed to sleep
		/// bool IsAllowSleeping() const;
		public function IsSleepingAllowed():Boolean {
			return (m_flags & e_autoSleepFlag) == e_autoSleepFlag;
		}
		
		public function SetAwake(flag:Boolean):void {
			if(flag) {
				m_flags |= e_awakeFlag;
				m_sleepTime = 0;
			}
			else {
				m_flags &= ~e_awakeFlag;
				m_sleepTime = 0;
				m_linearVelocity.x = 0;
				m_linearVelocity.y = 0;
				m_force.x = 0;
				m_force.y = 0;
				m_torque = 0;
			}
		}
		
		/// Is this body sleeping (not simulating).
		/// bool IsSleeping() const;
		public function IsAwake():Boolean {
			return (m_flags & e_awakeFlag) == e_awakeFlag;
		}
		
		/// Set the active state of the body. An inactive body is not
		/// simulated and cannot be collided with or woken up.
		/// If you pass a flag of true, all fixtures will be added to the
		/// broad-phase.
		/// If you pass a flag of false, all fixtures will be removed from
		/// the broad-phase and all contacts will be destroyed.
		/// Fixtures and joints are otherwise unaffected. You may continue
		/// to create/destroy fixtures and joints on inactive bodies.
		/// Fixtures on an inactive body are implicitly inactive and will
		/// not participate in collisions, ray-casts, or queries.
		/// Joints connected to an inactive body are implicitly inactive.
		/// An inactive body is still owned by a b2World object and remains
		/// in the body list.
		/// void SetActive(bool flag);
		public function SetActive(flag:Boolean):void {
			lib.b2Body_SetActive(_ptr, flag);
		}
		
		/// Get the active state of the body.
		/// bool IsActive() const;
		public function IsActive():Boolean {
			return (m_flags & e_activeFlag) == e_activeFlag;
		}
		
		/// Set this body to have fixed rotation. This causes the mass
		/// to be reset.
		/// void SetFixedRotation(bool flag);
		public function SetFixedRotation(flag:Boolean):void {
			if(flag) {
				m_flags |= e_fixedRotationFlag;
			}
			else {
				m_flags &= ~e_fixedRotationFlag;
			}
			ResetMassData();
		}
	
		/// Does this body have fixed rotation?
		/// bool IsFixedRotation() const;
		public function IsFixedRotation():Boolean {
			return (m_flags & e_fixedRotationFlag) == e_fixedRotationFlag;
		}
		

	
		/// Get the list of all fixtures attached to this body.
		/// b2Fixture* GetFixtureList();
		public function GetFixtureList():b2Fixture {
			return m_fixtureList;
		}
	
		/// Get the list of all joints attached to this body.
		/// b2JointEdge* GetJointList();
		public function GetJointList():b2JointEdge {
			var p:int = mem._mr32(_ptr + 116);
			return p ? new b2JointEdge(p) : null;
		}
	
		/// Get the list of all contacts attached to this body.
		/// @warning this list changes during the time step and you may
		/// miss some collisions if you don't use b2ContactListener.
		/// b2ContactEdge* GetContactList();
		public function GetContactList():b2ContactEdge {
			var p:int = mem._mr32(_ptr + 120);
			return p ? new b2ContactEdge(p) : null;
		}
	
		/// Get the next body in the world's body list.
		/// b2Body* GetNext();
		public function GetNext():b2Body {
			return m_next;
		}
		
		/// Get the user data pointer that was provided in the body definition.
		/// void* GetUserData() const;
		public function GetUserData():* {
			return m_userData;
		}
	
		/// Set the user data. Use this to store your application specific data.
		/// void SetUserData(void* data);
		public function SetUserData(data:*):void {
			m_userData = data;
		}
	
		/// Get the parent world of this body.
		/// b2World* GetWorld();
		public function GetWorld():b2World {
			return m_world;
		}
		
		/* public function GetInertiaScale():Number {
			return m_inertiaScale;
		}
		
		public function SetInertiaScale(v:Number):void {
			m_I /= m_inertiaScale;
			m_inertiaScale = v;
			m_I *= m_inertiaScale;
		}*/
		
		public static const e_islandFlag:int = 0x0001;
		public static const e_awakeFlag:int = 0x0002;
		public static const e_autoSleepFlag:int = 0x0004;
		public static const e_bulletFlag:int = 0x0008;
		public static const e_fixedRotationFlag:int = 0x0010;
		public static const e_activeFlag:int = 0x0020;
		
		public static const b2_staticBody:int = 0;
		public static const b2_kinematicBody:int = 1;
		public static const b2_dynamicBody:int = 2;
		
		public var m_controllers:Dictionary = new Dictionary();
		
		public var m_userData:*;
		public var m_next:b2Body;
		public var m_prev:b2Body;
		public var m_world:b2World;
		public var m_fixtureList:b2Fixture;

		public var m_xf:b2Transform;
		public var m_sweep:b2Sweep;
		public var m_linearVelocity:b2Vec2;
		public var m_force:b2Vec2;
		
		public function get m_flags():int { return mem._mru16(_ptr + 4); }
		public function set m_flags(v:int):void { mem._mw16(_ptr + 4, v); }
		public function get m_type():int { return mem._mrs16(_ptr + 0); }
		public function set m_type(v:int):void { mem._mw16(_ptr + 0, v); }
		public function get m_islandIndex():int { return mem._mr32(_ptr + 8); }
		public function set m_islandIndex(v:int):void { mem._mw32(_ptr + 8, v); }
		public function get m_angularVelocity():Number { return mem._mrf(_ptr + 80); }
		public function set m_angularVelocity(v:Number):void { mem._mwf(_ptr + 80, v); }
		public function get m_torque():Number { return mem._mrf(_ptr + 92); }
		public function set m_torque(v:Number):void { mem._mwf(_ptr + 92, v); }
		public function get m_fixtureCount():int { return mem._mr32(_ptr + 112); }
		public function set m_fixtureCount(v:int):void { mem._mw32(_ptr + 112, v); }
		public function get m_mass():Number { return mem._mrf(_ptr + 124); }
		public function set m_mass(v:Number):void { mem._mwf(_ptr + 124, v); }
		public function get m_invMass():Number { return mem._mrf(_ptr + 128); }
		public function set m_invMass(v:Number):void { mem._mwf(_ptr + 128, v); }
		public function get m_I():Number { return mem._mrf(_ptr + 132); }
		public function set m_I(v:Number):void { mem._mwf(_ptr + 132, v); }
		public function get m_invI():Number { return mem._mrf(_ptr + 136); }
		public function set m_invI(v:Number):void { mem._mwf(_ptr + 136, v); }

		/* public function get m_linearDamping():Number { return mem._mrf(_ptr + 144); }
		public function set m_linearDamping(v:Number):void { mem._mwf(_ptr + 144, v); }
		public function get m_angularDamping():Number { return mem._mrf(_ptr + 148); }
		public function set m_angularDamping(v:Number):void { mem._mwf(_ptr + 148, v); }
		public function get m_sleepTime():Number { return mem._mrf(_ptr + 152); }
		public function set m_sleepTime(v:Number):void { mem._mwf(_ptr + 152, v); }
		public function get m_inertiaScale():Number { return mem._mrf(_ptr + 140); }
		public function set m_inertiaScale(v:Number):void { mem._mwf(_ptr + 140, v); } */

		public function get m_linearDamping():Number { return mem._mrf(_ptr + 140); }
		public function set m_linearDamping(v:Number):void { mem._mwf(_ptr + 140, v); }
		public function get m_angularDamping():Number { return mem._mrf(_ptr + 144); }
		public function set m_angularDamping(v:Number):void { mem._mwf(_ptr + 144, v); }
		public function get m_sleepTime():Number { return mem._mrf(_ptr + 148); }
		public function set m_sleepTime(v:Number):void { mem._mwf(_ptr + 148, v); }
	}
}