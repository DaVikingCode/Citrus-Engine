package starlingtiles 
{
	import nape.geom.Vec2;

	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.StarlingState;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.NapePhysicsObject;
	import com.citrusengine.objects.platformer.nape.Hero;
	import com.citrusengine.objects.platformer.nape.Platform;
	import com.citrusengine.objects.platformer.nape.Sensor;
	import com.citrusengine.physics.nape.Nape;
	import com.citrusengine.utils.ObjectMaker2D;
	import com.citrusengine.view.starlingview.AnimationSequence;
	import com.citrusengine.view.starlingview.StarlingArt;
	import com.citrusengine.view.starlingview.StarlingTileSystem;

	import org.osflash.signals.Signal;

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;

	/**
	 * @author Nick Pinkham
	 */
	public class StarlingTilesGameState extends StarlingState 
	{
		[Embed(source="../../embed/crate.png")]
		private var _cratePng:Class;
		
		//[Embed(source = "../../embed/hero_static.png")]
		//private var _heroPng:Class;
		
		[Embed(source="../../embed/buckshot_platforming.xml", mimeType = "application/octet-stream")]
		private var _heroConfig:Class;
		
		[Embed(source="../../embed/buckshot_platforming_black.png")]
		private var _heroPng:Class;
		
		public var lvlEnded:Signal;
		public var restartLevel:Signal;
		
		protected var _ce:CitrusEngine;
		protected var _level:MovieClip;
		
		private var _hero:Hero;
		
		public function StarlingTilesGameState(level:MovieClip = null) 
		{
			super();
			
			_ce = CitrusEngine.getInstance();
			
			_level = level;
			
			lvlEnded = new Signal();
			restartLevel = new Signal();
			
			// Useful for not forgetting to import object from the Level Editor
			var objectsUsed:Array = [Hero, Platform, Sensor, CitrusSprite];
		}
 
		override public function initialize():void {
 
			super.initialize();
			
			var nape:Nape = new Nape("nape");
			nape.visible = false; // -> to see the debug view!
			add(nape);
			nape.gravity = new Vec2(0, 210);
			
			// create objects from our level made with Flash Pro
			ObjectMaker2D.FromMovieClip(_level);
			
			// the hero view from sprite sheet
			var heroBitmap:Bitmap = new _heroPng();
			var heroTexture:Texture = Texture.fromBitmap(heroBitmap);
			var xml:XML = XML(new _heroConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(heroTexture, xml);
			
			// get hero from movieclip
			_hero = Hero(getFirstObjectByType(Hero));
			_hero.view = new AnimationSequence(sTextureAtlas, ["walk", "idle", "jump", "hurt"], "idle");
			StarlingArt.setLoopAnimations(["walk"]);
			
			// setup camera to follow hero
			view.setupCamera(_hero, new MathVector(400, 300), new Rectangle(0, 0, 5000, 1024), new MathVector(0.25, 0.15));
			
			/*
			// set view
			var heroTexture:Texture = Texture.fromBitmap(new _heroPng());
			var heroImage:Image = new Image(heroTexture);
			_hero.view = heroImage;
			*/
			
			// movieclip on stage converted to tiles
			// background
			var tileSprite:CitrusSprite = new CitrusSprite("tileLowerBackground", { x:0, y:0, parallax:0.6 } );
			var tileSystem:StarlingTileSystem = new StarlingTileSystem(MovieClip(_level.getChildByName("tile_lower_background")), _hero);
			
			tileSystem.parallax = 0.6;
			tileSystem.name = tileSprite.name;
			tileSystem.tileWidth = 2048;
			tileSystem.tileHeight = 1024;
			tileSystem.blendMode = BlendMode.NONE;
			tileSystem.touchable = false;
			tileSystem.init();
			
			tileSprite.view = tileSystem;
			tileSprite.group = 0;
			add(tileSprite);
			
			
			if (Starling.current.context.driverInfo.toLowerCase().search("software") < 0) {
				
			// add upper background
			tileSprite = new CitrusSprite("tileUpperBackground", { x:0, y:0, parallax:0.8 } );
			tileSystem = new StarlingTileSystem(MovieClip(_level.getChildByName("tile_upper_background")), _hero);
			
			tileSystem.parallax = 0.8;
			tileSystem.name = tileSprite.name;
			tileSystem.tileWidth = 2048;
			tileSystem.tileHeight = 1024;
			tileSystem.touchable = false;
			tileSystem.init();
			
			tileSprite.view = tileSystem;
			tileSprite.group = 1;
			add(tileSprite);
			
			}
			
			// add player plane tiles via flash stage
			tileSprite = new CitrusSprite("tilePlayerPlane", { x:0, y:0 } );
			tileSystem = new StarlingTileSystem(MovieClip(_level.getChildByName("tile_player_plane")), _hero);
			
			tileSystem.name = tileSprite.name;
			tileSystem.tileWidth = 2048;
			tileSystem.tileHeight = 1024;
			tileSystem.touchable = false;
			tileSystem.init();
			
			tileSprite.view = tileSystem;
			tileSprite.group = 2;
			add(tileSprite);
			
			// check to see if software mode, if not drop a bunch of boxes
			if (Starling.current.context.driverInfo.toLowerCase().search("software") < 0) {
				var texture:Texture = Texture.fromBitmap(new  _cratePng());
				var image:Image;
				var physicObject:NapePhysicsObject;
				for (var i:uint = 0; i < 50; i++ ) {
					image = new Image(texture);
					physicObject = new NapePhysicsObject(("physicobject" + i), { x:Math.random() * stage.stageWidth, y:Math.random() * 300, width:60, height:60, view:image } );
					physicObject.group = 3;
					add(physicObject);
				}

			} else {
				var texture1:Texture = Texture.fromBitmap(new _cratePng());
				var image1:Image = new Image(texture1);
				var physicObject1:NapePhysicsObject = new NapePhysicsObject("physicobject", { x:Math.random() * stage.stageWidth, y:0, width:60, height:60, view:image1 } );
				physicObject1.group = 3;
				add(physicObject1);
			}
		}		
		
		override public function destroy():void {
			super.destroy();
		}
 
	}
 
}