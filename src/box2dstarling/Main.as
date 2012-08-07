package {

	import box2dstarling.ALevel;
	import box2dstarling.MyGameData;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.IState;
	import com.citrusengine.utils.LevelManager;	

	[SWF(frameRate="60")]
	
	public class Main extends CitrusEngine {
		
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
