package awayphysics.collision.dispatch {
	import flash.geom.Vector3D;
	
	public class AWPRay {
		public var pointer:uint;
		public var rayFrom:Vector3D;
		public var rayTo:Vector3D;
		
		public function AWPRay(from:Vector3D, to:Vector3D, ptr:uint = 0) {
			rayFrom = from;
			rayTo = to;
			pointer = ptr;
		}
	}
}