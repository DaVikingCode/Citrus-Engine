package Box2DAS.Dynamics.Contacts {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// The class manages contact between two shapes. A contact exists for each overlapping
	/// AABB in the broad-phase (except if filtered). Therefore a contact object may exist
	/// that has no contact points.
	public class b2Contact extends b2Base {
		
		public function b2Contact(p:int, fA:b2Fixture = null, fB:b2Fixture = null) {
			_ptr = p;
			m_manifold = new b2Manifold(_ptr + 64);
			
			/// Address of b2Fixture + userData offset -> deref to AS3 = AS3 b2Fixture.
			m_fixtureA = fA ? fA : deref(mem._mr32(mem._mr32(_ptr + 48) + 44)) as b2Fixture;
			m_fixtureB = fB ? fB : deref(mem._mr32(mem._mr32(_ptr + 52) + 44)) as b2Fixture;
		}
		
		// Used when crawling contact graph when forming islands.
		public static var e_islandFlag:int = 0x0001;

        // Set when the shapes are touching.
		public static var e_touchingFlag:int = 0x0002;

		// This contact can be disabled (by user)
		public static var e_enabledFlag:int = 0x0004;

		// This contact needs filtering because a fixture filter was changed.
		public static var e_filterFlag:int = 0x0008;

		// This bullet contact had a TOI event
		public static var e_bulletHitFlag:int = 0x0010;

		// This contact has a valid TOI in m_toi
		public static var e_toiFlag:int = 0x0020;
		
		/*
		/// This contact should not participate in Solve
		/// The contact equivalent of sensors
		public static var e_sensorFlag:int = 0x0001;

		/// Generate TOI events
		public static var e_continuousFlag:int = 0x0002;

		/// Used when crawling contact graph when forming islands.
		public static var e_islandFlag:int = 0x0004;
		
		/// Used in SolveTOI to indicate the cached toi value is still valid.
		public static var e_toiFlag:int = 0x0008;
        
        /// Set when the shapes are touching.
		public static var e_touchingFlag:int = 0x0010;
		
		/// Disabled (by user)
		public static var e_enabledFlag:int = 0x0020;
		
		/// This contact needs filtering because a fixture filter was changed.
		public static var e_filterFlag:int = 0x0040; */
		
		/// Get the contact manifold. Do not set the point count to zero. Instead
		/// call Disable.
		/// b2Manifold* GetManifold();
		public function GetManifold():b2Manifold {
			return m_manifold;
		}
	
		/// Get the world manifold.
		/// void GetWorldManifold(b2WorldManifold* worldManifold) const;
		public function GetWorldManifold(worldManifold:b2WorldManifold):void {
			var bodyA:b2Body = m_fixtureA.GetBody();
			var bodyB:b2Body= m_fixtureB.GetBody();
			var shapeA:b2Shape = m_fixtureA.GetShape();
			var shapeB:b2Shape = m_fixtureB.GetShape();
			worldManifold.Initialize(m_manifold, bodyA.GetTransform(), shapeA.m_radius, bodyB.GetTransform(), shapeB.m_radius);
		}
		
		/// Is this contact solid? Returns false if the shapes are separate,
		/// sensors, or the contact has been disabled.
		/// @return true if this contact should generate a response.
		/// bool IsSolid() const;
		public function IsSolid():Boolean {
			return IsTouching() //&& !IsSensor();
		}
		
		/// Is this contact touching.
		/// bool IsTouching() const;
		public function IsTouching():Boolean {
			return (m_flags & e_touchingFlag) != 0;
		}
		
		/// Does this contact generate TOI events for continuous simulation?
		/// bool IsContinuous() const;
		/* public function IsContinuous():Boolean {
			return (m_flags & e_continuousFlag) != 0;
		}*/
		
		/// Is this contact a sensor?
		/// bool IsSensor() const;
		/*public function IsSensor():Boolean {
			return (m_flags & e_sensorFlag) == e_sensorFlag;
		}*/
		
		/// Change this to be a sensor or non-sensor contact.
		/// void SetAsSensor(bool sensor);
		/// AS3 ONLY: the value passed to here is cached, so it can be easily determined later
		/// if the contact was explicitly disabled via this method.
		/*public function SetSensor(sensor:Boolean):void {
			_setSensor = sensor;
			if(sensor) {
				m_flags |= e_sensorFlag;
			}
			else {
				m_flags &= ~e_sensorFlag;
			}
		}
		public var _setSensor:Boolean = false;*/
	
		/// Disable this contact. This can be used inside the pre-solve
		/// contact listener. The contact is only disabled for the current
		/// time step (or sub-step in continuous collisions).
		/// void Disable();
		public function Disable():void {
			m_flags &= ~e_enabledFlag;
		}
		
		/// Enable/disable this contact. This can be used inside the pre-solve
		/// contact listener. The contact is only disabled for the current
		/// time step (or sub-step in continuous collisions).
		/// void SetEnabled(bool flag);
		public function SetEnabled(flag:Boolean):void {
			if(flag) {
				m_flags |= e_enabledFlag;
			}
			else {
				m_flags &= ~e_enabledFlag;
			}
		}

		/// Has this contact been disabled?
		/// bool IsEnabled() const;
		public function IsEnabled():Boolean {
			return (m_flags & e_enabledFlag) == e_enabledFlag;
		}		
		
		/// Get the next contact in the world's contact list.
		/// b2Contact* GetNext();
		public function GetNext():b2Contact {
			return m_next ? new b2Contact(m_next) : null;
		}
		
		/// Get the first fixture in this contact.
		/// b2Fixture* GetFixtureA();
		public function GetFixtureA():b2Fixture {
			return m_fixtureA;
		}
	
		/// Get the second fixture in this contact.
		/// b2Fixture* GetFixtureB();
		public function GetFixtureB():b2Fixture {
			return m_fixtureB;
		}

		/// Flag this contact for filtering. Filtering will occur the next time step.
		/// void FlagForFiltering();
		public function FlagForFiltering():void {
			m_flags |= e_filterFlag;
		}
		
		public function Update():void {
			lib.b2Contact_Update(_ptr);
		}
		
		public function Evaluate():void {
			lib.b2Contact_Evaluate(_ptr);
		}
		
		public var m_fixtureA:b2Fixture;
		public var m_fixtureB:b2Fixture;
		public var m_manifold:b2Manifold;
		
		public function get m_flags():int { return mem._mr32(_ptr + 4); }
		public function set m_flags(v:int):void { mem._mw32(_ptr + 4, v); }
		/*public function get m_toiCount():Number { return mem._mrf(_ptr + 120); }
		public function set m_toiCount(v:Number):void { mem._mwf(_ptr + 120, v); }
		public function get frictionDisabled():Boolean { return mem._mru8(_ptr + 124) == 1; }
		public function set frictionDisabled(v:Boolean):void { mem._mw8(_ptr + 124, v ? 1 : 0); }
		public function get m_next():int { return mem._mr32(_ptr + 12); }
		public function set m_next(v:int):void { mem._mw32(_ptr + 12, v); }
		public function get m_prev():int { return mem._mr32(_ptr + 8); }
		public function set m_prev(v:int):void { mem._mw32(_ptr + 8, v); }*/
		
		public function get m_indexA():int { return mem._mr32(_ptr + 56); }
		public function set m_indexA(v:int):void { mem._mw32(_ptr + 56, v); }
		public function get m_indexB():int { return mem._mr32(_ptr + 60); }
		public function set m_indexB(v:int):void { mem._mw32(_ptr + 60, v); }
		public function get m_toiCount():int { return mem._mr32(_ptr + 136); }
		public function set m_toiCount(v:int):void { mem._mw32(_ptr + 136, v); }
		public function get m_toi():Number { return mem._mrf(_ptr + 140); }
		public function set m_toi(v:Number):void { mem._mwf(_ptr + 140, v); }
		public function get frictionDisabled():Boolean { return mem._mru8(_ptr + 144) == 1; }
		public function set frictionDisabled(v:Boolean):void { mem._mw8(_ptr + 144, v ? 1 : 0); }
		public function get m_next():int { return mem._mr32(_ptr + 12); }
		public function set m_next(v:int):void { mem._mw32(_ptr + 12, v); }
		public function get m_prev():int { return mem._mr32(_ptr + 8); }
		public function set m_prev(v:int):void { mem._mw32(_ptr + 8, v); }
	}
}