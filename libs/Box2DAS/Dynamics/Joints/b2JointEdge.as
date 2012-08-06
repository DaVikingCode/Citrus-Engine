package Box2DAS.Dynamics.Joints {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// A joint edge is used to connect bodies and joints together
	/// in a joint graph where each body is a node and each joint
	/// is an edge. A joint edge belongs to a doubly linked list
	/// maintained in each attached body. Each joint has two joint
	/// nodes, one for each attached body.
	public class b2JointEdge extends b2Base {
	
		public function b2JointEdge(p:int) {
			_ptr = p;
		}
		
		/// provides quick access to the other body attached.
		public function get other():b2Body {
			/// Address of b2Body + userData offset -> deref to AS3 = AS3 b2Body.
			return deref(mem._mr32(mem._mr32(_ptr + 0) + 152)) as b2Body;
		}
		
		/// the joint
		public function get joint():b2Joint {
			/// Address of b2Joint + userData offset -> deref to AS3 = AS3 b2Body.
			return deref(mem._mr32(mem._mr32(_ptr + 4) + 60)) as b2Joint;
		}
	
		/// the previous joint edge in the body's joint list	
		public function get prev():b2JointEdge {
			var p:int = mem._mr32(_ptr + 8);
			return p ? new b2JointEdge(p) : null;
		}
	
		/// the next joint edge in the body's joint list	
		public function get next():b2JointEdge {
			var p:int = mem._mr32(_ptr + 12);
			return p ? new b2JointEdge(p) : null;
		}
	}
};