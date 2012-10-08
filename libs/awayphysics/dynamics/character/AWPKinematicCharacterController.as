package awayphysics.dynamics.character {
	import awayphysics.AWPBase;
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.math.AWPVector3;

	import flash.geom.Vector3D;

	public class AWPKinematicCharacterController extends AWPBase {
		private var m_ghostObject : AWPGhostObject;
		private var m_walkDirection : AWPVector3;
		private var m_normalizedDirection : AWPVector3;

		public function AWPKinematicCharacterController(ghostObject : AWPGhostObject, stepHeight : Number) {
			m_ghostObject = ghostObject;

			pointer = bullet.createCharacterMethod(ghostObject.pointer, ghostObject.shape.pointer, stepHeight, 1);

			m_walkDirection = new AWPVector3(pointer + 60);
			m_normalizedDirection = new AWPVector3(pointer + 76);
		}

		public function get ghostObject() : AWPGhostObject {
			return m_ghostObject;
		}
		
		public function dispose():void {
			if (!cleanup) {
				cleanup	= true;
				m_ghostObject.dispose();
				bullet.disposeCharacterMethod(pointer);
			}
		}

		/**
		 * called by dynamicsWorld
		 */
		public function updateTransform() : void {
			m_ghostObject.updateTransform();
		}

		public function get walkDirection() : Vector3D {
			return m_walkDirection.v3d;
		}
		
		/**
		 * set the walk direction and speed
		 */
		public function setWalkDirection(walkDirection : Vector3D) : void {
			useWalkDirection = true;
			m_walkDirection.v3d = walkDirection;
			var vec : Vector3D = walkDirection.clone();
			vec.normalize();
			m_normalizedDirection.v3d = vec;
		}

		/**
		 * set the walk direction and speed with time interval
		 */
		public function setVelocityForTimeInterval(velocity : Vector3D, timeInterval : Number) : void {
			useWalkDirection = false;
			m_walkDirection.v3d = velocity;
			var vec : Vector3D = velocity.clone();
			vec.normalize();
			m_normalizedDirection.v3d = vec;
			velocityTimeInterval = timeInterval;
		}

		/**
		 * set the character's position in world coordinates
		 */
		public function warp(origin : Vector3D) : void {
			m_ghostObject.position = origin;
		}

		/**
		 * whether character contact with ground
		 */
		public function onGround() : Boolean {
			return (verticalVelocity == 0 && verticalOffset == 0);
		}

		/**
		 * whether character can jump (on the ground)
		 */
		public function canJump() : Boolean {
			return onGround();
		}

		public function jump() : void {
			if (!canJump())
				return;

			verticalVelocity = jumpSpeed;
			wasJumping = true;
		}

		/**
		 * The max slope determines the maximum angle that the controller can walk up.
		 * The slope angle is measured in radians.
		 */
		public function setMaxSlope(slopeRadians : Number) : void {
			maxSlopeRadians = slopeRadians;
			maxSlopeCosine = Math.cos(slopeRadians);
		}

		public function getMaxSlope() : Number {
			return maxSlopeRadians;
		}

		public function get fallSpeed() : Number {
			return memUser._mrf(pointer + 24);
		}

		public function set fallSpeed(v : Number) : void {
			memUser._mwf(pointer + 24, v);
		}

		public function get jumpSpeed() : Number {
			return memUser._mrf(pointer + 28);
		}

		public function set jumpSpeed(v : Number) : void {
			memUser._mwf(pointer + 28, v);
		}

		public function get maxJumpHeight() : Number {
			return memUser._mrf(pointer + 32) * _scaling;
		}

		public function set maxJumpHeight(v : Number) : void {
			memUser._mwf(pointer + 32, v / _scaling);
		}

		public function get gravity() : Number {
			return memUser._mrf(pointer + 44);
		}

		public function set gravity(v : Number) : void {
			memUser._mwf(pointer + 44, v);
		}

		private function get wasJumping() : Boolean {
			return memUser._mru8(pointer + 169) == 1;
		}

		private function set wasJumping(v : Boolean) : void {
			memUser._mw8(pointer + 169, v ? 1 : 0);
		}

		private function get useWalkDirection() : Boolean {
			return memUser._mru8(pointer + 171) == 1;
		}

		private function set useWalkDirection(v : Boolean) : void {
			memUser._mw8(pointer + 171, v ? 1 : 0);
		}

		private function get velocityTimeInterval() : Number {
			return memUser._mrf(pointer + 172);
		}

		private function set velocityTimeInterval(v : Number) : void {
			memUser._mwf(pointer + 172, v);
		}

		private function get verticalVelocity() : Number {
			return memUser._mrf(pointer + 16);
		}

		private function set verticalVelocity(v : Number) : void {
			memUser._mwf(pointer + 16, v);
		}

		private function get verticalOffset() : Number {
			return memUser._mrf(pointer + 20);
		}

		private function set verticalOffset(v : Number) : void {
			memUser._mwf(pointer + 20, v);
		}

		private function get maxSlopeRadians() : Number {
			return memUser._mrf(pointer + 36);
		}

		private function set maxSlopeRadians(v : Number) : void {
			memUser._mwf(pointer + 36, v);
		}

		private function get maxSlopeCosine() : Number {
			return memUser._mrf(pointer + 40);
		}

		private function set maxSlopeCosine(v : Number) : void {
			memUser._mwf(pointer + 40, v);
		}
	}
}