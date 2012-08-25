package games.live4sales.characters {

	import games.live4sales.assets.Assets;
	import games.live4sales.weapons.Bag;

	import starling.display.Image;

	import com.citrusengine.objects.platformer.box2d.Cannon;

	import flash.events.TimerEvent;

	/**
	 * @author Aymeric
	 */
	public class SalesWoman extends Cannon {

		public function SalesWoman(name:String, params:Object = null) {
			
			super(name, params);
		}
			
		override public function destroy():void {
			super.destroy();
		}

		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
		}
		
		override protected function _fire(tEvt:TimerEvent):void {

			var missile:Bag;

			if (startingDirection == "right")
				missile = new Bag("Missile", {x:x + width, y:y, width:missileWidth, height:missileHeight, speed:missileSpeed, angle:missileAngle, explodeDuration:missileExplodeDuration, fuseDuration:missileFuseDuration, view:new Image(Assets.getAtlasTexture("bag"))});
			else
				missile = new Bag("Missile", {x:x - width, y:y, width:missileWidth, height:missileHeight, speed:-missileSpeed, angle:missileAngle, explodeDuration:missileExplodeDuration, fuseDuration:missileFuseDuration, view:new Image(Assets.getAtlasTexture("bag"))});

			_ce.state.add(missile);
			missile.onExplode.addOnce(_damage);
		}

		override protected function _updateAnimation():void {
			
			if (_firing)
				_animation = "attack";
			else
				_animation = "stand";
		}

	}
}
