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
	
	/// The pulley joint is connected to two bodies and two fixed ground points.
	/// The pulley supports a ratio such that:
	/// length1 + ratio * length2 <= constant
	/// Yes, the force transmitted is scaled by the ratio.
	/// The pulley also enforces a maximum length limit on both sides. This is
	/// useful to prevent one side of the pulley hitting the top.
	public class b2PulleyJoint extends b2Joint {

		public static var b2_minPulleyLength:Number = 0.1;
		
		public function b2PulleyJoint(w:b2World, d:b2PulleyJointDef = null, ed:IEventDispatcher = null) {
			d ||= b2Def.pulleyJoint;
			super(w, d, ed);
			m_groundAnchor1 = new b2Vec2(_ptr + 96);
			m_groundAnchor2 = new b2Vec2(_ptr + 104);
			m_localAnchor1 = new b2Vec2(_ptr + 112);
			m_localAnchor2 = new b2Vec2(_ptr + 120);
			m_u1 = new b2Vec2(_ptr + 128);
			m_u2 = new b2Vec2(_ptr + 136);
		}
		
		public override function GetAnchorA():V2 {
			return m_bodyA.GetWorldPoint(m_localAnchor1.v2);
		}
	
		public override function GetAnchorB():V2 {
			return m_bodyB.GetWorldPoint(m_localAnchor2.v2);
		}
		
		public override function GetReactionForce(inv_dt:Number):V2 {
			return m_u2.v2.multiplyN(m_impulse * inv_dt);
		}
		
		public override function GetReactionTorque(inv_dt:Number):Number {
			return 0;
		}
		
		/// Get the first ground anchor.
		/// b2Vec2 GetGroundAnchor1() const;
		public function GetGroundAnchor1():V2 {
			return m_groundAnchor1.v2;
		}
	
		/// Get the second ground anchor.
		/// b2Vec2 GetGroundAnchor2() const;
		public function GetGroundAnchor2():V2 {
			return m_groundAnchor2.v2;
		}
		
		/// Get the current length of the segment attached to bodyA.
		/// float32 GetLength1() const;
		public function GetLength1():Number {
			return m_bodyA.GetWorldPoint(m_localAnchor1.v2).distance(m_groundAnchor1.v2);
		}
		
		/// Get the current length of the segment attached to body2.
		/// float32 GetLength2() const;
		public function GetLength2():Number {
			return m_bodyB.GetWorldPoint(m_localAnchor2.v2).distance(m_groundAnchor2.v2);
		}
	
		/// Get the pulley ratio.
		/// float32 GetRatio() const;
		public function GetRatio():Number {
			return m_ratio;
		}
		
		public var m_groundAnchor1:b2Vec2;
		public var m_groundAnchor2:b2Vec2;
		public var m_localAnchor1:b2Vec2; 
		public var m_localAnchor2:b2Vec2; 
		public var m_u1:b2Vec2; 
		public var m_u2:b2Vec2; 
		public function get m_constant():Number { return mem._mrf(_ptr + 144); }
		public function set m_constant(v:Number):void { mem._mwf(_ptr + 144, v); }
		public function get m_ratio():Number { return mem._mrf(_ptr + 148); }
		public function set m_ratio(v:Number):void { mem._mwf(_ptr + 148, v); }
		public function get m_maxLength1():Number { return mem._mrf(_ptr + 152); }
		public function set m_maxLength1(v:Number):void { mem._mwf(_ptr + 152, v); }
		public function get m_maxLength2():Number { return mem._mrf(_ptr + 156); }
		public function set m_maxLength2(v:Number):void { mem._mwf(_ptr + 156, v); }
		public function get m_pulleyMass():Number { return mem._mrf(_ptr + 160); }
		public function set m_pulleyMass(v:Number):void { mem._mwf(_ptr + 160, v); }
		public function get m_limitMass1():Number { return mem._mrf(_ptr + 164); }
		public function set m_limitMass1(v:Number):void { mem._mwf(_ptr + 164, v); }
		public function get m_limitMass2():Number { return mem._mrf(_ptr + 168); }
		public function set m_limitMass2(v:Number):void { mem._mwf(_ptr + 168, v); }
		public function get m_impulse():Number { return mem._mrf(_ptr + 172); }
		public function set m_impulse(v:Number):void { mem._mwf(_ptr + 172, v); }
		public function get m_limitImpulse1():Number { return mem._mrf(_ptr + 176); }
		public function set m_limitImpulse1(v:Number):void { mem._mwf(_ptr + 176, v); }
		public function get m_limitImpulse2():Number { return mem._mrf(_ptr + 180); }
		public function set m_limitImpulse2(v:Number):void { mem._mwf(_ptr + 180, v); }
		public function get m_state():int { return mem._mrs16(_ptr + 184); }
		public function set m_state(v:int):void { mem._mw16(_ptr + 184, v); }
		public function get m_limitState1():int { return mem._mrs16(_ptr + 188); }
		public function set m_limitState1(v:int):void { mem._mw16(_ptr + 188, v); }
		public function get m_limitState2():int { return mem._mrs16(_ptr + 192); }
		public function set m_limitState2(v:int):void { mem._mw16(_ptr + 192, v); }
	
	}
}