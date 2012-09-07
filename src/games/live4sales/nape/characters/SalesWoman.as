package games.live4sales.nape.characters {

	import games.live4sales.assets.Assets;
	import games.live4sales.nape.weapons.Bag;
	import games.live4sales.utils.Grid;

	import nape.callbacks.InteractionCallback;
	import nape.phys.Material;

	import starling.display.Image;

	import com.citrusengine.objects.platformer.nape.Cannon;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Aymeric
	 */
	public class SalesWoman extends Cannon {
		
		public var life:uint = 2;
		
		public var timerHurt:Timer;

		public function SalesWoman(name:String, params:Object = null) {
			
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
			
			if (Grid.tabBaddies[group])
				_firing = true;
			else
				_firing = false;
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
		
		override protected function _fire(tEvt:TimerEvent):void {
			
			if (_firing) {

				var missile:Bag;
	
				if (startingDirection == "right")
					missile = new Bag("Missile", {x:x + width, y:y, group:group, width:missileWidth, height:missileHeight, offsetY:-30, speed:missileSpeed, angle:missileAngle, explodeDuration:missileExplodeDuration, fuseDuration:missileFuseDuration, view:new Image(Assets.getAtlasTexture("bag", "Objects"))});
				else
					missile = new Bag("Missile", {x:x - width, y:y, group:group, width:missileWidth, height:missileHeight, offsetY:-30, speed:-missileSpeed, angle:missileAngle, explodeDuration:missileExplodeDuration, fuseDuration:missileFuseDuration, view:new Image(Assets.getAtlasTexture("bag", "Objects"))});
	
				_ce.state.add(missile);
			}
		}
		
		override protected function _updateAnimation():void {
			
			if (_firing)
				_animation = "fire";
			else
				_animation = "stand";
		}

	}
}
