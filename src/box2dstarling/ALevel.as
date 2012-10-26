package box2dstarling {

	import Box2D.Dynamics.Contacts.b2Contact;

	import starling.display.Quad;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.Color;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.StarlingState;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.platformer.box2d.Baddy;
	import com.citrusengine.objects.platformer.box2d.Hero;
	import com.citrusengine.objects.platformer.box2d.Platform;
	import com.citrusengine.objects.platformer.box2d.Sensor;
	import com.citrusengine.physics.box2d.Box2D;
	import com.citrusengine.utils.ObjectMaker2D;
	import com.citrusengine.view.starlingview.AnimationSequence;

	import org.osflash.signals.Signal;

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;

	/**
	 * @author Aymeric
	 */
	public class ALevel extends StarlingState {
		
		public var lvlEnded:Signal;
		public var restartLevel:Signal;
		
		protected var _ce:CitrusEngine;
		protected var _level:MovieClip;
		
		protected var _hero:Hero;
		
		[Embed(source="/../embed/Hero.xml", mimeType="application/octet-stream")]
		private var _heroConfig:Class;
		
		[Embed(source="/../embed/Hero.png")]
		private var _heroPng:Class;
		
		[Embed(source="/../embed/ArialFont.fnt", mimeType="application/octet-stream")]
		private var _fontConfig:Class;
		
		[Embed(source="/../embed/ArialFont.png")]
		private var _fontPng:Class;
		
		protected var _maskDuringLoading:Quad;
		protected var _percentTF:TextField;

		public function ALevel(level:MovieClip = null) {
			
			super();
			
			_ce = CitrusEngine.getInstance();
			
			_level = level;
			
			lvlEnded = new Signal();
			restartLevel = new Signal();
			
			// Useful for not forgetting to import object from the Level Editor
			var objectsUsed:Array = [Hero, Platform, Baddy, Sensor, CitrusSprite];
		}

		override public function initialize():void {
			
			super.initialize();
			
			var box2d:Box2D = new Box2D("Box2D");
			//box2d.visible = true;
			add(box2d);
			
			// hide objects loading in the background
			_maskDuringLoading = new Quad(stage.stageWidth, stage.stageHeight);
			_maskDuringLoading.color = 0x000000;
			_maskDuringLoading.x = (stage.stageWidth - _maskDuringLoading.width) / 2;
			_maskDuringLoading.y = (stage.stageHeight - _maskDuringLoading.height) / 2;
			addChild(_maskDuringLoading);
			
			// create a textfield to show the loading %
			var bitmap:Bitmap = new _fontPng();
			var ftTexture:Texture = Texture.fromBitmap(bitmap);
			var ftXML:XML = XML(new _fontConfig());
			TextField.registerBitmapFont(new BitmapFont(ftTexture, ftXML));
			
			_percentTF = new TextField(400, 200, "", "ArialMT");
			_percentTF.fontSize = BitmapFont.NATIVE_SIZE;
			_percentTF.color = Color.WHITE;
			_percentTF.autoScale = true;
			_percentTF.x = (stage.stageWidth - _percentTF.width) / 2;
			_percentTF.y = (stage.stageHeight - _percentTF.height) / 2;
			
			addChild(_percentTF);
			
			// when the loading is completed...
			view.loadManager.onLoadComplete.addOnce(_handleLoadComplete);
			
			// create objects from our level made with Flash Pro
			ObjectMaker2D.FromMovieClip(_level);
			
			// the hero view come from a sprite sheet, for the baddy that was a swf
			bitmap = new _heroPng();
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new _heroConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			
			_hero = Hero(getFirstObjectByType(Hero));
			_hero.view = new AnimationSequence(sTextureAtlas, ["walk", "duck", "idle", "jump", "hurt"], "idle");
			_hero.hurtDuration = 500;

			view.setupCamera(_hero, new MathVector(320, 240), new Rectangle(0, 0, 1550, 450), new MathVector(.25, .05));
		}
		
		protected function _changeLevel(contact:b2Contact):void {
			
			if (Box2DPhysicsObject.CollisionGetOther(Sensor(getObjectByName("endLevel")), contact) is Hero) {
				lvlEnded.dispatch();
			}
		}
		
		protected function _handleLoadComplete():void {
			
			removeChild(_percentTF, true);
			removeChild(_maskDuringLoading, true);
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			var percent:uint = view.loadManager.bytesLoaded / view.loadManager.bytesTotal * 100;

			if (percent < 99) {
				_percentTF.text = percent.toString() + "%";
			}
		}

		override public function destroy():void {
			
			TextField.unregisterBitmapFont("ArialMT");
			
			super.destroy();
		}
	}
}
