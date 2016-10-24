package citrus.core {
	/**
	 * @author gsynuh
	 */
	public class SceneTransition {
		public static var TRANSITION_FADEIN : String = "transition_fadein";
		public static var TRANSITION_FADEOUT : String = "transition_fadeout";
		public static var TRANSITION_MOVEINLEFT : String = "transition_moveinleft";
		public static var TRANSITION_MOVEINRIGHT : String = "transition_moveinright";
		public static var TRANSITION_MOVEINDOWN : String = "transition_moveindown";
		public static var TRANSITION_MOVEINUP : String = "transition_moveinup";
		public static var validTransitions : Array = [TRANSITION_FADEIN, TRANSITION_FADEOUT, TRANSITION_MOVEINLEFT, TRANSITION_MOVEINRIGHT, TRANSITION_MOVEINDOWN, TRANSITION_MOVEINUP];

		public static function exists(transition : String) : Boolean {
			return validTransitions.indexOf(transition) > -1;
		}
	}
}
