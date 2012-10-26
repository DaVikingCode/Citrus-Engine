package box2dstarling {

	import Box2D.Dynamics.Contacts.b2Contact;

	import starling.extensions.particles.PDParticleSystem;
	import starling.extensions.particles.ParticleSystem;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;

	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.objects.platformer.box2d.Hero;
	import com.citrusengine.objects.platformer.box2d.Sensor;

	import flash.display.MovieClip;

	/**
	 * @author Aymeric
	 */
	public class Level1 extends ALevel {
		
		[Embed(source="/../embed/Particle.pex", mimeType="application/octet-stream")]
		private var _particleConfig:Class;

		[Embed(source="/../embed/ParticleTexture.png")]
		private var _particlePng:Class;
		
		private var _particleSystem:ParticleSystem;
		
		private var _bmpFontTF:TextField;
		private var _popUp:Sensor;

		public function Level1(level:MovieClip = null) {
			super(level);
		}

		override public function initialize():void {
			
			super.initialize();
			
			var psconfig:XML = new XML(new _particleConfig());
			var psTexture:Texture = Texture.fromBitmap(new _particlePng());

			_particleSystem = new PDParticleSystem(psconfig, psTexture);
			_particleSystem.start();
			
			var endLevel:Sensor = Sensor(getObjectByName("endLevel"));
			endLevel.view = _particleSystem;
			
			_bmpFontTF = new TextField(400, 200, "The Citrus Engine goes on Stage3D thanks to Starling", "ArialMT");
			_bmpFontTF.fontSize = BitmapFont.NATIVE_SIZE;
			_bmpFontTF.color = Color.WHITE;
			_bmpFontTF.autoScale = true;
			_bmpFontTF.x = (stage.stageWidth - _bmpFontTF.width) / 2;
			_bmpFontTF.y = (stage.stageHeight - _bmpFontTF.height) / 2;
			
			addChild(_bmpFontTF);
			_bmpFontTF.visible = false;
			
			_popUp = Sensor(getObjectByName("popUp"));
			
			endLevel.onBeginContact.add(_changeLevel);
			
			_popUp.onBeginContact.add(_showPopUp);
			_popUp.onEndContact.add(_hidePopUp);
		}
		
		private function _showPopUp(contact:b2Contact):void {
			
			if (Box2DPhysicsObject.CollisionGetOther(_popUp, contact) is Hero) {
				_bmpFontTF.visible = true;
			}
		}
		
		private function _hidePopUp(contact:b2Contact):void {
			
			if (Box2DPhysicsObject.CollisionGetOther(_popUp, contact) is Hero) {
				_bmpFontTF.visible = false;
			}
		}
		
		override public function destroy():void {
			
			removeChild(_bmpFontTF, true);

			super.destroy();
		}

	}
}
