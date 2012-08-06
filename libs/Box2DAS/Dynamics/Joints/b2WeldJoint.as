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
	
	/// A weld joint essentially glues two bodies together. A weld joint may
	/// distort somewhat because the island constraint solver is approximate.
	public class b2WeldJoint extends b2Joint {
		
		public function b2WeldJoint(w:b2World, d:b2WeldJointDef = null, ed:IEventDispatcher = null) {
			d ||= b2Def.weldJoint;
			super(w, d, ed);
			m_localAnchorA = new b2Vec2(_ptr + 96);
			m_localAnchorB = new b2Vec2(_ptr + 104);
			m_impulse = new b2Vec3(_ptr + 116);
			m_mass = new b2Mat33(_ptr + 128);
		}
		
		public override function GetAnchorA():V2 {
			return m_bodyA.GetWorldPoint(m_localAnchorA.v2);
		}
		
		public override function GetAnchorB():V2 {
			return m_bodyB.GetWorldPoint(m_localAnchorB.v2);
		}
		
		public override function GetReactionForce(inv_dt:Number):V2 {
			return new V2(m_impulse.x, m_impulse.y).multiplyN(inv_dt);
		}
		
		public override function GetReactionTorque(inv_dt:Number):Number {
			return inv_dt * m_impulse.z;
		}
		
		public var m_localAnchorA:b2Vec2; 
		public var m_localAnchorB:b2Vec2;
		public function get m_referenceAngle():Number { return mem._mrf(_ptr + 112); }
		public function set m_referenceAngle(v:Number):void { mem._mwf(_ptr + 112, v); }
		public var m_impulse:b2Vec3;
		public var m_mass:b2Mat33;
	}
}