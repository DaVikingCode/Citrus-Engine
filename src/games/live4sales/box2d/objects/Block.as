package games.live4sales.box2d.objects {

	import Box2D.Dynamics.Contacts.b2Contact;

	import games.live4sales.box2d.characters.ShopsWoman;
	import games.live4sales.utils.Grid;

	import com.citrusengine.objects.Box2DPhysicsObject;
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

		override public function handleBeginContact(contact:b2Contact):void {
			
			if (Box2DPhysicsObject.CollisionGetOther(this, contact) is ShopsWoman) {
				
				if (!_timerHurt.running)
					_timerHurt.start();
			}
		}

		override public function handleEndContact(contact:b2Contact):void {
			
			if (Box2DPhysicsObject.CollisionGetOther(this, contact) is ShopsWoman) {
				
				if (_timerHurt && _timerHurt.running)
					_timerHurt.stop();
			}
		}
		
		private function _removeLife(tEvt:TimerEvent):void {
			life--;
		}
	}
}
