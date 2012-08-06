package Box2DAS.Dynamics {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2Filter extends b2Base {
	
		public function b2Filter(p:int) {
			_ptr = p;
		}
		
		public function set filter(v:Object):void {
			categoryBits = v.categoryBits;
			maskBits = v.maskBits;
			groupIndex = v.groupIndex;
		}
		
		public function get filter():Object {
			return {categoryBits: categoryBits, maskBits: maskBits, groupIndex: groupIndex}
		}
	
		public function get categoryBits():int { return mem._mru16(_ptr + 0); }
		public function set categoryBits(v:int):void { mem._mw16(_ptr + 0, v); }
		public function get maskBits():int { return mem._mru16(_ptr + 2); }
		public function set maskBits(v:int):void { mem._mw16(_ptr + 2, v); }
		public function get groupIndex():int { return mem._mrs16(_ptr + 4); }
		public function set groupIndex(v:int):void { mem._mw16(_ptr + 4, v); }
	
	}
}