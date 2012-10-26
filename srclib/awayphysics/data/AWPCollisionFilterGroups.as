package awayphysics.data {
	public class AWPCollisionFilterGroups {
		public static const DefaultFilter : int = 1;
		public static const StaticFilter : int = 2;
		public static const KinematicFilter : int = 4;
		public static const DebrisFilter : int = 8;
		public static const SensorTrigger : int = 16;
		public static const CharacterFilter : int = 32;
		public static const AllFilter : int = -1;
		// all bits sets: DefaultFilter | StaticFilter | KinematicFilter | DebrisFilter | SensorTrigger
	}
}