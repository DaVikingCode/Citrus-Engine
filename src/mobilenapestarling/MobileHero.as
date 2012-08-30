package mobilenapestarling {

	import nape.callbacks.CbType;
	import nape.callbacks.InteractionType;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.geom.Vec2;

	import com.citrusengine.objects.platformer.nape.Hero;
	import com.citrusengine.objects.platformer.nape.Platform;

	/**
	 * @author Aymeric
	 */
	public class MobileHero extends Hero {
		
		public var jumpDecceleration:Number = 7;

		private var _mobileInput:MobileInput;
		private var _preListener:PreListener;

		public function MobileHero(name:String, params:Object = null) {
			
			super(name, params);

			_mobileInput = new MobileInput();
			_mobileInput.initialize();
		}

		override public function destroy():void {
			
			_preListener.space = null;
			_preListener = null;
			
			_mobileInput.destroy();

			super.destroy();
		}

		override public function update(timeDelta:Number):void {
			
			var velocity:Vec2 = _body.velocity;

			velocity.x = 100;

			if (_mobileInput.screenTouched) {
				
				if (_onGround) {
					
					velocity.y = -jumpHeight;
					_onGround = false;
					
				} else if (velocity.y < 0)
					velocity.y -= jumpAcceleration;
				else
					velocity.y -= jumpDecceleration;
			}

			_body.velocity = velocity;
			
			_updateAnimation();
		}

		private function _updateAnimation():void {
			
			if (_mobileInput.screenTouched) {
				
				_animation = _body.velocity.y < 0 ? "jump" :  "ascent";
				
			} else if (_onGround)
				_animation = "fly";
			else
				_animation = "descent";
		}

		override protected function createConstraint():void {
			
			super.createConstraint();

			_preListener = new PreListener(InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, handlePreContact);
			_body.space.listeners.add(_preListener);
		}

		override public function handlePreContact(callback:PreCallback):PreFlag {
			
			if (callback.int2.userData.myData is Platform)
				_onGround = true;

			return PreFlag.ACCEPT;
		}
	}
}
