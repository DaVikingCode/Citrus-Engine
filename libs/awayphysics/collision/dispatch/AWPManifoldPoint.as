package awayphysics.collision.dispatch {
	import awayphysics.AWPBase;
	import awayphysics.math.AWPVector3;

	import flash.geom.Vector3D;

	public class AWPManifoldPoint extends AWPBase {
		private var m_localPointA : AWPVector3;
		private var m_localPointB : AWPVector3;
		private var m_normalWorldOnB : AWPVector3;

		public function AWPManifoldPoint(ptr : uint) {
			pointer = ptr;

			m_localPointA = new AWPVector3(ptr + 0);
			m_localPointB = new AWPVector3(ptr + 16);
			m_normalWorldOnB = new AWPVector3(ptr + 64);
		}

		/**
		 *get the collision position in objectA's local coordinates
		 */
		public function get localPointA() : Vector3D {
			return m_localPointA.sv3d;
		}

		/**
		 *get the collision position in objectB's local coordinates
		 */
		public function get localPointB() : Vector3D {
			return m_localPointB.sv3d;
		}

		/**
		 *get the collision normal in world coordinates
		 */
		public function get normalWorldOnB() : Vector3D {
			return m_normalWorldOnB.v3d;
		}

		/**
		 *get the value of collision impulse
		 */
		public function get appliedImpulse() : Number {
			return memUser._mrf(pointer + 112);
		}
	}
}