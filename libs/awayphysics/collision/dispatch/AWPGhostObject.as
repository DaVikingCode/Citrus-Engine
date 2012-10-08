package awayphysics.collision.dispatch {
	import away3d.containers.ObjectContainer3D;

	import awayphysics.collision.shapes.AWPCollisionShape;

	/**
	 *used for create the character controller
	 */
	public class AWPGhostObject extends AWPCollisionObject {
		public function AWPGhostObject(shape : AWPCollisionShape, skin : ObjectContainer3D = null) {
			pointer = bullet.createGhostObjectMethod(this, shape.pointer);
			super(shape, skin, pointer);
		}
	}
}