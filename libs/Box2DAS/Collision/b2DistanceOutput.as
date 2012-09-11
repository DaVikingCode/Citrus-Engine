package Box2DAS.Collision {

	import Box2DAS.Common.b2Base;
	import Box2DAS.Common.b2Vec2;
	
	public class b2DistanceOutput extends b2Base {
		
		public function b2DistanceOutput() {
			_ptr = lib.b2DistanceOutput_new();
			pointA = new b2Vec2(_ptr + 0);
			pointB = new b2Vec2(_ptr + 8);
		}
		
		public override function destroy():void {
			lib.b2DistanceOutput_delete(_ptr);
			super.destroy();
		}
		
		public var pointA:b2Vec2;
		public var pointB:b2Vec2;
		public function get distance():Number { return mem._mrf(_ptr + 16); }
		public function set distance(v:Number):void { mem._mwf(_ptr + 16, v); }
		public function get iterations():int { return mem._mr32(_ptr + 20); }
		public function set iterations(v:int):void { mem._mw32(_ptr + 20, v); }
	}
}