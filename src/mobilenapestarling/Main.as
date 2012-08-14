package mobilenapestarling {

	import com.citrusengine.core.CitrusEngine;

	import flash.geom.Rectangle;

	[SWF(frameRate="60")]
	
	/**
	 * @author Aymeric
	 */
	public class Main extends CitrusEngine {
		
		public function Main() {

			// landscape mode!
			setUpStarling(true, 1, new Rectangle(0, 0, stage.fullScreenHeight, stage.fullScreenWidth));
			
			state = new MobileNapeStarlingGameState();
		}
		
		override public function setUpStarling(debugMode:Boolean = false, antiAliasing:uint = 1, viewport:Rectangle = null):void {
			
			super.setUpStarling(debugMode, antiAliasing, viewport);
			
			// set iPhone size, used for Starling contentScaleFactor
			// landscape mode!
			_starling.stage.stageWidth  = 480;
			_starling.stage.stageHeight = 320;
		}
	}
}
