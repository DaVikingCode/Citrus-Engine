package games.live4sales.nape.objects {

	import games.live4sales.nape.characters.ShopsWoman;
	import games.live4sales.utils.Grid;

	import nape.callbacks.InteractionCallback;
	import nape.phys.Material;

	import com.citrusengine.objects.platformer.nape.Platform;

	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * @author Aymeric
	 */
	public class Block extends Platform {
		
		public var life:uint = 5;
		
		public var timerHurt:Timer;

		public function Block(name:String, params:Object = null) {
			
			super(name, params);
			
			timerHurt = new Timer(1000);
			timerHurt.addEventListener(TimerEvent.TIMER, _removeLife);
		}
		
		override public function destroy():void {
			
			timerHurt.removeEventListener(TimerEvent.TIMER, _removeLife);
			timerHurt = null;
			
			super.destroy();
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (life == 0) {
				kill = true;
				var tab:Array = Grid.getCaseId(x, y);
				
				Grid.tabObjects[tab[1]][tab[0]] = false;
			}
			
			_updateAnimation();
		}

		protected function _updateAnimation():void {
			
			if (life == 3)
				_animation = "block2";
			else if (life == 2)
				_animation = "block3";
			else if (life == 1)
				_animation = "blockDestroyed";
		}
		
		override protected function createMaterial():void {
			
			_material = new Material(0, 0, 0, 1, 0);
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			if (callback.int1.userData.myData is ShopsWoman) {
				
				if (!callback.int2.userData.myData.timerHurt.running)
					callback.int2.userData.myData.timerHurt.start();
			}
		}
		
		override public function handleEndContact(callback:InteractionCallback):void {
			
			if (callback.int1.userData.myData is ShopsWoman) {
				
				if (callback.int2.userData.myData.timerHurt)
					callback.int2.userData.myData.timerHurt.stop();
			}
		}
		
		private function _removeLife(tEvt:TimerEvent):void {
			life--;
		}
	}
}
