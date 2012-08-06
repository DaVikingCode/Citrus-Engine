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
	
	/// A distance joint constrains two points on two bodies
	/// to remain at a fixed distance from each other. You can view
	/// this as a massless, rigid rod.
	public class b2DistanceJoint extends b2Joint {
		
		public function b2DistanceJoint(w:b2World, d:b2DistanceJointDef = null, ed:IEventDispatcher = null) {
			d ||= b2Def.distanceJoint;
			super(w, d, ed);
			m_localAnchor1 = new b2Vec2(_ptr + 96);
			m_localAnchor2 = new b2Vec2(_ptr + 104);
			m_u = new b2Vec2(_ptr + 112);
		}
		
		public override function GetAnchorA():V2 {
			return m_bodyA.GetWorldPoint(m_localAnchor1.v2);
		}
	
		public override function GetAnchorB():V2 {
			return m_bodyB.GetWorldPoint(m_localAnchor2.v2);
		}
		
		public override function GetReactionForce(inv_dt:Number):V2 {
			return m_u.v2.multiplyN(m_impulse * inv_dt);
		}
		
		public override function GetReactionTorque(inv_dt:Number):Number {
			return 0;
		}
		
		public override function SetFrequency(hz:Number):void {
			m_frequencyHz = hz;
		}
		
		public override function GetFrequency():Number {
			return m_frequencyHz;
		}

		public override function SetDampingRatio(ratio:Number):void {
			m_dampingRatio = ratio;
		}
		
		public override function GetDampingRatio():Number {
			return m_dampingRatio;
		}
		
		public var m_localAnchor1:b2Vec2; // m_localAnchorA = new b2Vec2(_ptr + 96);
		public var m_localAnchor2:b2Vec2; // m_localAnchorB = new b2Vec2(_ptr + 104);
		public var m_u:b2Vec2; // m_u = new b2Vec2(_ptr + 112);
		public function get m_frequencyHz():Number { return mem._mrf(_ptr + 120); }
		public function set m_frequencyHz(v:Number):void { mem._mwf(_ptr + 120, v); }
		public function get m_dampingRatio():Number { return mem._mrf(_ptr + 124); }
		public function set m_dampingRatio(v:Number):void { mem._mwf(_ptr + 124, v); }
		public function get m_gamma():Number { return mem._mrf(_ptr + 128); }
		public function set m_gamma(v:Number):void { mem._mwf(_ptr + 128, v); }
		public function get m_bias():Number { return mem._mrf(_ptr + 132); }
		public function set m_bias(v:Number):void { mem._mwf(_ptr + 132, v); }
		public function get m_impulse():Number { return mem._mrf(_ptr + 136); }
		public function set m_impulse(v:Number):void { mem._mwf(_ptr + 136, v); }
		public function get m_mass():Number { return mem._mrf(_ptr + 140); }
		public function set m_mass(v:Number):void { mem._mwf(_ptr + 140, v); }
		public function get m_length():Number { return mem._mrf(_ptr + 144); }
		public function set m_length(v:Number):void { mem._mwf(_ptr + 144, v); }
	
	}
}