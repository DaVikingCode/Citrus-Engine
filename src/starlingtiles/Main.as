package starlingtiles {

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.IState;
	import com.citrusengine.utils.LevelManager;
	
	[SWF(backgroundColor="#FFFF00", frameRate="60", width="1280", height="720")]
	
	/**
	 * @author Nick Pinkham
	 */
	public class Main extends CitrusEngine {
		
		public function Main():void {
			
			setUpStarling(true, 16);
			
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