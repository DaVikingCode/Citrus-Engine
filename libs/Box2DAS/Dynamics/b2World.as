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
	import flash.events.*;
	import flash.utils.*;
	import flash.display.*;
	import flash.utils.*;
	
	/// The world class manages all physics entities, dynamic simulation,
	/// and asynchronous queries. The world also contains efficient memory
	/// management facilities.
	public class b2World extends b2EventDispatcher {
		
		public static var defaultContactListener:Class = b2ContactListener;
		public static var defaultDestructionListener:Class = b2DestructionListener;		
		
		public static const e_newFixture:int = 0x0001;
		public static const e_locked:int = 0x0002;
		public static const e_clearForces:int	= 0x0004;
		
		/// Construct a world object.
		/// @param gravity the world gravity vector.
		/// @param doSleep improve performance by not simulating inactive bodies.
		/// b2World(const b2Vec2& gravity, bool doSleep);
		public function b2World(g_or_p:*, s:Boolean = true, d:IEventDispatcher = null) {
			// b2World is usually the first thing to be created - make sure the system is initialized.
			b2Base.initialize();
			super(d);
			var g:V2 = g_or_p as V2;
			if(g) {
				_ptr = lib.b2World_new(this, g.x, g.y, s);	
			}
			else {
				_ptr = g_or_p as int;
			}
			m_gravity = new b2Vec2(_ptr + 102968);
			var bd:b2BodyDef = new b2BodyDef();
			m_groundBody = new b2Body(this, bd);
			bd.destroy();
			m_contactManager = new b2ContactManager(_ptr + 102872);
			SetContactListener(new defaultContactListener() as b2ContactListener);
			SetDestructionListener(new defaultDestructionListener() as b2DestructionListener);
			addEventListener(StepEvent.STEP, HandleStep);			
		}
		
		/// Destruct the world. All physics entities are destroyed and all heap memory is released.
		/// ~b2World();
		public override function destroy():void {
			lib.b2World_delete(_ptr);
			removeEventListener(StepEvent.STEP, HandleStep);
			super.destroy();
		}
		
		/// Query the world for all fixtures that potentially overlap the
		/// provided AABB.
		/// @param callback a user implemented callback class.
		/// @param aabb the query box.
		/// void QueryAABB(b2QueryCallback* callback, const b2AABB& aabb);
		///
		/// AS3 Callback Signature:
		/// function(fixture:b2Fixture):Boolean;
		///
		/// Return true to continue, false to stop.
		///
		public function QueryAABB(callback:Function, aabb:AABB):void {
			lib.b2World_QueryAABB(_ptr, callback, 
				aabb.lowerBound.x, aabb.lowerBound.y, 
				aabb.upperBound.x, aabb.upperBound.y);
		}
		
		/// Query a point.
		///
		/// AS3 Callback Signature:
		/// function(fixture:b2Fixture):Boolean;
		///
		/// Return true to continue, false to stop.
		///
		public function QueryPoint(callback:Function, p:V2):void {
			QueryAABB(function(f:b2Fixture):Boolean {
				if(f.m_shape.TestPoint(f.m_body.GetTransform(), p)) {
					return callback(f);
				}
				return true;
			}, AABB.FromV2(p));
		}
	
		/// Ray-cast the world for all fixtures in the path of the ray. Your callback
		/// controls whether you get the closest point, any point, or n-points.
		/// The ray-cast ignores shapes that contain the starting point.
		/// @param callback a user implemented callback class.
		/// @param point1 the ray starting point
		/// @param point2 the ray ending point
		/// void RayCast(b2RayCastCallback* callback, const b2Vec2& point1, const b2Vec2& point2);
		///
		/// AS3 Callback Signature:
		/// function(fixture:b2Fixture, point:V2, normal:V2, fraction:Number):Number;
		///
		/// WARNING: If your callback has an error, it will NOT be reported while debugging. It will
		/// be blocked by Alchemy.
		///
		public function RayCast(callback:Function, point1:V2, point2:V2):void {
			lib.b2World_RayCast(_ptr, function(f:b2Fixture, px:Number, py:Number, nx:Number, ny:Number, fr:Number):Number {
				var frac:Number = callback(f, new V2(px, py), new V2(nx, ny), fr); 
				return frac;
			}, point1.x, point1.y, point2.x, point2.y);
		}
	
		/// Create a rigid body given a definition. No reference to the definition
		/// is retained.
		/// @warning This function is locked during callbacks.
		/// b2Body* CreateBody(const b2BodyDef* def);
		public function CreateBody(def:b2BodyDef = null):b2Body {
			return new b2Body(this, def);
		}
	
		/// Destroy a rigid body given a definition. No reference to the definition
		/// is retained. This function is locked during callbacks.
		/// @warning This automatically deletes all associated shapes and joints.
		/// @warning This function is locked during callbacks.
		/// void DestroyBody(b2Body* body);
		public function DestroyBody(body:b2Body):void {
			body.destroy();
		}
		
		/// Create a joint to constrain bodies together. No reference to the definition
		/// is retained. This may cause the connected bodies to cease colliding.
		/// @warning This function is locked during callbacks.
		/// b2Joint* CreateJoint(const b2JointDef* def);
		public function CreateJoint(def:b2JointDef, ed:IEventDispatcher = null):b2Joint {
			return def.create(this, ed);
		}
		
		/// Destroy a joint. This may cause the connected bodies to begin colliding.
		/// @warning This function is locked during callbacks.
		/// void DestroyJoint(b2Joint* joint);
		public function DestroyJoint(joint:b2Joint):void {
			joint.destroy();
		}
	
		/// Take a time step. This performs collision detection, integration,
		/// and constraint solution.
		/// @param timeStep the amount of time to simulate, this should not vary.
		/// @param velocityIterations for the velocity constraint solver.
		/// @param positionIterations for the position constraint solver.		
		/// @param resetForces forces will be reset at the end of the step (normally true).
		/// void Step(float32 timeStep, int32 velocityIterations, int32 positionIterations);
		public function Step(timeStep:Number, velocityIterations:int, positionIterations:int):void {
			stepTime++; //= getTimer();
			var se:StepEvent = new StepEvent(timeStep, velocityIterations, positionIterations, stepTime);
			dispatchEvent(se);
		}
		
		public function HandleStep(se:StepEvent):void {
			lib.b2World_Step(_ptr, se.timeStep, se.velocityIterations, se.positionIterations);
		}
			
		/// Get the world body list. With the returned body, use b2Body::GetNext to get
		/// the next body in the world list. A NULL body indicates the end of the list.
		/// @return the head of the world body list.
		/// b2Body* GetBodyList();
		public function GetBodyList():b2Body {
			return m_bodyList;
		}
	
		/// Get the world joint list. With the returned joint, use b2Joint::GetNext to get
		/// the next joint in the world list. A NULL joint indicates the end of the list.
		/// @return the head of the world joint list.
		/// b2Joint* GetJointList();
		public function GetJointList():b2Joint {
			return m_jointList;
		}
	
		/// Get the world contact list. With the returned contact, use b2Contact::GetNext to get
		/// the next contact in the world list. A NULL contact indicates the end of the list.
		/// @return the head of the world contact list.
		/// @warning contacts are 
		/// b2Contact* GetContactList();
		public function GetContactList():b2Contact {
			return m_contactManager.m_contactList;
		}
	
		/// Enable/disable warm starting. For testing.
		/// void SetWarmStarting(bool flag) { m_warmStarting = flag; }
		public function SetWarmStarting(flag:Boolean):void {
			m_warmStarting = flag;
		}
		
		/// Enable/disable continuous physics. For testing.
		/// void SetContinuousPhysics(bool flag) { m_continuousPhysics = flag; }
		public function SetContinuousPhysics(flag:Boolean):void {
			m_continuousPhysics = flag;
		}
	
		/// Get the number of broad-phase proxies.
		/// int32 GetProxyCount() const;
		public function GetProxyCount():int {
			return m_contactManager.m_broadPhase.GetProxyCount();
		}
	
		/// Get the number of bodies.
		/// int32 GetBodyCount() const;
		public function GetBodyCount():int {
			return m_bodyCount;
		}
	
		/// Get the number of joints.
		/// int32 GetJointCount() const;
		public function GetJointCount():int {
			return m_jointCount;
		}
	
		/// Get the number of contacts (each may have 0 or more contact points).
		/// int32 GetContactCount() const;
		public function GetContactCount():int {
			return m_contactManager.m_contactCount;
		}
	
		/// Change the global gravity vector.
		/// void SetGravity(const b2Vec2& gravity);
		public function SetGravity(gravity:V2):void {
			m_gravity.v2 = gravity;
		}
		
		/// Get the global gravity vector.
		/// b2Vec2 GetGravity() const;
		public function GetGravity():V2 {
			return m_gravity.v2;
		}
	
		/// Is the world locked (in the middle of a time step).
		/// bool IsLocked() const;
		public function IsLocked():Boolean {
			return (m_flags & e_locked) == e_locked;
		}
		
		/// Add a controller to the world.
		/// b2Controller* AddController(b2Controller* def);
		public function AddController(c:b2Controller):void {
			c.world = this;
			m_controllers[c] = true;
			addEventListener(StepEvent.STEP, c.Step, false, c.priority);
		}
	
		/// Removes a controller from the world.
		/// void RemoveController(b2Controller* controller);
		public function RemoveController(c:b2Controller):void {
			c.world = null;
			delete m_controllers[c];
			removeEventListener(StepEvent.STEP, c.Step);
		}
		
		/// Register a destruction listener.
		/// void SetDestructionListener(b2DestructionListener* listener);
		public function SetDestructionListener(listener:b2DestructionListener):void {
			m_destructionListener = listener;
		}
		
		/// Register a contact filter to provide specific control over collision.
		/// Otherwise the default filter is used (b2_defaultFilter).
		/// void SetContactFilter(b2ContactFilter* filter);
		/// WILL NOT BE IMPLEMENTED.
		/// AS3 Filtering would be waaaay slow - to many Alchemy to AS3 calls.
		
		/// Register a contact event listener
		/// void SetContactListener(b2ContactListener* listener);		
		public function SetContactListener(listener:b2ContactListener):void {
			m_contactListener = listener;
		}
		
		/// Set flag to control automatic clearing of forces after each time step.
		/// void SetAutoClearForces(bool flag);		
		public function SetAutoClearForces(flag:Boolean):void {
			if(flag) {
				m_flags |= e_clearForces;
			}
			else {
				m_flags &= ~e_clearForces;
			}
		}
		
		/// Get the flag that controls automatic clearing of forces after each time step.
		/// bool GetAutoClearForces() const;
		public function GetAutoClearForces():Boolean {
			return (m_flags & e_clearForces) == e_clearForces;
		}
		
		/// Call this after you are done with time steps to clear the forces. You normally
		/// call this after each call to Step, unless you are performing sub-steps. By default,
		/// forces will be automatically cleared, so you don't need to call this function.
		/// @see SetAutoClearForces
		/// void ClearForces();
		public function ClearForces():void {
			for(var body:b2Body = m_bodyList; body; body = body.GetNext()) {
				body.m_force.x = 0;
				body.m_force.y = 0;
				body.m_torque = 0;
			}
		}
		

	
		
		/// Incremented each step. This can be used to check
		/// if buffered / cached world data is outdated.
		public var stepTime:int = 0;

		
		public var m_bodyList:b2Body;
		public var m_jointList:b2Joint;
		
		public var m_controllers:Dictionary = new Dictionary();
		
		public var m_destructionListener:b2DestructionListener;
		public var m_contactListener:b2ContactListener;
		
		public function get m_flags():int { return mem._mr32(_ptr + 102868); }
		public function set m_flags(v:int):void { mem._mw32(_ptr + 102868, v); }
		public function get m_bodyCount():int { return mem._mr32(_ptr + 102960); }
		public function set m_bodyCount(v:int):void { mem._mw32(_ptr + 102960, v); }
		public function get m_jointCount():int { return mem._mr32(_ptr + 102964); }
		public function set m_jointCount(v:int):void { mem._mw32(_ptr + 102964, v); }
		public var m_gravity:b2Vec2; // 
		public function get m_allowSleep():Boolean { return mem._mru8(_ptr + 102976) == 1; }
		public function set m_allowSleep(v:Boolean):void { mem._mw8(_ptr + 102976, v ? 1 : 0); }
		public var m_groundBody:b2Body; // 
		public var m_contactManager:b2ContactManager; // 
		public function get m_warmStarting():Boolean { return mem._mru8(_ptr + 102992) == 1; }
		public function set m_warmStarting(v:Boolean):void { mem._mw8(_ptr + 102992, v ? 1 : 0); }
		public function get m_continuousPhysics():Boolean { return mem._mru8(_ptr + 102993) == 1; }
		public function set m_continuousPhysics(v:Boolean):void { mem._mw8(_ptr + 102993, v ? 1 : 0); }


/// b2ContactListener:
		
		/// Called when two fixtures begin to touch.
		public function BeginContact(c:int, a:b2Fixture, b:b2Fixture):void { 
			if(m_contactListener) {
				m_contactListener.BeginContact(new b2Contact(c, a, b));
			}
		}
		
		/// Called when two fixtures cease to touch.
		public function EndContact(c:int, a:b2Fixture, b:b2Fixture):void { 
			if(m_contactListener) {
				m_contactListener.EndContact(new b2Contact(c, a, b));
			}
		}
		
		/// This is called after a contact is updated. This allows you to inspect a
		/// contact before it goes to the solver. If you are careful, you can modify the
		/// contact manifold (e.g. disable contact).
		/// A copy of the old manifold is provided so that you can detect changes.
		/// Note: this is called only for awake bodies.
		/// Note: this is called even when the number of contact points is zero.
		/// Note: this is not called for sensors.
		/// Note: if you set the number of contact points to zero, you will not
		/// get an EndContact callback. However, you may get a BeginContact callback
		/// the next step.
		public function PreSolve(c:int, a:b2Fixture, b:b2Fixture, o:int):void { 
			if(m_contactListener) {
				m_contactListener.PreSolve(new b2Contact(c, a, b), new b2Manifold(o));
			}		
		}
		
		/// This lets you inspect a contact after the solver is finished. This is useful
		/// for inspecting impulses.
		/// Note: the contact manifold does not include time of impact impulses, which can be
		/// arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
		/// in a separate data structure.
		/// Note: this is only called for contacts that are touching, solid, and awake.
		public function PostSolve(c:int, a:b2Fixture, b:b2Fixture, i:int):void { 
			if(m_contactListener) {
				m_contactListener.PostSolve(new b2Contact(c, a, b), new b2ContactImpulse(i));
			}		
		}
		
		
/// b2DestructionListener:
		
		/// Called when any joint is about to be destroyed due
		/// to the destruction of one of its attached bodies.
		public function SayGoodbyeJoint(j:b2Joint):void {
			if(m_destructionListener) {
				m_destructionListener.SayGoodbyeJoint(j);
			}
		}
		
		/// Called when any fixture is about to be destroyed due
		/// to the destruction of its parent body.
		public function SayGoodbyeFixture(f:b2Fixture):void {
			if(m_destructionListener) {
				m_destructionListener.SayGoodbyeFixture(f);
			}		
		}
	}
}