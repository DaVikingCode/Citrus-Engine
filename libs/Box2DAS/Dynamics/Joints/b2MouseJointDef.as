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
	
	/// Mouse joint definition. This requires a world target point,
	/// tuning parameters, and the time step.
	public class b2MouseJointDef extends b2JointDef {

		public override function create(w:b2World, ed:IEventDispatcher = null):b2Joint {
			return new b2MouseJoint(w, this, ed);
		}
		
		public function b2MouseJointDef() {
			_ptr = lib.b2MouseJointDef_new();
			target = new b2Vec2(_ptr + 20);
		}
		
		public override function destroy():void {
			lib.b2MouseJointDef_delete(_ptr);
			super.destroy();
		}
		
		public function Initialize(b:b2Body, t:V2):void {
			bodyA = b.m_world.m_groundBody;
			bodyB = b;
			target.v2 = t;
		}
		
		/// The initial world target point. This is assumed
		/// to coincide with the body anchor initially.
		public var target:b2Vec2;
		
		/// The maximum constraint force that can be exerted
		/// to move the candidate body. Usually you will express
		/// as some multiple of the weight (multiplier * mass * gravity).
		public function get maxForce():Number { return mem._mrf(_ptr + 28); }
		public function set maxForce(v:Number):void { mem._mwf(_ptr + 28, v); }
		
		/// The response speed.
		public function get frequencyHz():Number { return mem._mrf(_ptr + 32); }
		public function set frequencyHz(v:Number):void { mem._mwf(_ptr + 32, v); }
		
		/// The damping ratio. 0 = no damping, 1 = critical damping.
		public function get dampingRatio():Number { return mem._mrf(_ptr + 36); }
		public function set dampingRatio(v:Number):void { mem._mwf(_ptr + 36, v); }
	
	}
}