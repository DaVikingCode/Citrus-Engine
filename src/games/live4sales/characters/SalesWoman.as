package games.live4sales.characters {

	import Box2DAS.Dynamics.ContactEvent;

	import games.live4sales.assets.Assets;
	import games.live4sales.utils.Grid;
	import games.live4sales.weapons.Bag;

	import starling.display.Image;

	import com.citrusengine.objects.platformer.box2d.Cannon;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Aymeric
	 */
	public class SalesWoman extends Cannon {
		
		public var life:uint = 2;
		
		private var _timerHurt:Timer;

		public function SalesWoman(name:String, params:Object = null) {
			
			super(name, params);
			
			_timerHurt = new Timer(1000);
			_timerHurt.addEventListener(TimerEvent.TIMER, _removeLife);
		}
			
		override public function destroy():void {
			
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.removeEventListener(ContactEvent.END_CONTACT, handleEndContact);
			
			_timerHurt.removeEventListener(TimerEvent.TIMER, _removeLife);
			_timerHurt = null;
			
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
			
		override protected function createFixture():void {
			
			_fixture = _body.CreateFixture(_fixtureDef);
			_fixture.m_reportBeginContact = true;
			_fixture.m_reportEndContact = true;
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.addEventListener(ContactEvent.END_CONTACT, handleEndContact);
		}
		
		protected function handleBeginContact(cEvt:ContactEvent):void {
			
			if (cEvt.other.GetBody().GetUserData() is ShopsWoman) {
				
				if (!_timerHurt.running)
					_timerHurt.start();
			}
		}
		
		protected function handleEndContact(cEvt:ContactEvent):void {
			
			if (cEvt.other.GetBody().GetUserData() is ShopsWoman) {
				
				if (_timerHurt.running)
					_timerHurt.stop();
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
