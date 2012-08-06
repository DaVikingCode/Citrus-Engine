package Box2DAS.Dynamics {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.utils.*;
	import flash.display.*;
	import flash.events.*;
	
	/// A fixture is used to attach a shape to a body for collision detection. A fixture
	/// inherits its transform from its parent. Fixtures hold additional non-geometric data
	/// such as friction, collision filters, etc.
	/// Fixtures are created via b2Body::CreateFixture.
	/// @warning you cannot reuse fixtures.
	public class b2Fixture extends b2EventDispatcher {
		
		public function b2Fixture(b:b2Body, d:b2FixtureDef = null, ed:IEventDispatcher = null) {
			super(ed);
			d ||= b2Def.fixture;
			_ptr = lib.b2Body_CreateFixture(this, b._ptr, d._ptr);
			//m_aabb = new b2AABB(_ptr + 4);
			//m_filter = new b2Filter(_ptr + 48);
			m_filter = new b2Filter(_ptr + 36);
			m_body = b;
			var shapeClass:Class = getDefinitionByName(getQualifiedClassName(d._shape)) as Class;
			//m_shape = new shapeClass(mem._mr32(_ptr + 32));
			m_shape = new shapeClass(mem._mr32(_ptr + 16));
			m_userData = d.userData;
			m_next = b.m_fixtureList;
			b.m_fixtureList = this;
		}
		
		/// Forwards the Draw command to the shape.
		public function Draw(g:Graphics, xf:XF, scale:Number = 1):void {
			m_shape.Draw(g, xf, scale);
		}
		
		public override function destroy():void {
			lib.b2Body_DestroyFixture(m_body._ptr, _ptr);
			if(m_body.m_fixtureList == this) {
				m_body.m_fixtureList = m_next;
			}
			else {
				var prev:b2Fixture = m_body.m_fixtureList;
				while(prev.m_next != this) {
					prev = prev.m_next;
				}
				prev.m_next = m_next;
			}
			super.destroy();
		}
		
		/// Get the type of the child shape. You can use this to down cast to the concrete shape.
		/// @return the shape type.
		/// b2Shape::Type GetType() const;
		public function GetType():int {
			return m_shape.GetType();
		}
	
		/// Get the child shape. You can modify the child shape, however you should not change the
		/// number of vertices because this will crash some collision caching mechanisms.
		/// const b2Shape* GetShape() const;
		/// b2Shape* GetShape();
		public function GetShape():b2Shape {
			return m_shape;
		}
	
		/// Is this fixture a sensor (non-solid)?
		/// @return the true if the shape is a sensor.
		/// bool IsSensor() const;
		public function IsSensor():Boolean {
			return m_isSensor;
		}
	
		/// Set if this fixture is a sensor.
		/// void SetSensor(bool sensor);
		public function SetSensor(sensor:Boolean):void {
			/*if((m_isSensor && sensor) || (!m_isSensor && !sensor)) {
				return;
			}*/
			m_isSensor = sensor;
			/* for(var e:b2ContactEdge = m_body.GetContactList(); e; e = e.next) {
				var c:b2Contact = e.contact;
				if(c.m_fixtureA == this || c.m_fixtureB == this) {
					c.SetSensor(c.m_fixtureA.m_isSensor || c.m_fixtureB.m_isSensor);
				}
			}*/
		}
	
		/// Set the contact filtering data. This is an expensive operation and should
		/// not be called frequently. This will not update contacts until the next time
		/// step when either parent body is awake.
		/// void SetFilterData(const b2Filter& filter);
		public function SetFilterData(filter:Object, refilter:Boolean = true):void {
			m_filter.filter = filter;
			if(refilter) {
				Refilter();
			}
		}


		public function Refilter():void {
			if(!m_body) {
				return;
			}
			// Flag associated contacts for filtering.
			var edge:b2ContactEdge = m_body.GetContactList();
			while (edge) {
				var contact:b2Contact = edge.contact;
				var fixtureA:b2Fixture = contact.GetFixtureA();
				var fixtureB:b2Fixture = contact.GetFixtureB();
				if(fixtureA == this || fixtureB == this) {
					contact.FlagForFiltering();
				}
				edge = edge.next;
			}		
		}
	
		/// Get the contact filtering data.
		/// const b2Filter& GetFilterData() const;
		public function GetFilterData():Object {
			return m_filter.filter;
		}
		
		/// Get the parent body of this fixture. This is NULL if the fixture is not attached.
		/// @return the parent body.
		/// b2Body* GetBody();
		public function GetBody():b2Body {
			return m_body;
		}
	
		/// Get the next fixture in the parent body's fixture list.
		/// @return the next shape.
		/// b2Fixture* GetNext();
		public function GetNext():b2Fixture {
			return m_next;
		}
	
		/// Get the user data that was assigned in the fixture definition. Use this to
		/// store your application specific data.
		/// void* GetUserData();
		public function GetUserData():* {
			return m_userData;
		}
	
		/// Set the user data. Use this to store your application specific data.
		/// void SetUserData(void* data);
		public function SetUserData(data:*):void {
			m_userData = data;
		}
	
		/// Test a point for containment in this fixture. This only works for convex shapes.
		/// @param xf the shape world transform.
		/// @param p a point in world coordinates.
		/// bool TestPoint(const b2Vec2& p) const;
		public function TestPoint(p:V2):Boolean {
			return m_shape.TestPoint(m_body.GetTransform(), p);
		}
	
		/// Cast a ray against this shape.
		/// @param output the ray-cast results.
		/// @param input the ray-cast input parameters.
		/// void RayCast(b2RayCastOutput* output, const b2RayCastInput& input) const;
		public function RayCast():void {
			/// NOT IMPLEMENTED.
		}
		
		/// Get the mass data for this fixture. The mass data is based on the density and
		/// the shape. The rotational inertia is about the shape's origin.
		/// const b2MassData& GetMassData() const;
		public function GetMassData():b2MassData {
			/// NOT IMPLEMENTED.
			return null;
		}
		
		/// Set the density of this fixture. This will _not_ automatically adjust the mass
		/// of the body. You must call b2Body::ResetMassData to update the body's mass.
		/// void SetDensity(float32 density);
		public function SetDensity(v:Number):void {
			m_density = v;
		}
	
		/// Get the density of this fixture.
		/// float32 GetDensity() const;
		public function GetDensity():Number {
			return m_density;
		}
		
		/// Get the coefficient of friction.
		/// float32 GetFriction() const;
		public function GetFriction():Number {
			return m_friction;
		}
	
		/// Set the coefficient of friction.
		/// void SetFriction(float32 friction);
		public function SetFriction(friction:Number):void {
			m_friction = friction;
		}
	
		/// Get the coefficient of restitution.
		/// float32 GetRestitution() const;
		public function GetRestitution():Number {
			return m_restitution;
		}
	
		/// Set the coefficient of restitution.
		/// void SetRestitution(float32 restitution);
		public function SetRestitution(restitution:Number):void {
			m_restitution = restitution;
		}
		
		/// Get the distance to the other fixture.
		public function GetDistance(f:b2Fixture):V2 {
			var din:b2DistanceInput = b2Def.distanceInput;
			var dout:b2DistanceOutput = b2Def.distanceOutput;
			din.proxyA.Set(m_shape);
			din.proxyB.Set(f.m_shape);
			din.transformA.xf = m_body.GetTransform();
			din.transformB.xf = f.m_body.GetTransform();
			din.useRadii = true;
			b2Def.simplexCache.count = 0;
			b2Distance();
			return dout.pointB.v2.subtract(dout.pointA.v2);
		}
				
		public var m_userData:*;
		public var m_body:b2Body;
		public var m_shape:b2Shape;
		public var m_next:b2Fixture;
		public var m_bubbleContacts:Boolean = true;
		public function get m_reportBeginContact():Boolean { return mem._mru8(_ptr + 0) == 1; }
		public function set m_reportBeginContact(v:Boolean):void { mem._mw8(_ptr + 0, v ? 1 : 0); }
		public function get m_reportEndContact():Boolean { return mem._mru8(_ptr + 1) == 1; }
		public function set m_reportEndContact(v:Boolean):void { mem._mw8(_ptr + 1, v ? 1 : 0); }
		public function get m_reportPreSolve():Boolean { return mem._mru8(_ptr + 2) == 1; }
		public function set m_reportPreSolve(v:Boolean):void { mem._mw8(_ptr + 2, v ? 1 : 0); }
		public function get m_reportPostSolve():Boolean { return mem._mru8(_ptr + 3) == 1; }
		public function set m_reportPostSolve(v:Boolean):void { mem._mw8(_ptr + 3, v ? 1 : 0); }		
		//public var m_aabb:b2AABB;
		
		/* public function get m_friction():Number { return mem._mrf(_ptr + 36); }
		public function set m_friction(v:Number):void { mem._mwf(_ptr + 36, v); }
		public function get m_restitution():Number { return mem._mrf(_ptr + 40); }
		public function set m_restitution(v:Number):void { mem._mwf(_ptr + 40, v); } */
		
		public function get m_friction():Number { return mem._mrf(_ptr + 20); }
		public function set m_friction(v:Number):void { mem._mwf(_ptr + 20, v); }
		public function get m_restitution():Number { return mem._mrf(_ptr + 24); }
		public function set m_restitution(v:Number):void { mem._mwf(_ptr + 24, v); }
		
		/* public function get m_proxyId():int { return mem._mr32(_ptr + 44); }
		public function set m_proxyId(v:int):void { mem._mw32(_ptr + 44, v); } */
		
		// proxyId & AABB have been moved to a pointer to a struct. Need to read
		// the pointer to get at the struct.
		public function get m_proxyId():int { return mem._mr32(mem._mr32(_ptr + 28) + 24); }
		public function set m_proxyId(v:int):void { mem._mw32(mem._mr32(_ptr + 28) + 24, v); }
		public function get m_aabb():b2AABB { return new b2AABB(mem._mr32(_ptr + 28)); }
		
		public var m_filter:b2Filter;
		
		/* public function get m_isSensor():Boolean { return mem._mru8(_ptr + 54) == 1; }
		public function set m_isSensor(v:Boolean):void { mem._mw8(_ptr + 54, v ? 1 : 0); }
		public function get m_density():Number { return mem._mrf(_ptr + 20); }
		public function set m_density(v:Number):void { mem._mwf(_ptr + 20, v); } 
		public function get m_conveyorBeltSpeed():Number { return mem._mrf(_ptr + 60); }
		public function set m_conveyorBeltSpeed(v:Number):void { mem._mwf(_ptr + 60, v); } */
		
		public function get m_isSensor():Boolean { return mem._mru8(_ptr + 42) == 1; }
		public function set m_isSensor(v:Boolean):void { mem._mw8(_ptr + 42, v ? 1 : 0); }
		public function get m_density():Number { return mem._mrf(_ptr + 4); }
		public function set m_density(v:Number):void { mem._mwf(_ptr + 4, v); }
		public function get m_conveyorBeltSpeed():Number { return mem._mrf(_ptr + 48); }
		public function set m_conveyorBeltSpeed(v:Number):void { mem._mwf(_ptr + 48, v); }		
			
	}
}