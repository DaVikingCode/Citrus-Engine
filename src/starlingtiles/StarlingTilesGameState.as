package starlingtiles 
{

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.StarlingState;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.platformer.nape.*;
	import com.citrusengine.physics.Nape;
	import com.citrusengine.utils.ObjectMaker;
	import com.citrusengine.view.starlingview.StarlingTileSystem;

	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
	import flash.geom.Rectangle;
 
	/**
	 * @author Nick Pinkham
	 */
	public class StarlingTilesGameState extends StarlingState 
	{
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
			
			// create objects from our level made with Flash Pro
			ObjectMaker.FromMovieClip(_level);
			
			// get hero from movieclip
			_hero = Hero(getFirstObjectByType(Hero));
			
			// movieclip on stage converted to tiles
			// background
			var tileSprite:CitrusSprite = new CitrusSprite("tileLowerBackground", { x:0, y:0, parallax:0.6 } );
			var tileSystem:StarlingTileSystem = new StarlingTileSystem(MovieClip(_level.getChildByName("tile_lower_background")), _hero);
			
			tileSystem.parallax = 0.6;
			tileSystem.name = tileSprite.name;
			tileSystem.tileWidth = 2048;
			tileSystem.tileHeight = 1024;
			tileSystem.init();
			
			tileSprite.view = tileSystem;
			tileSprite.group = 0;
			add(tileSprite);
			
			
			// add upper background
			tileSprite = new CitrusSprite("tileUpperBackground", { x:0, y:0, parallax:0.8 } );
			tileSystem = new StarlingTileSystem(MovieClip(_level.getChildByName("tile_upper_background")), _hero);
			
			tileSystem.parallax = 0.8;
			tileSystem.name = tileSprite.name;
			tileSystem.tileWidth = 2048;
			tileSystem.tileHeight = 1024;
			tileSystem.init();
			
			tileSprite.view = tileSystem;
			tileSprite.group = 1;
			add(tileSprite);
			
			
			// add player plane tiles via flash stage
			tileSprite = new CitrusSprite("tilePlayerPlane", { x:0, y:0 } );
			tileSystem = new StarlingTileSystem(MovieClip(_level.getChildByName("tile_player_plane")), _hero);
			
			tileSystem.name = tileSprite.name;
			tileSystem.tileWidth = 2048;
			tileSystem.tileHeight = 1024;
			tileSystem.init();
			
			tileSprite.view = tileSystem;
			tileSprite.group = 2;
			add(tileSprite);
			
			// setup camera to follow hero
			view.setupCamera(_hero, new MathVector(640, 360), new Rectangle(0, 0, 5000, 1024), new MathVector(0.25, 0.15));
		}		
		
		override public function destroy():void {
			super.destroy();
		}
 
	}
 
}