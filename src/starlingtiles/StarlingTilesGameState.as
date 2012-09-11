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
			nape.visible = true; // -> to see the debug view!
			add(nape);
			
			// create objects from our level made with Flash Pro
			ObjectMaker.FromMovieClip(_level);
			
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