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
	
	/// A rope joint enforces a maximum distance between two points
	/// on two bodies. It has no other effect.
	/// Warning: if you attempt to change the maximum length during
	/// the simulation you will get some non-physical behavior.
	/// A model that would allow you to dynamically modify the length
	/// would have some sponginess, so I chose not to implement it
	/// that way. See b2DistanceJoint if you want to dynamically
	/// control length.
	public class b2RopeJoint extends b2Joint {
	
		public function b2RopeJoint(w:b2World, d:b2RopeJointDef = null, ed:IEventDispatcher = null) {
			d ||= b2Def.ropeJoint;
			super(w, d, ed);
			m_localAnchorA = new b2Vec2(_ptr + 96);
			m_localAnchorB = new b2Vec2(_ptr + 104);
			m_u = new b2Vec2(_ptr + 120);
			m_rA = new b2Vec2(_ptr + 128);
			m_rB = new b2Vec2(_ptr + 136);
		}
		
		public override function GetAnchorA():V2 {
			return m_bodyA.GetWorldPoint(m_localAnchorA.v2);
		}
	
		public override function GetAnchorB():V2 {
			return m_bodyB.GetWorldPoint(m_localAnchorB.v2);
		}
		
		public override function GetReactionForce(inv_dt:Number):V2 {
			return m_u.v2.multiplyN(inv_dt * m_impulse);
		}
		
		public override function GetReactionTorque(inv_dt:Number):Number {
			return 0;
		}
		
		public var m_localAnchorA:b2Vec2; // m_localAnchorA = new b2Vec2(_ptr + 96);
		public var m_localAnchorB:b2Vec2; // m_localAnchorB = new b2Vec2(_ptr + 104);
		public function get m_maxLength():Number { return mem._mrf(_ptr + 112); }
		public function set m_maxLength(v:Number):void { mem._mwf(_ptr + 112, v); }
		public function get m_length():Number { return mem._mrf(_ptr + 116); }
		public function set m_length(v:Number):void { mem._mwf(_ptr + 116, v); }
		public var m_u:b2Vec2; // m_u = new b2Vec2(_ptr + 120);
		public var m_rA:b2Vec2; // m_rA = new b2Vec2(_ptr + 128);
		public var m_rB:b2Vec2; // m_rB = new b2Vec2(_ptr + 136);
		public function get m_mass():Number { return mem._mrf(_ptr + 144); }
		public function set m_mass(v:Number):void { mem._mwf(_ptr + 144, v); }
		public function get m_impulse():Number { return mem._mrf(_ptr + 148); }
		public function set m_impulse(v:Number):void { mem._mwf(_ptr + 148, v); }
		public function get m_limitState():int { return mem._mrs16(_ptr + 212); }
		public function set m_limitState(v:int):void { mem._mw16(_ptr + 212, v); }
	
	}
}