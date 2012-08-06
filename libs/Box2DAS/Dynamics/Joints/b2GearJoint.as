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
	
	/// A gear joint is used to connect two joints together. Either joint
	/// can be a revolute or prismatic joint. You specify a gear ratio
	/// to bind the motions together:
	/// coordinate1 + ratio * coordinate2 = constant
	/// The ratio can be negative or positive. If one joint is a revolute joint
	/// and the other joint is a prismatic joint, then the ratio will have units
	/// of length or units of 1/length.
	/// @warning The revolute and prismatic joints must be attached to
	/// fixed bodies (which must be bodyA on those joints).
	public class b2GearJoint extends b2Joint {
		
		public function b2GearJoint(w:b2World, d:b2GearJointDef = null, ed:IEventDispatcher = null) {
			d ||= b2Def.gearJoint;
			super(w, d, ed);
			m_ground1 = d.joint1.GetBodyA();
			m_ground2 = d.joint2.GetBodyA();
			m_revolute1 = d.joint1 as b2RevoluteJoint;
			m_prismatic1 = d.joint1 as b2PrismaticJoint;
			m_revolute2 = d.joint2 as b2RevoluteJoint;
			m_prismatic2 = d.joint2 as b2PrismaticJoint;
			m_groundAnchor1 = new b2Vec2(_ptr + 120);
			m_groundAnchor2 = new b2Vec2(_ptr + 128);
			m_localAnchor1 = new b2Vec2(_ptr + 136);
			m_localAnchor2 = new b2Vec2(_ptr + 144);
			m_J = new b2Jacobian(_ptr + 152);
		}
		
		public override function GetAnchorA():V2 {
			return m_bodyA.GetWorldPoint(m_localAnchor1.v2);
		}
	
		public override function GetAnchorB():V2 {
			return m_bodyB.GetWorldPoint(m_localAnchor2.v2);
		}
		
		public override function GetReactionForce(inv_dt:Number):V2 {
			return m_J.linear2.v2.multiplyN(m_impulse);
		}
		
		public override function GetReactionTorque(inv_dt:Number):Number {
			var r:V2 = m_bodyB.GetTransform().r.multiplyV(m_localAnchor2.v2.subtract(m_bodyB.GetLocalCenter()));
			var P:V2 = m_J.linear2.v2.multiplyN(m_impulse);
			var L:Number = m_impulse * m_J.angular2 - r.cross(P);
			return inv_dt * L;
		}
		
		public var m_ground1:b2Body;
		public var m_ground2:b2Body;
		public var m_revolute1:b2RevoluteJoint;
		public var m_prismatic1:b2PrismaticJoint;
		public var m_revolute2:b2RevoluteJoint;
		public var m_prismatic2:b2PrismaticJoint;
		public var m_groundAnchor1:b2Vec2;
		public var m_groundAnchor2:b2Vec2;
		public var m_localAnchor1:b2Vec2;
		public var m_localAnchor2:b2Vec2;
		public function get m_constant():Number { return mem._mrf(_ptr + 176); }
		public function set m_constant(v:Number):void { mem._mwf(_ptr + 176, v); }
		public function get m_ratio():Number { return mem._mrf(_ptr + 180); }
		public function set m_ratio(v:Number):void { mem._mwf(_ptr + 180, v); }
		public function get m_mass():Number { return mem._mrf(_ptr + 184); }
		public function set m_mass(v:Number):void { mem._mwf(_ptr + 184, v); }
		public function get m_impulse():Number { return mem._mrf(_ptr + 188); }
		public function set m_impulse(v:Number):void { mem._mwf(_ptr + 188, v); }
		public var m_J:b2Jacobian;
	
	}
}