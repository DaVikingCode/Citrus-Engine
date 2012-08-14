package mobilenapestarling {

	import com.citrusengine.core.CitrusEngine;

	import flash.geom.Rectangle;

	[SWF(frameRate="60")]
	
	/**
	 * @author Aymeric
	 */
	public class Main extends CitrusEngine {
		
		public function Main() {

			setUpStarling(true);
			
			state = new MobileNapeStarlingGameState();
		}
		
		override public function setUpStarling(debugMode:Boolean = false, antiAliasing:uint = 1, viewport:Rectangle = null):void {
			
			super.setUpStarling(debugMode, antiAliasing, viewport);
			
			// set iPhone size, used for Starling contentScaleFactor
			_starling.stage.stageWidth  = 320;
			_starling.stage.stageHeight = 480;
		}
	}
}
