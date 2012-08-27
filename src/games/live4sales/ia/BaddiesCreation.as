package games.live4sales.ia {

	import games.live4sales.utils.Grid;
	import games.live4sales.characters.ShopsWoman;

	import com.citrusengine.core.CitrusEngine;

	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * @author Aymeric
	 */
	public class BaddiesCreation {
		
		private var _ce:CitrusEngine;		
		
		private var _timerShopsWomen:Timer;
		
		public function BaddiesCreation() {
			
			_ce = CitrusEngine.getInstance();
			
			_timerShopsWomen = new Timer(1500);
			_timerShopsWomen.start();
			_timerShopsWomen.addEventListener(TimerEvent.TIMER, _tick);
		}
		
		public function destroy():void {
			
			_timerShopsWomen.stop();
			_timerShopsWomen.removeEventListener(TimerEvent.TIMER, _tick);
		}

		private function _tick(tEvt:TimerEvent):void {
			
			var casePosition:Array = Grid.getBaddyPosition(0, Grid.getRandomHeight());
			
			var shopswoman:ShopsWoman = new ShopsWoman("shopswoman", {x:480, y:casePosition[1], group:casePosition[2], speed:1});
			_ce.state.add(shopswoman);
			shopswoman.onTouchLeftSide.add(_endGame);
			
			Grid.tabBaddies[casePosition[2]] = true;
		}
		
		private function _endGame():void {

			trace('game over');
		}
	}
}
