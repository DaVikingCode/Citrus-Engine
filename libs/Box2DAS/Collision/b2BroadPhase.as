package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// The broad-phase is used for computing pairs and performing volume queries and ray casts.
	/// This broad-phase does not persist pairs. Instead, this reports potentially new pairs.
	/// It is up to the client to consume the new pairs and to track subsequent overlap.
	public class b2BroadPhase extends b2Base {
		
		public function b2BroadPhase(p:int) {
			_ptr = p;
		}
		
		/// Get the number of proxies.
		public function GetProxyCount():int {
			return m_proxyCount;
		}
		
		public static const e_nullProxy:int = -1;
		
		public function get m_proxyCount():int { return mem._mr32(_ptr + 28); }
		public function set m_proxyCount(v:int):void { mem._mw32(_ptr + 28, v); }
		public function get m_moveBuffer():int { return mem._mr32(_ptr + 32); }
		public function set m_moveBuffer(v:int):void { mem._mw32(_ptr + 32, v); }
		public function get m_moveCapacity():int { return mem._mr32(_ptr + 36); }
		public function set m_moveCapacity(v:int):void { mem._mw32(_ptr + 36, v); }
		public function get m_moveCount():int { return mem._mr32(_ptr + 40); }
		public function set m_moveCount(v:int):void { mem._mw32(_ptr + 40, v); }
		public function get m_pairCapacity():int { return mem._mr32(_ptr + 48); }
		public function set m_pairCapacity(v:int):void { mem._mw32(_ptr + 48, v); }
		public function get m_pairCount():int { return mem._mr32(_ptr + 52); }
		public function set m_pairCount(v:int):void { mem._mw32(_ptr + 52, v); }
		public function get m_queryProxyId():int { return mem._mr32(_ptr + 56); }
		public function set m_queryProxyId(v:int):void { mem._mw32(_ptr + 56, v); }
	}
}