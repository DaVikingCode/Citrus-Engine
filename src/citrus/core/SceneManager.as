package citrus.core {
	import ash.signals.Signal1;

	import aze.motion.EazeTween;
	import aze.motion.easing.Linear;

	public class SceneManager {
		/**
		 * Dispatched with a scene object, when that scene is added (visually) to CE.
		 */
		public var onsceneAdded : Signal1;
		/**
		 * Dispatched with a scene object, when that scene is removed/destroyed.
		 */
		public var onsceneRemoved : Signal1;
		protected var definedscenes : Vector.<SceneManagerSceneData>;
		protected var definedsceneNames : Array = [];
		protected var lastCreatedscene : SceneManagerSceneData;
		protected var runningscenes : Vector.<SceneManagerSceneData>;
		protected var scenesToCreate : Vector.<SceneManagerSceneData>;
		protected var scenesToDestroy : Vector.<SceneManagerSceneData>;
		protected var _ce : CitrusEngine;
		protected var _transitionQueue : Array;
		protected var _sceneManagerMode : String;
		/**
		 * names of scenes that describe levels.
		 * levels defined here can be navigated using startLevelProgression, nextLevel, gotoLevel, previousLevel.
		 */
		protected var levelProgression : Array = [];
		/**
		 * current level index (in levelProgression)
		 */
		protected var currentLevel : int = -1;

		public function SceneManager(sceneManagerMode : String = null) {
			_sceneManagerMode = sceneManagerMode != null ? sceneManagerMode : SceneManagerMode.SINGLE_MODE;

			onsceneAdded = new Signal1(IScene);
			onsceneRemoved = new Signal1(IScene);

			definedscenes = new Vector.<SceneManagerSceneData>();
			runningscenes = new Vector.<SceneManagerSceneData>();
			scenesToCreate = new Vector.<SceneManagerSceneData>();
			scenesToDestroy = new Vector.<SceneManagerSceneData>();

			_transitionQueue = [];
			_ce = CitrusEngine.getInstance();
			_ce.onPlayingChange.add(handlePlayingChanged);
		}

		/**
		 * pause/resumes transitions when CE is paused/resumed
		 */
		public function handlePlayingChanged(playing : Boolean) : void {
			for each (var sceneData : SceneManagerSceneData in runningscenes) {
				if (sceneData.transitionTween != null && sceneData.transitionTween.isStarted) {
					if (!playing) {
						sceneData.transitionTween.pause();
					} else
						sceneData.transitionTween.resume();
				}
			}
		}

		/**
		 * add a scene to the scene manager, defined by a name and a type (Class).
		 * the params object can hold additional information such as arguments to pass when the scene is constructed.
		 */
		public function add(name : String, type : Class, params : Object = null) : void {
			if (name == null || type == null)
				return;

			if (getSceneManagerSceneDataByName(name, false) != null)
				return;

			var sceneData : SceneManagerSceneData = new SceneManagerSceneData(name, type);

			if (params != null) {
				if ("args" in params && params.args is Array)
					sceneData.args = params.args;
				if ("transition" in params)
					sceneData.transition = params.transition;
				if ("transitionTime" in params)
					sceneData.transitionTime = params.transitionTime;
				if ("onTransitionComplete" in params)
					sceneData.onTransitionComplete = params.onTransitionComplete;
			}

			definedsceneNames.push(name);
			definedscenes.push(sceneData);
		}

		/**
		 * Starts a new scene by name.
		 * if destroy is true, every currently running scene will be destroyed.
		 * if arguments for transition are set, this scene will come in via a transition,
		 * by default, after a transition, every scene is destroyed except for the one who's transition is over.
		 */
		public function start(name : String, destroy : Boolean = true, transition : String = null, transitionTime : Number = Number.NaN, onTransitionComplete : Function = null) : void {
			var sceneData : SceneManagerSceneData = getSceneManagerSceneDataByName(name);
			if (sceneData == null)
				return;

			if (destroy)
				destroyAllButRunning();

			if (transition != null)
				sceneData.transition = transition;

			if (transitionTime >= 0)
				sceneData.transitionTime = transitionTime;

			if (onTransitionComplete != null)
				sceneData.onTransitionComplete = onTransitionComplete;
			
			startsceneTransition(sceneData);
		}
		
		public function setSceneArgs(name:String,args:Array):void {
			var sceneData : SceneManagerSceneData = getSceneManagerSceneDataByName(name,false);
			if(sceneData != null) {
				sceneData.args = args;
			}
		}

		protected function getSceneManagerSceneDataByName(name : String, clone : Boolean = true) : SceneManagerSceneData {
			for each (var sceneData : SceneManagerSceneData in definedscenes)
				if (sceneData.name == name)
					if (clone)
						return sceneData.clone();
					else
						return sceneData;
			return null;
		}

		/**
		 * creates the scene object , set it in the SceneManagerSceneData, and returns it.
		 */
		protected function createscene(sceneData : SceneManagerSceneData) : IScene {
			var scene : IScene = createObjectWithArgs(sceneData.type, sceneData.args);
			sceneData.scene = scene;
			return scene;
		}

		/**
		 * this creates the transition and starts it if it exists.
		 * in any case the scene is then queued up in scenesToCreate.
		 */
		protected function startsceneTransition(sceneData : SceneManagerSceneData) : IScene {
			var transition : String = sceneData.transition;
			var transitionTime : Number = sceneData.transitionTime;
			var scene : IScene = createscene(sceneData);

			if (scene == null)
				return null;
				
			if (SceneTransition.exists(transition)) {
				switch (transition) {
					case SceneTransition.TRANSITION_FADEOUT :
					case SceneTransition.TRANSITION_FADEIN :
						sceneData.transitionTween = new EazeTween(scene, false);
						sceneData.transitionTween.from(transitionTime, {alpha:0}).easing(Linear.easeNone);
						break;
					case SceneTransition.TRANSITION_MOVEINLEFT :
						sceneData.transitionTween = new EazeTween(scene, false);
						sceneData.transitionTween.from(transitionTime, {x:-_ce.screenWidth}).easing(Linear.easeNone);
						break;
					case SceneTransition.TRANSITION_MOVEINRIGHT :
						sceneData.transitionTween = new EazeTween(scene, false);
						sceneData.transitionTween.from(transitionTime, {x:_ce.screenWidth}).easing(Linear.easeNone);
						break;
					case SceneTransition.TRANSITION_MOVEINDOWN :
						sceneData.transitionTween = new EazeTween(scene, false);
						sceneData.transitionTween.from(transitionTime, {y:_ce.screenHeight}).easing(Linear.easeNone);
						break;
					case SceneTransition.TRANSITION_MOVEINUP :
						sceneData.transitionTween = new EazeTween(scene, false);
						sceneData.transitionTween.from(transitionTime, {y:-_ce.screenHeight}).easing(Linear.easeNone);
						break;
				}

				sceneData.transitionTween.updateNow();
				sceneData.transitionTween.onComplete(function() : void {
					switch (_sceneManagerMode) {
						case SceneManagerMode.SINGLE_MODE:
							destroyAllButRunningExcept(sceneData);
							break;
					}

					if (sceneData.onTransitionComplete != null)
						sceneData.onTransitionComplete();

					sceneData.transition = null;
					sceneData.transitionTime = NaN;
					sceneData.onTransitionComplete = null;
					sceneData.transitionTween = null;
				});
			}

			scenesToCreate.unshift(sceneData);
			return scene;
		}
		
		public function destroyPreviousScenes():void {
			destroyAllButRunningExcept(lastCreatedscene);
		}

		/**
		 * Destroy all but running scenes.
		 */
		protected function destroyAllButRunning() : void {
			var sceneData : SceneManagerSceneData;
			while ((sceneData = scenesToCreate.pop()) != null) {
				removesceneFromCE(sceneData);
			}

			for each (var rscene : SceneManagerSceneData in runningscenes)
				if (scenesToDestroy.indexOf(rscene) < 0)
					scenesToDestroy.unshift(rscene);
		}

		/**
		 * Destroy all but running scenes except specific by scene data.
		 */
		protected function destroyAllButRunningExcept(sceneData : SceneManagerSceneData) : void {
			for each (var std : SceneManagerSceneData in scenesToCreate) {
				if (std == sceneData)
					continue;
				removesceneFromCE(sceneData);
			}
			scenesToCreate.length = 0;

			for each (var rscene : SceneManagerSceneData in runningscenes)
				if (scenesToDestroy.indexOf(rscene) == -1)
					scenesToDestroy.unshift(rscene);
			removeSceneManagerSceneDataFromVector(sceneData, scenesToDestroy);
		}

		protected function collectscenes() : void {
			if (scenesToDestroy.length > 0) {
				var sceneData : SceneManagerSceneData;
				while ((sceneData = scenesToDestroy.pop()) != null) {
					removesceneFromCE(sceneData);
					removeSceneManagerSceneDataFromVector(sceneData, runningscenes);
				}
			}
		}

		protected function createscenes() : void {
			if (scenesToCreate.length > 0) {
				var sceneData : SceneManagerSceneData;
				while ((sceneData = scenesToCreate.pop()) != null) {
					runningscenes.push(sceneData);
					addsceneToCE(sceneData);
				}
			}
		}

		protected function removesceneFromCE(sceneData : SceneManagerSceneData) : void {
			sceneData.scene.playing = false;
			sceneData.destroy();
			_ce.citrus_internal::removeScene(sceneData.scene);
			onsceneRemoved.dispatch(sceneData.scene);
			sceneData.scene = null;
		}

		protected function addsceneToCE(sceneData : SceneManagerSceneData) : void {
			lastCreatedscene = sceneData;
			
			_ce.citrus_internal::addSceneOver(sceneData.scene);
			
			if(sceneData.scene.preload()) {
				sceneData.preloading = true;
				sceneData.scene.playing = false;
			}else {
				if (sceneData.transitionTween != null)
					sceneData.transitionTween.start();
				sceneData.scene.initialize();
				sceneData.scene.playing = true;
			}
			
			onsceneAdded.dispatch(sceneData.scene);
		}

		protected function removeSceneManagerSceneDataFromVector(st : SceneManagerSceneData, v : Vector.<SceneManagerSceneData>) : void {
			var i : int = v.indexOf(st);
			if (i > -1) v.splice(i, 1);
		}

		citrus_internal function update(timeDelta : Number) : void {
			for each (var sceneData : SceneManagerSceneData in runningscenes)
				if (sceneData.scene != null && sceneData.scene.playing)
					sceneData.scene.update(timeDelta);

			_ce.onPostUpdate.dispatch();

			collectscenes();
			createscenes();
		}

		public function destroy() : void {
			destroyAllButRunning();
			for each (var sceneData : SceneManagerSceneData in runningscenes) {
				if (sceneData.scene != null)
					sceneData.scene.destroy();
			}
			runningscenes.length = 0;
			levelProgression.length = 0;

			onsceneAdded.removeAll();
			onsceneRemoved.removeAll();
		}

		protected function createObjectWithArgs(type : Class, args : Array = null) : IScene {
			if (args == null)
				return new type() as IScene;
			else if (args.length == 1)
				return new type(args[0]) as IScene;
			else if (args.length == 2)
				return new type(args[0], args[1]) as IScene;
			else if (args.length == 3)
				return new type(args[0], args[1], args[2]) as IScene;
			else if (args.length == 4)
				return new type(args[0], args[1], args[2], args[3]) as IScene;
			else
				return null;
		}

		/**
		 * used for backwards compatibility when _ce.scene is read. will return the last created scene,
		 * which is not necessarily the most visible one on screen as more than 2 scene could run at a time.
		 */
		public function getCurrentScene() : IScene {
			
			if (!lastCreatedscene)
				return null;
			
			return lastCreatedscene.scene;
		}

		/**
		 * used for backwards compatibility (called when CitrusEngine.scene is set)
		 */
		public function setCurrentScene(value : IScene) : void {
			destroyAllButRunning();

			if (value == null)
				return;

			var sceneData : SceneManagerSceneData = new SceneManagerSceneData("scene(anonymous)", Object(value).constructor as Class);
			sceneData.scene = value;
			lastCreatedscene = sceneData;
			scenesToCreate.unshift(sceneData);
		}

		/**
		 * Get the name of a scene object, as defined in sceneManager when the scene definition was added with sceneManager.add()
		 */
		public function getSceneName(scene : IScene) : String {
			var sceneData : SceneManagerSceneData;

			for each (sceneData in runningscenes)
				if (sceneData.scene == scene)
					return sceneData.name;

			for each (sceneData in scenesToCreate)
				if (sceneData.scene == scene)
					return sceneData.name;

			for each (sceneData in scenesToDestroy)
				if (sceneData.scene == scene)
					return sceneData.name;

			return null;
		}

		/**
		 * sets a sequence of level names to be used with startLevelProgression,gotoLevel,nextLevel,previousLevel
		 */
		public function setLevelNames(names : Array) : void {
			levelProgression = names;
		}

		/**
		 * if level names are set with setLevelNames, this will start the first scene in the list of levels.
		 */
		public function startLevelProgression() : void {
			currentLevel = 0;
			start(levelProgression[currentLevel]);
		}

		/**
		 * if level names are set with setLevelNames, this will get the level name from the list and start the corresponding scene.
		 */
		public function gotoLevel(level : int = 0) : Boolean {
			if (level > -1 && level < levelProgression.length - 1) {
				start(levelProgression[currentLevel]);
				return true;
			}
			return false;
		}

		/**
		 * if level names are set with setLevelNames, this will go to the next level of the list. (stops at the end)
		 */
		public function nextLevel() : Boolean {
			if (currentLevel + 1 > levelProgression.length - 1)
				return false;
			currentLevel++;
			start(levelProgression[currentLevel]);
			return true;
		}

		/**
		 * if level names are set with setLevelNames, this will go to the previous level of the list. (stops at the beginning)
		 */
		public function previousLevel() : Boolean {
			if (currentLevel - 1 < 0)
				return false;
			currentLevel--;
			start(levelProgression[currentLevel]);
			return true;
		}
	}
}