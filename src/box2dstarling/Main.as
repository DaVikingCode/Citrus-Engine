package box2dstarling {

	import com.citrusengine.core.IState;
	import com.citrusengine.core.StarlingCitrusEngine;
	import com.citrusengine.utils.LevelManager;

	[SWF(frameRate="60")]
	
	/**
	 * @author Aymeric
	 */
	public class Main extends StarlingCitrusEngine {
		
		public function Main() {
			
			setUpStarling(true);
			
			gameData = new MyGameData();
			
			levelManager = new LevelManager(ALevel);
			levelManager.onLevelChanged.add(_onLevelChanged);
			levelManager.levels = gameData.levels;
			levelManager.gotoLevel();
		}
		
		private function _onLevelChanged(lvl:ALevel):void {

			state = lvl;

			lvl.lvlEnded.add(_nextLevel);
			lvl.restartLevel.add(_restartLevel);
		}

		private function _nextLevel():void {

			levelManager.nextLevel();
		}

		private function _restartLevel():void {

			state = levelManager.currentLevel as IState;
		}
	}
}
