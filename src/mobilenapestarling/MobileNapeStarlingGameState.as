package mobilenapestarling {

	import mobilenapestarling.assets.Assets;

	import nape.callbacks.InteractionCallback;

	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.extensions.particles.PDParticleSystem;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import com.citrusengine.core.StarlingState;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.platformer.nape.Platform;
	import com.citrusengine.physics.nape.Nape;
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
		
		[Embed(source="/../embed/ArialFont.fnt", mimeType="application/octet-stream")] private var _fontConfig:Class;
		[Embed(source="/../embed/ArialFont.png")] private var _fontPng:Class;

		[Embed(source="/../embed/yellowParticle.pex", mimeType="application/octet-stream")] private var _particleConfig:Class;
		[Embed(source="/../embed/yellowParticle.png")] private var _particlePng:Class;
		
		[Embed(source="/../embed/particlePicked.xml", mimeType="application/octet-stream")] private var _particlePickedConfig:Class;
		[Embed(source="/../embed/particlePicked.png")] private var _particlePickedPng:Class;
		
		private var _mobileHero:MobileHero;
		private var _score:TextField;
		
		private var _particlePicked:CitrusSprite;
		private var _particlePickedMC:MovieClip;
		
		private var _back1:CitrusSprite, _back2:CitrusSprite, _back3:CitrusSprite;

		private var _timerParticle:Timer;
		private var _psconfig:XML;
		private var _psTexture:Texture;

		public function MobileNapeStarlingGameState() {

			super();
		}

		override public function initialize():void {

			super.initialize();

			Assets.contentScaleFactor = Starling.current.contentScaleFactor;
			
			var nape:Nape = new Nape("nape");
			//nape.visible = true;
			add(nape);
			
			var gameLength:uint = 25000;
			
			add(new CitrusSprite("backgroud", {parallax:0.02, view:new Image(Assets.getTexture("Background"))}));
			
			var bitmap:Bitmap = new _fontPng();
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new _fontConfig());
			TextField.registerBitmapFont(new BitmapFont(texture, xml));
			
			_score = new TextField(50, 20, "0", "ArialMT");
			_score.x = stage.stageWidth - _score.width;
			addChild(_score);
			
			_back1 = new CitrusSprite("back1", {y:50, width:847, view:new Image(Assets.getAtlasTexture("yellow1"))});
			_back2 = new CitrusSprite("back2", {y:50, x:847, width:777, view:new Image(Assets.getAtlasTexture("yellow2"))});
			_back3 = new CitrusSprite("back3", {y:50, x: 847 + 777, width:702, view:new Image(Assets.getAtlasTexture("yellow3"))});
			add(_back1);
			add(_back2);
			add(_back3);
			
			var heroAnim:AnimationSequence = new AnimationSequence(Assets.getTextureAtlas("Hero"), ["fly", "descent", "stop", "ascent", "throughPortal", "jump", "ground"], "fly", 30, true);
			StarlingArt.setLoopAnimations(["fly"]);

			_mobileHero = new MobileHero("hero", {x:40, y:150, width:80, height:75, jumpHeight:175, jumpAcceleration:5, view:heroAnim});
			add(_mobileHero);
			
			texture = Texture.fromBitmap(new _particlePickedPng());
			xml = new XML(new _particlePickedConfig());
			var textureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			_particlePickedMC = new MovieClip(textureAtlas.getTextures("particlePicked"), 30);
			_particlePickedMC.loop = false;
			_particlePickedMC.stop();
			_particlePickedMC.addEventListener(Event.COMPLETE, _hideParticlePickedMc);
			_particlePicked = new CitrusSprite("particlePicked", {x:_mobileHero.x, y:_mobileHero.y, view:_particlePickedMC});
			add(_particlePicked);

			_psconfig = new XML(new _particleConfig());
			_psTexture = Texture.fromBitmap(new _particlePng());

			add(new Platform("platformBot", {x:gameLength / 2, y:320, width:gameLength, height:10}));

			view.setupCamera(_mobileHero, new MathVector(_mobileHero.width, 0), new Rectangle(0, 0, gameLength, 0), new MathVector(.25, .05));

			_timerParticle = new Timer(500);
			_timerParticle.addEventListener(TimerEvent.TIMER, _particleCreation);
			_timerParticle.start();	
		}
			
		override public function destroy():void {
			
			TextField.unregisterBitmapFont("ArialMT");
			removeChild(_score, true);
			
			_particlePickedMC.removeEventListener(Event.COMPLETE, _hideParticlePickedMc);
			
			_timerParticle.stop();
			_timerParticle.removeEventListener(TimerEvent.TIMER, _particleCreation);
			
			super.destroy();
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (_particlePicked && _mobileHero) {
			
				_particlePicked.x = _mobileHero.x - _mobileHero.width - _particlePicked.width - 25;
				_particlePicked.y = _mobileHero.y - _mobileHero.height - _particlePicked.height + 10;
				
				//switch background positions
				if (_mobileHero.x + stage.stageWidth > _back1.x + _back1.width)
					_back2.x = _back1.x + _back1.width;
					
				if (_mobileHero.x + stage.stageWidth > _back2.x + _back2.width)
					_back3.x = _back2.x + _back2.width;
					
				if (_mobileHero.x + stage.stageWidth > _back3.x + _back3.width)
					_back1.x = _back3.x + _back3.width;
				
			}
		}

		private function _particleCreation(tEvt:TimerEvent):void {

			var random:uint = Math.random() * 4;
			
			if (random > 1) {

				var particleSystem:PDParticleSystem = new PDParticleSystem(_psconfig, _psTexture);
				particleSystem.start();
				particleSystem.touchable = false;

				var positionX:uint = _mobileHero.x + stage.stageWidth + Math.random() * 300;
				var positionY:uint = 50 + Math.random() * 250;
				var particle:Particle = new Particle("particle", {x:positionX, y:positionY, view:particleSystem});
				add(particle);
				particle.onBeginContact.addOnce(_particleTouched);
			}
		}

		private function _particleTouched(interactionCallback:InteractionCallback):void {
			
			_particlePickedMC.visible = true;
			_particlePickedMC.currentFrame = 0;
			_particlePickedMC.play();
			
			_score.text = String(uint(_score.text)+1);
			
			interactionCallback.int1.userData.myData.kill = true;
		}

		private function _hideParticlePickedMc(evt:Event):void {
			_particlePickedMC.visible = false;
		}
	}
}
