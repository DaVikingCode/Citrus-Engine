package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2Manifold extends b2Base {
		
		public static var e_circles:int = 0;
		public static var e_faceA:int = 1;
		public static var e_faceB:int = 2;
		
		public function b2Manifold(p:int) {
			_ptr = p;
			//localPlaneNormal = new b2Vec2(_ptr + 40);
			//localPoint = new b2Vec2(_ptr + 48);
			localNormal = new b2Vec2(_ptr + 48);
			localPoint = new b2Vec2(_ptr + 56);
			points[0] = new b2ManifoldPoint(_ptr + 0);
			//points[1] = new b2ManifoldPoint(_ptr + 20);
			points[1] = new b2ManifoldPoint(_ptr + 24)
		}
		
		/* public var localPlaneNormal:b2Vec2; 
		public var localPoint:b2Vec2;
		public function get type():int { return mem._mrs8(_ptr + 56); }
		public function set type(v:int):void { mem._mw8(_ptr + 56, v); }
		public function get pointCount():int { return mem._mr32(_ptr + 60); }
		public function set pointCount(v:int):void { mem._mw32(_ptr + 60, v); } */
		
		public var points:Array = []; 
		
		public var localNormal:b2Vec2; // localNormal = new b2Vec2(_ptr + 48);
		public var localPoint:b2Vec2; // localPoint = new b2Vec2(_ptr + 56);
		public function get type():int { return mem._mrs8(_ptr + 64); }
		public function set type(v:int):void { mem._mw8(_ptr + 64, v); }
		public function get pointCount():int { return mem._mr32(_ptr + 68); }
		public function set pointCount(v:int):void { mem._mw32(_ptr + 68, v); }
		//public var points[0]:b2ManifoldPoint; // points[0] = new b2ManifoldPoint(_ptr + 0);
		//public var points[1]:b2ManifoldPoint; // points[1] = new b2ManifoldPoint(_ptr + 24);
	
	}
}