package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2ManifoldPoint extends b2Base {
	
		public function b2ManifoldPoint(p:int) {
			_ptr = p;
			localPoint = new b2Vec2(_ptr + 0);
			id = new b2ContactID(_ptr + 16);
		}
		
		public var localPoint:b2Vec2; // m_localPoint = new b2Vec2(_ptr + 0);
		public function get normalImpulse():Number { return mem._mrf(_ptr + 8); }
		public function set normalImpulse(v:Number):void { mem._mwf(_ptr + 8, v); }
		public function get tangentImpulse():Number { return mem._mrf(_ptr + 12); }
		public function set tangentImpulse(v:Number):void { mem._mwf(_ptr + 12, v); }
		public var id:b2ContactID; // m_id = new b2ContactID(_ptr + 16);
		public function get isNew():Boolean { return mem._mru8(_ptr + 20) == 1; }
		public function set isNew(v:Boolean):void { mem._mw8(_ptr + 20, v ? 1 : 0); }
	
	}
}