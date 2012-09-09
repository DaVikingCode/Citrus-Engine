package starlingtiles 
{

	import nape.callbacks.InteractionCallback;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.StarlingState;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.platformer.nape.*;
	import com.citrusengine.physics.Nape;
	import com.citrusengine.utils.ObjectMaker;

	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
 
	/**
	 * @author Nick Pinkham
	 */
	public class ALevel extends StarlingState 
	{
		public var lvlEnded:Signal;
		public var restartLevel:Signal;
		
		protected var _ce:CitrusEngine;
		protected var _level:MovieClip;
		
		public function ALevel(level:MovieClip = null) 
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
		}
		
		protected function _changeLevel(cEvt:InteractionCallback):void {
			//trace("1", cEvt.int1.castBody.userData.myData);
			//trace("2", cEvt.int2.castBody.userData.myData);
			
			if (cEvt.int2.castBody.userData.myData is Hero) {
				lvlEnded.dispatch();
			}
		}
		
		protected function _restartLevel(cEvt:InteractionCallback):void {
			
			if (cEvt.int2.castBody.userData.myData is Hero) {
				restartLevel.dispatch();
			}
		}
		
		
		override public function destroy():void {
			super.destroy();
		}
 
	}
 
}