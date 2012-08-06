package Box2DAS.Dynamics.Contacts {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2ContactID extends b2Base {

		public static var e_vertex:int = 0;
		public static var e_face:int = 1;
	
		public function b2ContactID(p:int) {
			_ptr = p;
		}
	
		/* public function get referenceEdge():int { return mem._mru8(_ptr + 0); }
		public function set referenceEdge(v:int):void { mem._mw8(_ptr + 0, v); }
		public function get incidentEdge():int { return mem._mru8(_ptr + 1); }
		public function set incidentEdge(v:int):void { mem._mw8(_ptr + 1, v); }
		public function get incidentVertex():int { return mem._mru8(_ptr + 2); }
		public function set incidentVertex(v:int):void { mem._mw8(_ptr + 2, v); }
		public function get flip():int { return mem._mru8(_ptr + 3); }
		public function set flip(v:int):void { mem._mw8(_ptr + 3, v); }		
		public function get key():int { return mem._mr32(_ptr + 0); }
		public function set key(v:int):void { mem._mw32(_ptr + 0, v); } */
		
		public function get key():int { return mem._mr32(_ptr + 0); }
		public function set key(v:int):void { mem._mw32(_ptr + 0, v); }
		public function get indexA():int { return mem._mru8(_ptr + 0); }
		public function set indexA(v:int):void { mem._mw8(_ptr + 0, v); }
		public function get indexB():int { return mem._mru8(_ptr + 1); }
		public function set indexB(v:int):void { mem._mw8(_ptr + 1, v); }
		public function get typeA():int { return mem._mru8(_ptr + 2); }
		public function set typeA(v:int):void { mem._mw8(_ptr + 2, v); }
		public function get typeB():int { return mem._mru8(_ptr + 3); }
		public function set typeB(v:int):void { mem._mw8(_ptr + 3, v); }

	}
}