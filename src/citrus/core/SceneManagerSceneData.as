package citrus.core {
	import aze.motion.EazeTween;

	/**
	 * This class is used to define scenes and track transitioning scenes or running scenes.
	 * name and type are needed however other properties are not necessary and will only be used by
	 * sceneManager during the scene creation and/or transition.
	 */
	internal class SceneManagerSceneData {
		public var name : String;
		public var type : Class;
		// optional
		public var args : Array = null;
		public var transition : String;
		public var transitionTime : Number;
		public var preloading:Boolean = false;
		// set when scene is running
		public var transitionTween : EazeTween;
		public var onTransitionComplete : Function;
		public var scene : IScene;

		public function SceneManagerSceneData(name : String, type : Class, args : Array = null, transition : String = null, transitionTime : Number = Number.NaN) {
			this.name = name;
			this.type = type;
			this.args = args;
			this.transition = transition;
			this.transitionTime = transitionTime;
		}

		public function destroy() : void {
			if (transitionTween != null) transitionTween.kill();
			if (scene != null) scene.destroy();
			transitionTween = null;
		}

		public function clone() : SceneManagerSceneData {
			return new SceneManagerSceneData(this.name, this.type, this.args, this.transition, this.transitionTime);
		}
	}
}
