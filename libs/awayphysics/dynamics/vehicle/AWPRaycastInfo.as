package awayphysics.dynamics.vehicle {
	import awayphysics.AWPBase;
	import awayphysics.math.AWPVector3;

	import flash.geom.Vector3D;

	public class AWPRaycastInfo extends AWPBase {
		private var m_contactNormalWS : AWPVector3;
		private var m_contactPointWS : AWPVector3;
		private var m_hardPointWS : AWPVector3;
		private var m_wheelDirectionWS : AWPVector3;
		private var m_wheelAxleWS : AWPVector3;

		public function AWPRaycastInfo(ptr : uint) {
			pointer = ptr;

			m_contactNormalWS = new AWPVector3(ptr + 0);
			m_contactPointWS = new AWPVector3(ptr + 16);
			m_hardPointWS = new AWPVector3(ptr + 36);
			m_wheelDirectionWS = new AWPVector3(ptr + 52);
			m_wheelAxleWS = new AWPVector3(ptr + 68);
		}

		public function get contactNormalWS() : Vector3D {
			return m_contactNormalWS.v3d;
		}

		public function get contactPointWS() : Vector3D {
			return m_contactPointWS.sv3d;
		}

		public function get hardPointWS() : Vector3D {
			return m_hardPointWS.sv3d;
		}

		public function get wheelDirectionWS() : Vector3D {
			return m_wheelDirectionWS.v3d;
		}

		public function get wheelAxleWS() : Vector3D {
			return m_wheelAxleWS.v3d;
		}

		public function get suspensionLength() : Number {
			return memUser._mrf(pointer + 32) * _scaling;
		}

		public function get isInContact() : Boolean {
			return memUser._mru8(pointer + 84) == 1;
		}
	}
}