package tiledmap {

	import com.citrusengine.core.State;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.platformer.box2d.Hero;
	import com.citrusengine.objects.platformer.box2d.Platform;
	import com.citrusengine.physics.box2d.Box2D;
	import com.citrusengine.utils.ObjectMaker2D;
	import com.citrusengine.view.spriteview.SpriteArt;
	import flash.geom.Rectangle;

	
	/**
	 * @author Aymeric
	 */
	public class TiledMapGameState extends State {
		
		[Embed(source="/../embed/tiledmap/map.tmx", mimeType="application/octet-stream")]
		private const _Map:Class;
		
		[Embed(source="/../embed/tiledmap/Genetica-tiles.png")]
		private const _ImgTiles:Class;

		public function TiledMapGameState() {
			
			super();
			
			var objects:Array = [Hero, Platform];
		}

		override public function initialize():void {
			
			super.initialize();
			
			var box2D:Box2D = new Box2D("box2D");
			//box2D.visible = true;
			add(box2D);
			
			ObjectMaker2D.FromTiledMap(XML(new _Map()), _ImgTiles);
			
			var hero:Hero = getObjectByName("hero") as Hero;
			
			view.setupCamera(hero, new MathVector(stage.stageWidth / 2, 240), new Rectangle(0, 0, 1280, 640), new MathVector(.25, .05));
			
			(view.getArt(getObjectByName("foreground")) as SpriteArt).alpha = 0.3;
		}

	}
}
