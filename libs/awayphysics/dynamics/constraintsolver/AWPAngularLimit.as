package awayphysics.dynamics.constraintsolver {
	import awayphysics.AWPBase;

	public class AWPAngularLimit extends AWPBase {
		public function AWPAngularLimit(ptr : uint) {
			pointer = ptr;
		}

		public function setLimit(low : Number, high : Number, _softness : Number = 0.9, _biasFactor : Number = 0.3, _relaxationFactor : Number = 1.0) : void {
			halfRange = (high - low) / 2;
			center = normalizeAngle(low + halfRange);
			softness = _softness;
			biasFactor = _biasFactor;
			relaxationFactor = _relaxationFactor;
		}
		
		public function get low():Number {
			return normalizeAngle(center - halfRange);
		}
		
		public function get high():Number {
			return normalizeAngle(center + halfRange);
		}

		public function get center() : Number {
			return memUser._mrf(pointer + 0);
		}

		public function set center(v : Number) : void {
			memUser._mwf(pointer + 0, v);
		}

		public function get halfRange() : Number {
			return memUser._mrf(pointer + 4);
		}

		public function set halfRange(v : Number) : void {
			memUser._mwf(pointer + 4, v);
		}

		public function get softness() : Number {
			return memUser._mrf(pointer + 8);
		}

		public function set softness(v : Number) : void {
			memUser._mwf(pointer + 8, v);
		}

		public function get biasFactor() : Number {
			return memUser._mrf(pointer + 12);
		}

		public function set biasFactor(v : Number) : void {
			memUser._mwf(pointer + 12, v);
		}

		public function get relaxationFactor() : Number {
			return memUser._mrf(pointer + 16);
		}

		public function set relaxationFactor(v : Number) : void {
			memUser._mwf(pointer + 16, v);
		}

		public function get correction() : Number {
			return memUser._mrf(pointer + 20);
		}

		public function get sign() : Number {
			return memUser._mrf(pointer + 24);
		}

		private function normalizeAngle(angleInRadians : Number) : Number {
			var pi2 : Number = 2 * Math.PI;
			var result : Number = angleInRadians % pi2;
			if (result < -Math.PI) {
				return result + pi2;
			} else if (result > Math.PI) {
				return result - pi2;
			} else {
				return result;
			}
		}
	}
}