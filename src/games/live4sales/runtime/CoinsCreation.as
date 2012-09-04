package games.live4sales.runtime {

	import games.live4sales.assets.Assets;
	import games.live4sales.events.MoneyEvent;
	import games.live4sales.objects.Coin;

	import starling.core.Starling;
	import starling.display.Sprite;

	import com.citrusengine.core.CitrusEngine;

	import flash.events.TimerEvent;
	import flash.utils.Timer;
		
	/**
	 * @author Aymeric
	 */
	public class CoinsCreation extends Sprite {
		
		private var _ce:CitrusEngine;
		
		private var _timerCoins:Timer;
		
		private var _coin:Coin;
		
		public function CoinsCreation() {
			
			_ce = CitrusEngine.getInstance();
			
			_timerCoins = new Timer(2000);
			_timerCoins.start();
			_timerCoins.addEventListener(TimerEvent.TIMER, _tick);
		}
		
		public function destroy():void {
			
			_timerCoins.stop();
			_timerCoins.removeEventListener(TimerEvent.TIMER, _tick);
		}

		private function _tick(tEvt:TimerEvent):void {
			
			if (Math.random() > 0.5) {
				
				_coin = new Coin(Assets.getAtlasTexture("coin", "Objects"));
				addChild(_coin);
				_coin.onDestroyed.add(_coinDestroy);
				
				_coin.x = Math.random() * Starling.current.viewPort.width - Starling.current.viewPort.x - _coin.width;
				_coin.y = Math.random() * Starling.current.viewPort.height - Starling.current.viewPort.y - _coin.height;
			}
		}

		private function _coinDestroy(coin:Coin, touched:Boolean):void {
			
			removeChild(coin);
			
			if (touched)
				_ce.dispatchEvent(new MoneyEvent(MoneyEvent.PICKUP_MONEY));
		}
	}
}
