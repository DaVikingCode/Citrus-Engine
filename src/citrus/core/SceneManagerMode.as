package citrus.core {
	/**
	 * @author gsynuh
	 */
	public class SceneManagerMode {
		/**
		 * In this mode, the StateManager will, at maximum, have 3 states running at the same time.
		 * One main state, One state to transition to, and a possible Pause state that will be on top.
		 */
		public static var SINGLE_MODE : String = "singleMode";
		/**
		 * In this mode, the StateManager will allow you to define what happens with running states.
		 * You ask it to create states and it will run them.
		 */
		public static var USER_MODE : String = "userMode";
	}
}
