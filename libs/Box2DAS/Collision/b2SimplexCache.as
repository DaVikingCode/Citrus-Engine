package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2SimplexCache extends b2Base {
		
		public function b2SimplexCache() {
			_ptr = lib.b2SimplexCache_new();
		}
		
		public override function destroy():void {
			lib.b2SimplexCache_delete(_ptr);
			super.destroy();
		}
		
		public function get metric():Number { return mem._mrf(_ptr + 0); }
		public function set metric(v:Number):void { mem._mwf(_ptr + 0, v); }
		public function get count():int { return mem._mru16(_ptr + 4); }
		public function set count(v:int):void { mem._mw16(_ptr + 4, v); }
		public function get indexA():int { return mem._mru8(_ptr + 6); }
		public function set indexA(v:int):void { mem._mw8(_ptr + 6, v); }
		public function get indexB():int { return mem._mru8(_ptr + 9); }
		public function set indexB(v:int):void { mem._mw8(_ptr + 9, v); }
	}
}