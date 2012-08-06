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
	
	/// Rope joint definition. This requires two body anchor points and
	/// a maximum lengths.
	/// Note: by default the connected objects will not collide.
	/// see collideConnected in b2JointDef.
	public class b2RopeJointDef extends b2JointDef {

		public override function create(w:b2World, ed:IEventDispatcher = null):b2Joint {
			return new b2RopeJoint(w, this, ed);
		}
	
		public function b2RopeJointDef() {
			_ptr = lib.b2RopeJointDef_new();
			localAnchorA = new b2Vec2(_ptr + 20);
			localAnchorB = new b2Vec2(_ptr + 28);
		}
		
		public override function destroy():void {
			lib.b2RopeJointDef_delete(_ptr);
			super.destroy();
		}
		
		public function Initialize(b1:b2Body, b2:b2Body, anchorA:V2, anchorB:V2):void {
			bodyA = b1;
			bodyB = b2;
			localAnchorA.v2 = bodyA.GetLocalPoint(anchorA);
			localAnchorB.v2 = bodyB.GetLocalPoint(anchorB);
			maxLength = anchorB.distance(anchorA);
		}

		/// The local anchor point relative to bodyA's origin.
		public var localAnchorA:b2Vec2; 
		
		/// The local anchor point relative to bodyB's origin.
		public var localAnchorB:b2Vec2; 

		/// The maximum length of the rope.
		/// Warning: this must be larger than b2_linearSlop or
		/// the joint will have no effect.
		public function get maxLength():Number { return mem._mrf(_ptr + 36); }
		public function set maxLength(v:Number):void { mem._mwf(_ptr + 36, v); }
	
	}
}