package awayphysics.dynamics.constraintsolver {
	import awayphysics.AWPBase;
	import awayphysics.dynamics.AWPRigidBody;

	public class AWPTypedConstraint extends AWPBase {
		protected var m_rbA : AWPRigidBody;
		protected var m_rbB : AWPRigidBody;
		
		protected var m_constraintType:int;

		public function AWPTypedConstraint(type:int) {
			m_constraintType = type;
		}

		public function get rigidBodyA() : AWPRigidBody {
			return m_rbA;
		}

		public function get rigidBodyB() : AWPRigidBody {
			return m_rbB;
		}
		
		public function get constraintType():int {
			return m_constraintType;
		}
		
		public function dispose():void {
			if (!cleanup) {
				cleanup	= true;
				bullet.disposeConstraintMethod(pointer);
			}
		}
	}
}