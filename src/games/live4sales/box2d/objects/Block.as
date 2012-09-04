package games.live4sales.box2d.objects {

	import Box2DAS.Dynamics.ContactEvent;

	import games.live4sales.box2d.characters.ShopsWoman;
	import games.live4sales.utils.Grid;

	import com.citrusengine.objects.platformer.box2d.Platform;

	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * @author Aymeric
	 */
	public class Block extends Platform {
		
		public var life:uint = 5;
		
		protected var _timerHurt:Timer;

		public function Block(name:String, params:Object = null) {
			
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
	}
}
