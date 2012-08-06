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
	
	/// Pulley joint definition. This requires two ground anchors,
	/// two dynamic body anchor points, max lengths for each side,
	/// and a pulley ratio.
	public class b2PulleyJointDef extends b2JointDef {

		public override function create(w:b2World, ed:IEventDispatcher = null):b2Joint {
			return new b2PulleyJoint(w, this, ed);
		}
		
		public function b2PulleyJointDef() {
			_ptr = lib.b2PulleyJointDef_new();
			groundAnchorA = new b2Vec2(_ptr + 20);
			groundAnchorB = new b2Vec2(_ptr + 28);
			localAnchorA = new b2Vec2(_ptr + 36);
			localAnchorB = new b2Vec2(_ptr + 44);
		}
		
		public override function destroy():void {
			lib.b2PulleyJointDef_delete(_ptr);
			super.destroy();
		}
		
		/// Initialize the bodies, anchors, lengths, max lengths, and ratio using the world anchors.
		/// void Initialize(b2Body* bodyA, b2Body* bodyB,
		///		const b2Vec2& groundAnchorA, const b2Vec2& groundAnchorB,
		///		const b2Vec2& anchorA, const b2Vec2& anchorB,
		///		float32 ratio);
		public function Initialize(b1:b2Body, b2:b2Body,
				ga1:V2, ga2:V2,
				anchorA:V2, anchorB:V2,
				r:Number):void {
			
			bodyA = b1;
			bodyB = b2;
			groundAnchorA.v2 = ga1;
			groundAnchorB.v2 = ga2;
			localAnchorA.v2 = bodyA.GetLocalPoint(anchorA);
			localAnchorB.v2 = bodyB.GetLocalPoint(anchorB);
			lengthA = anchorA.distance(ga1);
			lengthB = anchorB.distance(ga2);
			ratio = r;
			var C:Number = lengthA + ratio * lengthB;
			maxLengthA = C - ratio * b2PulleyJoint.b2_minPulleyLength;
			maxLengthB = (C - b2PulleyJoint.b2_minPulleyLength) / ratio;
		}
		
		/// The first ground anchor in world coordinates. This point never moves.
		public var groundAnchorA:b2Vec2;
		
		/// The second ground anchor in world coordinates. This point never moves.
		public var groundAnchorB:b2Vec2;

		/// The local anchor point relative to bodyA's origin.
		public var localAnchorA:b2Vec2;

		/// The local anchor point relative to bodyB's origin.
		public var localAnchorB:b2Vec2;

		/// The a reference length for the segment attached to bodyA.
		public function get lengthA():Number { return mem._mrf(_ptr + 52); }
		public function set lengthA(v:Number):void { mem._mwf(_ptr + 52, v); }

		/// The maximum length of the segment attached to bodyA.
		public function get maxLengthA():Number { return mem._mrf(_ptr + 56); }
		public function set maxLengthA(v:Number):void { mem._mwf(_ptr + 56, v); }

		/// The a reference length for the segment attached to bodyB.
		public function get lengthB():Number { return mem._mrf(_ptr + 60); }
		public function set lengthB(v:Number):void { mem._mwf(_ptr + 60, v); }

		/// The maximum length of the segment attached to bodyB.
		public function get maxLengthB():Number { return mem._mrf(_ptr + 64); }
		public function set maxLengthB(v:Number):void { mem._mwf(_ptr + 64, v); }

		/// The pulley ratio, used to simulate a block-and-tackle.
		public function get ratio():Number { return mem._mrf(_ptr + 68); }
		public function set ratio(v:Number):void { mem._mwf(_ptr + 68, v); }
	
	}
}