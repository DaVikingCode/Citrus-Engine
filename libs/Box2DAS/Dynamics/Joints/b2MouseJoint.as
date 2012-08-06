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
	
	/// A mouse joint is used to make a point on a body track a
	/// specified world point. This a soft constraint with a maximum
	/// force. This allows the constraint to stretch and without
	/// applying huge forces.
	/// NOTE: this joint is not documented in the manual because it was
	/// developed to be used in the testbed. If you want to learn how to
	/// use the mouse joint, look at the testbed.
	public class b2MouseJoint extends b2Joint {
	
		public function b2MouseJoint(w:b2World, d:b2MouseJointDef = null, ed:IEventDispatcher = null) {
			d ||= b2Def.mouseJoint;
			super(w, d, ed);
			m_localAnchor = new b2Vec2(_ptr + 96);
			m_target = new b2Vec2(_ptr + 104);
			m_impulse = new b2Vec2(_ptr + 112);
			m_C = new b2Vec2(_ptr + 136);
		}
		
		public override function GetAnchorA():V2 {
			return m_target.v2;
		}
	
		public override function GetAnchorB():V2 {
			return m_bodyB.GetWorldPoint(m_localAnchor.v2);
		}
		
		public override function GetReactionForce(inv_dt:Number):V2 {
			return m_impulse.v2.multiplyN(inv_dt);
		}
		
		public override function GetReactionTorque(inv_dt:Number):Number {
			return 0;
		}
		
		public function SetTarget(v:V2):void {
			m_bodyB.SetAwake(true);
			m_target.v2 = v;
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
		
		public function SetMaxForce(v:Number):void {
			m_maxForce = v;
		}
		
		public function GetMaxForce():Number {
			return m_maxForce;
		}
		
		public override function SetMaxMotorForce(v:Number):void { 
			m_maxForce = v;
		}
		
		public override function GetMaxMotorForce():Number {
			return m_maxForce;
		}
		
		public var m_localAnchor:b2Vec2;
		public var m_target:b2Vec2;
		public var m_impulse:b2Vec2;
		public var m_C:b2Vec2;
		public function get m_maxForce():Number { return mem._mrf(_ptr + 144); }
		public function set m_maxForce(v:Number):void { mem._mwf(_ptr + 144, v); }
		public function get m_frequencyHz():Number { return mem._mrf(_ptr + 148); }
		public function set m_frequencyHz(v:Number):void { mem._mwf(_ptr + 148, v); }
		public function get m_dampingRatio():Number { return mem._mrf(_ptr + 152); }
		public function set m_dampingRatio(v:Number):void { mem._mwf(_ptr + 152, v); }
		public function get m_beta():Number { return mem._mrf(_ptr + 156); }
		public function set m_beta(v:Number):void { mem._mwf(_ptr + 156, v); }
		public function get m_gamma():Number { return mem._mrf(_ptr + 160); }
		public function set m_gamma(v:Number):void { mem._mwf(_ptr + 160, v); }
	
	}
}