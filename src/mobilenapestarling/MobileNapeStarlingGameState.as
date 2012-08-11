package mobilenapestarling {

	import com.citrusengine.objects.platformer.nape.Sensor;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import com.citrusengine.core.StarlingState;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.platformer.nape.Platform;
	import com.citrusengine.physics.Nape;
	import com.citrusengine.view.starlingview.AnimationSequence;
	import com.citrusengine.view.starlingview.StarlingArt;

	import flash.display.Bitmap;
	import flash.geom.Rectangle;

	/**
	 * @author Aymeric
	 */
	public class MobileNapeStarlingGameState extends StarlingState {
		
		[Embed(source="../embed/heroMobile.xml", mimeType="application/octet-stream")]
		private var _heroConfig:Class;
		
		[Embed(source="../embed/heroMobile.png")]
		private var _heroPng:Class;
		
		private var _mobileHero:MobileHero;

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
			
			_mobileHero = new MobileHero("hero", {x:40, y:00, width:80, height:75, jumpHeight:175, jumpAcceleration:5, view:heroAnim});
			add(_mobileHero);
			
			//add(new Sensor("sensor", {x:350, y:300}));
			
			add(new Platform("platformBot", {x:0, y:stage.stageHeight - 10, width:gameLength, height:10}));
			
			view.setupCamera(_mobileHero, new MathVector(_mobileHero.width, 0), new Rectangle(0, 0, gameLength, 450), new MathVector(.25, .05));
		}

	}
}
