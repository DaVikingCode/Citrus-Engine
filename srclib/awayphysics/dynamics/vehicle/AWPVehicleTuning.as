package awayphysics.dynamics.vehicle {
	public class AWPVehicleTuning {
		public var suspensionStiffness : Number;
		public var suspensionCompression : Number;
		public var suspensionDamping : Number;
		public var maxSuspensionTravelCm : Number;
		public var frictionSlip : Number;
		public var maxSuspensionForce : Number;

		public function AWPVehicleTuning() {
			suspensionStiffness = 5.88;
			suspensionCompression = 0.83;
			suspensionDamping = 0.88;
			maxSuspensionTravelCm = 500;
			frictionSlip = 10.5;
			maxSuspensionForce = 6000;
		}
	}
}