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
	
	/// Joint definitions are used to construct joints.
	public class b2JointDef extends b2Base {
		
		public function create(w:b2World, ed:IEventDispatcher = null):b2Joint {
			return new b2Joint(w, this, ed);
		}
		
		/// The joint type is set automatically for concrete joint types.
		public function get type():int { return mem._mrs16(_ptr + 0); }
		public function set type(v:int):void { mem._mw16(_ptr + 0, v); }
		
		/// Use this to attach application specific data to your joints.
		public var userData:*;
		
		/// The first attached body.
		public var _bodyA:b2Body;
		public function get bodyA():b2Body { return _bodyA; }
		public function set bodyA(v:b2Body):void { mem._mw32(_ptr + 8, v._ptr); _bodyA = v; }
		
		/// The second attached body.
		public var _bodyB:b2Body;
		public function get bodyB():b2Body { return _bodyB; }
		public function set bodyB(v:b2Body):void { mem._mw32(_ptr + 12, v._ptr); _bodyB = v; }
		
		/// Set this flag to true if the attached bodies should collide.
		public function get collideConnected():Boolean { return mem._mru8(_ptr + 16) == 1; }
		public function set collideConnected(v:Boolean):void { mem._mw8(_ptr + 16, v ? 1 : 0); }
		
	}
}