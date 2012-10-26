package awayphysics.math {
	import awayphysics.AWPBase;

	import flash.geom.Vector3D;

	public class AWPVector3 extends AWPBase {
		private var _v3d : Vector3D = new Vector3D();

		public function AWPVector3(ptr : uint) {
			pointer = ptr;
		}

		public function get x() : Number {
			return memUser._mrf(pointer + 0);
		}

		public function set x(v : Number) : void {
			memUser._mwf(pointer + 0, v);
		}

		public function get y() : Number {
			return memUser._mrf(pointer + 4);
		}

		public function set y(v : Number) : void {
			memUser._mwf(pointer + 4, v);
		}

		public function get z() : Number {
			return memUser._mrf(pointer + 8);
		}

		public function set z(v : Number) : void {
			memUser._mwf(pointer + 8, v);
		}

		public function get v3d() : Vector3D {
			_v3d.setTo(x, y, z);
			return _v3d;
		}

		public function set v3d(v : Vector3D) : void {
			x = v.x;
			y = v.y;
			z = v.z;
		}

		public function get sv3d() : Vector3D {
			_v3d.setTo(x, y, z);
			_v3d.scaleBy(_scaling);
			return _v3d;
		}

		public function set sv3d(v : Vector3D) : void {
			x = v.x / _scaling;
			y = v.y / _scaling;
			z = v.z / _scaling;
		}
	}
}