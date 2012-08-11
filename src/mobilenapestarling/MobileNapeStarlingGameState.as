package mobilenapestarling {
	
	import nape.callbacks.InteractionCallback;

	import starling.core.Starling;
	import starling.display.Image;
	import starling.extensions.particles.PDParticleSystem;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import com.citrusengine.core.StarlingState;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.platformer.nape.Platform;
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
		
		[Embed(source="../embed/ArialFont.fnt", mimeType="application/octet-stream")]
		private var _fontConfig:Class;
		
		[Embed(source="../embed/ArialFont.png")]
		private var _fontPng:Class;

		[Embed(source="../embed/yellowParticle.pex", mimeType="application/octet-stream")]
		private var _particleConfig:Class;

		[Embed(source="../embed/yellowParticle.png")]
		private var _particlePng:Class;
		
		[Embed(source="../embed/yellowBackground.png")]
		private var _backgroundPng:Class;
		
		[Embed(source="../embed/yellow1.png")]
		private var _backPng1:Class;
		
		[Embed(source="../embed/yellow2.png")]
		private var _backPng2:Class;
		
		[Embed(source="../embed/yellow3.png")]
		private var _backPng3:Class;
		
		private var _mobileHero:MobileHero;
		private var _score:TextField;
		
		private var _back1:CitrusSprite, _back2:CitrusSprite, _back3:CitrusSprite;

		private var _timerParticle:Timer;
		private var _psconfig:XML;
		private var _psTexture:Texture;

		public function MobileNapeStarlingGameState() {

			super();
		}

		override public function initialize():void {

			super.initialize();

			var gameLength:uint = 10000;

			var nape:Nape = new Nape("nape");
			//nape.visible = true;
			add(nape);
			
			add(new CitrusSprite("backgroud", {parallax:0.05, view:Image.fromBitmap(new _backgroundPng())}));
			
			_back1 = new CitrusSprite("back1", {y:50, width:847, view:Image.fromBitmap(new _backPng1())});
			_back2 = new CitrusSprite("back2", {y:50, x:847, width:777, view:Image.fromBitmap(new _backPng2())});
			_back3 = new CitrusSprite("back3", {y:50, x: 847 + 777, width:702, view:Image.fromBitmap(new _backPng3())});
			add(_back1);
			add(_back2);
			add(_back3);
			
			var bitmap:Bitmap = new _fontPng();
			var ftTexture:Texture = Texture.fromBitmap(bitmap);
			var ftXML:XML = XML(new _fontConfig());
			TextField.registerBitmapFont(new BitmapFont(ftTexture, ftXML));
			
			_score = new TextField(50, 20, "0", "ArialMT");
			_score.x = stage.stageWidth - _score.width;
			addChild(_score);

			bitmap = new _heroPng();
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

			_timerParticle = new Timer(300);
			_timerParticle.addEventListener(TimerEvent.TIMER, _particleCreation);
			_timerParticle.start();
		}
			
		override public function destroy():void {
			
			TextField.unregisterBitmapFont("ArialMT");
			removeChild(_score);
			
			_timerParticle.stop();
			_timerParticle.removeEventListener(TimerEvent.TIMER, _particleCreation);
			
			super.destroy();
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			//switch background positions
				
			if (_mobileHero.x + stage.stageWidth > _back1.x + _back1.width)
				_back2.x = _back1.x + _back1.width;
				
			if (_mobileHero.x + stage.stageWidth > _back2.x + _back2.width)
				_back3.x = _back2.x + _back2.width;
				
			if (_mobileHero.x + stage.stageWidth > _back3.x + _back3.width)
				_back1.x = _back3.x + _back3.width;
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
				sensor.onBeginContact.addOnce(_particleTouched);
			}
		}

		private function _particleTouched(interactionCallback:InteractionCallback):void {
			
			_score.text = String(uint(_score.text)+1);
			
			interactionCallback.int1.userData.myData.kill = true;
		}
	}
}
