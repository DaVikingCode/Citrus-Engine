package Box2DAS.Dynamics.Contacts {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// A contact edge is used to connect bodies and contacts together
	/// in a contact graph where each body is a node and each contact
	/// is an edge. A contact edge belongs to a doubly linked list
	/// maintained in each attached body. Each contact has two contact
	/// nodes, one for each attached body.
	public class b2ContactEdge extends b2Base {
	
		public function b2ContactEdge(p:int) {
			_ptr = p;
		}
		
		/// provides quick access to the other body attached.
		public function get other():b2Body {
			/// Address of b2Body + userData offset -> deref to AS3 = AS3 b2Body.
			return deref(mem._mr32(mem._mr32(_ptr + 0) + 152)) as b2Body;
		}
		
		/// the contact
		public function get contact():b2Contact {
			/// Read value at pointer -> send to b2Contact constructor.
			return new b2Contact(mem._mr32(_ptr + 4));
		}
	
		/// the previous contact edge in the body's contact list	
		public function get prev():b2ContactEdge {
			var p:int = mem._mr32(_ptr + 8);
			return p ? new b2ContactEdge(p) : null;
		}
	
		/// the next contact edge in the body's contact list	
		public function get next():b2ContactEdge {
			var p:int = mem._mr32(_ptr + 12);
			return p ? new b2ContactEdge(p) : null;
		}
	}
};