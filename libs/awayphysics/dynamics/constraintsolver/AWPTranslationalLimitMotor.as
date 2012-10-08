package awayphysics.dynamics.constraintsolver {
	import awayphysics.AWPBase;
	import awayphysics.math.AWPVector3;

	import flash.geom.Vector3D;

	public class AWPTranslationalLimitMotor extends AWPBase {
		private var m_lowerLimit : AWPVector3;
		private var m_upperLimit : AWPVector3;
		private var m_accumulatedImpulse : AWPVector3;
		private var m_normalCFM : AWPVector3;
		private var m_stopERP : AWPVector3;
		private var m_stopCFM : AWPVector3;
		private var m_targetVelocity : AWPVector3;
		private var m_maxMotorForce : AWPVector3;
		private var m_currentLimitError : AWPVector3;
		private var m_currentLinearDiff : AWPVector3;

		public function AWPTranslationalLimitMotor(ptr : uint) {
			pointer = ptr;

			m_lowerLimit = new AWPVector3(ptr + 0);
			m_upperLimit = new AWPVector3(ptr + 16);
			m_accumulatedImpulse = new AWPVector3(ptr + 32);
			m_normalCFM = new AWPVector3(ptr + 60);
			m_stopERP = new AWPVector3(ptr + 76);
			m_stopCFM = new AWPVector3(ptr + 92);
			m_targetVelocity = new AWPVector3(ptr + 112);
			m_maxMotorForce = new AWPVector3(ptr + 128);
			m_currentLimitError = new AWPVector3(ptr + 144);
			m_currentLinearDiff = new AWPVector3(ptr + 160);
		}

		public function get lowerLimit() : Vector3D {
			return m_lowerLimit.sv3d;
		}

		public function set lowerLimit(v : Vector3D) : void {
			m_lowerLimit.sv3d = v;
		}

		public function get upperLimit() : Vector3D {
			return m_upperLimit.sv3d;
		}

		public function set upperLimit(v : Vector3D) : void {
			m_upperLimit.sv3d = v;
		}

		public function get accumulatedImpulse() : Vector3D {
			return m_accumulatedImpulse.v3d;
		}

		public function set accumulatedImpulse(v : Vector3D) : void {
			m_accumulatedImpulse.v3d = v;
		}

		public function get normalCFM() : Vector3D {
			return m_normalCFM.v3d;
		}

		public function set normalCFM(v : Vector3D) : void {
			m_normalCFM.v3d = v;
		}

		public function get stopERP() : Vector3D {
			return m_stopERP.v3d;
		}

		public function set stopERP(v : Vector3D) : void {
			m_stopERP.v3d = v;
		}

		public function get stopCFM() : Vector3D {
			return m_stopCFM.v3d;
		}

		public function set stopCFM(v : Vector3D) : void {
			m_stopCFM.v3d = v;
		}

		public function get targetVelocity() : Vector3D {
			return m_targetVelocity.v3d;
		}

		public function set targetVelocity(v : Vector3D) : void {
			m_targetVelocity.v3d = v;
		}

		public function get maxMotorForce() : Vector3D {
			return m_maxMotorForce.v3d;
		}

		public function set maxMotorForce(v : Vector3D) : void {
			m_maxMotorForce.v3d = v;
		}

		public function get currentLimitError() : Vector3D {
			return m_currentLimitError.v3d;
		}

		public function set currentLimitError(v : Vector3D) : void {
			m_currentLimitError.v3d = v;
		}

		public function get currentLinearDiff() : Vector3D {
			return m_currentLinearDiff.v3d;
		}

		public function set currentLinearDiff(v : Vector3D) : void {
			m_currentLinearDiff.v3d = v;
		}

		public function get limitSoftness() : Number {
			return memUser._mrf(pointer + 48);
		}

		public function set limitSoftness(v : Number) : void {
			memUser._mwf(pointer + 48, v);
		}

		public function get damping() : Number {
			return memUser._mrf(pointer + 52);
		}

		public function set damping(v : Number) : void {
			memUser._mwf(pointer + 52, v);
		}

		public function get restitution() : Number {
			return memUser._mrf(pointer + 56);
		}

		public function set restitution(v : Number) : void {
			memUser._mwf(pointer + 56, v);
		}

		public function get enableMotorX() : Boolean {
			return memUser._mru8(pointer + 108) == 1;
		}

		public function set enableMotorX(v : Boolean) : void {
			memUser._mw8(pointer + 108, v ? 1 : 0);
		}

		public function get enableMotorY() : Boolean {
			return memUser._mru8(pointer + 109) == 1;
		}

		public function set enableMotorY(v : Boolean) : void {
			memUser._mw8(pointer + 109, v ? 1 : 0);
		}

		public function get enableMotorZ() : Boolean {
			return memUser._mru8(pointer + 110) == 1;
		}

		public function set enableMotorZ(v : Boolean) : void {
			memUser._mw8(pointer + 110, v ? 1 : 0);
		}
	}
}