package com.citrusengine.utils {

	import org.osflash.signals.Signal;
	
	/**
	 * This is an (optional) abstract class to store your game's data such as lives, score, levels...
	 * 
	 * <p>You should extend this class and instantiate it into your main class using the gameData variable.
	 * You can dispatch a signal, <code>dataChanged</code>, if you update one of your data.
	 * For more information, watch the example below.</p> 
	 */
	dynamic public class AGameData {
		
		public var dataChanged:Signal;
		
		protected var _lives:int = 3;
		protected var _score:int = 0;
		protected var _timeleft:int = 300;
		
		protected var _levels:Array;
		
		public function AGameData() {
			
			dataChanged = new Signal(String, Object);
		}

		public function get lives():int {
			return _lives;
		}

		public function set lives(lives:int):void {
			
			_lives = lives;
			
			dataChanged.dispatch("lives", _lives);
		}

		public function get score():int {
			return _score;
		}

		public function set score(score:int):void {
			
			_score = score;
			
			dataChanged.dispatch("score", _score);
		}

		public function get timeleft():int {
			return _timeleft;
		}

		public function set timeleft(timeleft:int):void {
			
			_timeleft = timeleft;
			
			dataChanged.dispatch("timeleft", _timeleft);
		}
		
		public function destroy():void {
			
			dataChanged.removeAll();
		}
	}
}
