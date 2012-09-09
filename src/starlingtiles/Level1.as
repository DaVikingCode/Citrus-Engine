package starlingtiles {

	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.platformer.nape.Hero;
	import com.citrusengine.objects.platformer.nape.Sensor;
	import com.citrusengine.view.starlingview.StarlingTileSystem;

	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	/**
	 * @author Nick Pinkham
	 */
	public class Level1 extends ALevel {
		
		private var _hero:Hero;
		
		public function Level1(level:MovieClip = null) {
			super(level);
		}
		
		override public function initialize():void {
			
			super.initialize();
			
			var restartLevel:Sensor = Sensor(getObjectByName("restartLevel"));
			restartLevel.onBeginContact.add(_restartLevel);
			
			// get hero from movieclip
			_hero = Hero(getFirstObjectByType(Hero));
			
			// add background tiles via flash stage
			var px:Number = 0.6;
			// sprite is a movieclip on the stage
			var tileSprite:CitrusSprite = new CitrusSprite("tileLowerBackground", { x:0, y:0, parallax:px } );
			tileSprite.view = new StarlingTileSystem(_hero, MovieClip(_level.getChildByName("tile_lower_background")), px);
			tileSprite.view.name = tileSprite.name;
			tileSprite.group = 0;
			add(tileSprite);
			
			// add upper background
			px = 0.8;
			tileSprite = new CitrusSprite("tileUpperBackground", { x:0, y:0, parallax:px } );
			tileSprite.view = new StarlingTileSystem(_hero, MovieClip(_level.getChildByName("tile_upper_background")), px);
			tileSprite.view.name = tileSprite.name;
			tileSprite.group = 1;
			add(tileSprite);
			
			// add player plane tiles via flash stage
			tileSprite = new CitrusSprite("tilePlayerPlane", { x:0, y:0 } );
			tileSprite.view = new StarlingTileSystem(_hero, MovieClip(_level.getChildByName("tile_player_plane")));
			tileSprite.view.name = tileSprite.name;
			tileSprite.group = 2;
			add(tileSprite);
			
			// setup camera to follow hero
			view.setupCamera(_hero, new MathVector(640, 360), new Rectangle(0, 0, 5120, 1024), new MathVector(0.25, 0.15));
		}
		
		override public function destroy():void {
			
			super.destroy();
		}
	}
	
}