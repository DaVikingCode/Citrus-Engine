package Box2DAS.Dynamics.Joints {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.events.*;
	
	/// The base joint class. Joints are used to constraint two bodies together in
	/// various fashions. Some joints also feature limits and motors.
	public class b2Joint extends b2EventDispatcher {
		
		public function b2Joint(w:b2World, d:b2JointDef, ed:IEventDispatcher = null) {
			super(ed);
			m_bodyA = d._bodyA;
			m_bodyB = d._bodyB;
			_ptr = lib.b2World_CreateJoint(this, w._ptr, d._ptr);
			m_userData = d.userData;
			m_next = w.m_jointList;
			if(m_next) {
				m_next.m_prev = this;
			}
			w.m_jointList = this;
			m_world = w;
		}
		
		public override function destroy():void {
			lib.b2World_DestroyJoint(m_world._ptr, _ptr);
			if(m_prev) {
				m_prev.m_next = m_next;
			}
			else {
				m_world.m_jointList = m_next;
			}
			if(m_next) {
				m_next.m_prev = m_prev;
			}
			super.destroy();
		}
		
		/// Get the type of the concrete joint.
		/// b2JointType GetType() const;
		public function GetType():int {
			return m_type;
		}
	
		/// Get the first body attached to this joint.
		/// b2Body* GetBodyA();
		public function GetBodyA():b2Body {
			return m_bodyA;
		}
	
		/// Get the second body attached to this joint.
		/// b2Body* GetBodyB();
		public function GetBodyB():b2Body {
			return m_bodyB;
		}
	
		/// Get the anchor point on bodyA in world coordinates.
		/// virtual b2Vec2 GetAnchorA() const = 0;
		public function GetAnchorA():V2 {
			return null;
		}
	
		/// Get the anchor point on bodyB in world coordinates.
		/// virtual b2Vec2 GetAnchorB() const = 0;
		public function GetAnchorB():V2 {
			return null;
		}
		
		/// Get the reaction force on bodyB at the joint anchor.
		/// virtual b2Vec2 GetReactionForce(float32 inv_dt) const = 0;
		public function GetReactionForce(inv_dt:Number):V2 {
			return null;
		}
		
		/// Get the reaction torque on bodyB.
		/// virtual float32 GetReactionTorque(float32 inv_dt) const = 0;
		public function GetReactionTorque(inv_dt:Number):Number {
			return 0;
		}
	
		/// Get the next joint the world joint list.
		/// b2Joint* GetNext();
		public function GetNext():b2Joint {
			return m_next;
		}
	
		/// Get the user data pointer.
		/// void* GetUserData() const;
		public function GetUserData():* {
			return m_userData;
		}
		
		/// Set the user data pointer.
		/// void SetUserData(void* data);
		public function SetUserData(data:*):void {
			m_userData = data;
		}
		
		/// Wake both joint bodies.
		public function WakeUp():void {
			m_bodyA.SetAwake(true);
			m_bodyB.SetAwake(true);
		}
		
		
		
		/// Common joint functionality. These are in the base class so that a cast is not required to
		/// call them. Warning though: they are not implemented by all joints!
		public function IsLimitEnabled():Boolean { return false; }
		public function EnableLimit(flag:Boolean):void {}		
		public function GetLowerLimit():Number { return 0; }
		public function GetUpperLimit():Number { return 0; }
		public function SetLimits(lower:Number, upper:Number):void {}
		public function SetLowerLimit(l:Number):void {}
		public function SetUpperLimit(l:Number):void {}
		public function IsMotorEnabled():Boolean { return false; }
		public function EnableMotor(v:Boolean):void {}
		public function SetMotorSpeed(v:Number):void {}
		public function GetMotorSpeed():Number { return 0; }
		
		public function SetMaxMotorForce(v:Number):void {}
		public function GetMaxMotorForce():Number { return 0; }
		public function SetMaxMotorTorque(v:Number):void {}
		public function GetMaxMotorTorque():Number { return 0; }		
		
		/// Only used by mouse and distance joints.
		public function SetFrequency(v:Number):void {}
		public function GetFrequency():Number { return 0; }
		public function SetDampingRatio(v:Number):void {}
		public function GetDampingRatio():Number { return 0; }
		
		
		
		
		
		
		public static const e_unknownJoint:int = 0;
		public static const e_revoluteJoint:int = 1;
		public static const e_prismaticJoint:int = 2;
		public static const e_distanceJoint:int = 3;
		public static const e_pulleyJoint:int = 4;
		public static const e_mouseJoint:int = 5;
		public static const e_gearJoint:int = 6;
		public static const e_lineJoint:int = 7;
		public static const e_fixedJoint:int = 8;
		public static const e_ropeJoint:int = 9;
		
		public static const e_inactiveLimit:int = 0;
		public static const e_atLowerLimit:int = 1;
		public static const e_atUpperLimit:int = 2;
		public static const e_equalLimits:int = 3;
		
		public var m_world:b2World;
		public function get m_type():int { return mem._mrs16(_ptr + 4); }
		public function set m_type(v:int):void { mem._mw16(_ptr + 4, v); }
		public var m_prev:b2Joint;
		public var m_next:b2Joint;
		public var m_bodyA:b2Body;
		public var m_bodyB:b2Body;
		public function get m_islandFlag():Boolean { return mem._mru8(_ptr + 56) == 1; }
		public function set m_islandFlag(v:Boolean):void { mem._mw8(_ptr + 56, v ? 1 : 0); }
		public function get m_collideConnected():Boolean { return mem._mru8(_ptr + 57) == 1; }
		public function set m_collideConnected(v:Boolean):void { mem._mw8(_ptr + 57, v ? 1 : 0); }
		public var m_userData:*;
	}
}