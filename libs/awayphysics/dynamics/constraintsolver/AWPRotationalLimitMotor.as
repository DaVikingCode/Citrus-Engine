package awayphysics.dynamics.constraintsolver {
	import awayphysics.AWPBase;

	public class AWPRotationalLimitMotor extends AWPBase {
		public function AWPRotationalLimitMotor(ptr : uint) {
			pointer = ptr;
		}

		public function isLimited() : Boolean {
			if (loLimit > hiLimit) return false;

			return true;
		}

		public function get loLimit() : Number {
			return memUser._mrf(pointer + 0);
		}

		public function set loLimit(v : Number) : void {
			memUser._mwf(pointer + 0, v);
		}

		public function get hiLimit() : Number {
			return memUser._mrf(pointer + 4);
		}

		public function set hiLimit(v : Number) : void {
			memUser._mwf(pointer + 4, v);
		}

		public function get targetVelocity() : Number {
			return memUser._mrf(pointer + 8);
		}

		public function set targetVelocity(v : Number) : void {
			memUser._mwf(pointer + 8, v);
		}

		public function get maxMotorForce() : Number {
			return memUser._mrf(pointer + 12);
		}

		public function set maxMotorForce(v : Number) : void {
			memUser._mwf(pointer + 12, v);
		}

		public function get maxLimitForce() : Number {
			return memUser._mrf(pointer + 16);
		}

		public function set maxLimitForce(v : Number) : void {
			memUser._mwf(pointer + 16, v);
		}

		public function get damping() : Number {
			return memUser._mrf(pointer + 20);
		}

		public function set damping(v : Number) : void {
			memUser._mwf(pointer + 20, v);
		}

		public function get limitSoftness() : Number {
			return memUser._mrf(pointer + 24);
		}

		public function set limitSoftness(v : Number) : void {
			memUser._mwf(pointer + 24, v);
		}

		public function get normalCFM() : Number {
			return memUser._mrf(pointer + 28);
		}

		public function set normalCFM(v : Number) : void {
			memUser._mwf(pointer + 28, v);
		}

		public function get stopERP() : Number {
			return memUser._mrf(pointer + 32);
		}

		public function set stopERP(v : Number) : void {
			memUser._mwf(pointer + 32, v);
		}

		public function get stopCFM() : Number {
			return memUser._mrf(pointer + 36);
		}

		public function set stopCFM(v : Number) : void {
			memUser._mwf(pointer + 36, v);
		}

		public function get bounce() : Number {
			return memUser._mrf(pointer + 40);
		}

		public function set bounce(v : Number) : void {
			memUser._mwf(pointer + 40, v);
		}

		public function get enableMotor() : Boolean {
			return memUser._mru8(pointer + 44) == 1;
		}

		public function set enableMotor(v : Boolean) : void {
			memUser._mw8(pointer + 44, v ? 1 : 0);
		}

		public function get currentLimitError() : Number {
			return memUser._mrf(pointer + 48);
		}

		public function set currentLimitError(v : Number) : void {
			memUser._mwf(pointer + 48, v);
		}

		public function get currentPosition() : Number {
			return memUser._mrf(pointer + 52);
		}

		public function set currentPosition(v : Number) : void {
			memUser._mwf(pointer + 52, v);
		}

		public function get currentLimit() : int {
			return memUser._mr32(pointer + 56);
		}

		public function set currentLimit(v : int) : void {
			memUser._mw32(pointer + 56, v);
		}

		public function get accumulatedImpulse() : Number {
			return memUser._mrf(pointer + 60);
		}

		public function set accumulatedImpulse(v : Number) : void {
			memUser._mwf(pointer + 60, v);
		}
	}
}