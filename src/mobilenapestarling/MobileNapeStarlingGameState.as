package mobilenapestarling {

	import nape.callbacks.InteractionCallback;

	import starling.core.Starling;
	import starling.extensions.particles.PDParticleSystem;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import com.citrusengine.core.StarlingState;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.platformer.nape.Platform;
	import com.citrusengine.objects.platformer.nape.Sensor;
	import com.citrusengine.physics.Nape;
	import com.citrusengine.view.starlingview.AnimationSequence;
	import com.citrusengine.view.starlingview.StarlingArt;

	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	/**
	 * @author Aymeric
	 */
	public class MobileNapeStarlingGameState extends StarlingState {

		[Embed(source="../embed/heroMobile.xml", mimeType="application/octet-stream")]
		private var _heroConfig:Class;

		[Embed(source="../embed/heroMobile.png")]
		private var _heroPng:Class;

		[Embed(source="../embed/yellowParticle.pex", mimeType="application/octet-stream")]
		private var _particleConfig:Class;

		[Embed(source="../embed/yellowParticle.png")]
		private var _particlePng:Class;

		private var _mobileHero:MobileHero;

		private var _timerParticle:Timer;
		private var _psconfig:XML;
		private var _psTexture:Texture;

		public function MobileNapeStarlingGameState() {

			super();
		}

		override public function initialize():void {

			super.initialize();

			var gameLength:uint = 10000;

			var napePhysics:Nape = new Nape("nape");
			napePhysics.visible = true;
			add(napePhysics);

			var bitmap:Bitmap = new _heroPng();
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new _heroConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			var heroAnim:AnimationSequence = new AnimationSequence(sTextureAtlas, ["fly", "descent", "stop", "ascent", "throughPortal", "jump", "ground"], "fly", 30, true);
			StarlingArt.setLoopAnimations(["fly"]);

			_mobileHero = new MobileHero("hero", {x:40, y:300, width:80, height:75, jumpHeight:175, jumpAcceleration:5, view:heroAnim});
			add(_mobileHero);

			_psconfig = new XML(new _particleConfig());
			_psTexture = Texture.fromBitmap(new _particlePng());

			add(new Platform("platformBot", {x:0, y:stage.stageHeight - 10, width:gameLength, height:10}));

			view.setupCamera(_mobileHero, new MathVector(_mobileHero.width, 0), new Rectangle(0, 0, gameLength, 450), new MathVector(.25, .05));

			_timerParticle = new Timer(1000);
			_timerParticle.addEventListener(TimerEvent.TIMER, _particleCreation);
			_timerParticle.start();
		}

		private function _particleCreation(tEvt:TimerEvent):void {

			var random:uint = Math.random() * 4;

			if (random > 1) {

				var particleSystem:PDParticleSystem = new PDParticleSystem(_psconfig, _psTexture);
				particleSystem.start();
				Starling.juggler.add(particleSystem);

				var positionX:uint = _mobileHero.x + 500 + Math.random() * 300;
				var positionY:uint = 50 + Math.random() * 250;
				var sensor:Particle = new Particle("Sensor", {x:positionX, y:positionY, view:particleSystem});
				add(sensor);
				sensor.onBeginContact.add(_particleTouched);
			}
		}

		private function _particleTouched(interactionCallback:InteractionCallback):void {
			
			interactionCallback.int1.userData.myData.kill = true;
		}

	}
}
