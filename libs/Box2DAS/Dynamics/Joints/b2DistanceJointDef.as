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
	
	/// Distance joint definition. This requires defining an
	/// anchor point on both bodies and the non-zero length of the
	/// distance joint. The definition uses local anchor points
	/// so that the initial configuration can violate the constraint
	/// slightly. This helps when saving and loading a game.
	/// @warning Do not use a zero or short length.
	public class b2DistanceJointDef extends b2JointDef {
		
		public override function create(w:b2World, ed:IEventDispatcher = null):b2Joint {
			return new b2DistanceJoint(w, this, ed);
		}
		
		public function b2DistanceJointDef() {
			_ptr = lib.b2DistanceJointDef_new();
			localAnchorA = new b2Vec2(_ptr + 20);
			localAnchorB = new b2Vec2(_ptr + 28);
		}
		
		public override function destroy():void {
			lib.b2DistanceJointDef_delete(_ptr);
			super.destroy();
		}
		
		/// Initialize the bodies, anchors, and length using the world
		/// anchors.
		///void Initialize(b2Body* bodyA, b2Body* bodyB,
		///				const b2Vec2& anchorA, const b2Vec2& anchorB);
		public function Initialize(b1:b2Body, b2:b2Body, 
				anchorA:V2, anchorB:V2):void {
			bodyA = b1;
			bodyB = b2;
			localAnchorA.v2 = bodyA.GetLocalPoint(anchorA);
			localAnchorB.v2 = bodyB.GetLocalPoint(anchorB);
			length = anchorB.distance(anchorA);
		}
		
		/// The local anchor point relative to bodyA's origin.
		public var localAnchorA:b2Vec2;
		
		/// The local anchor point relative to bodyB's origin.
		public var localAnchorB:b2Vec2;
		
		/// The equilibrium length between the anchor points.
		public function get length():Number { return mem._mrf(_ptr + 36); }
		public function set length(v:Number):void { mem._mwf(_ptr + 36, v); }

		/// The response speed.
		public function get frequencyHz():Number { return mem._mrf(_ptr + 40); }
		public function set frequencyHz(v:Number):void { mem._mwf(_ptr + 40, v); }

		/// The damping ratio. 0 = no damping, 1 = critical damping.
		public function get dampingRatio():Number { return mem._mrf(_ptr + 44); }
		public function set dampingRatio(v:Number):void { mem._mwf(_ptr + 44, v); }
	
	}
}