package mobilenapestarling {

	import com.citrusengine.core.StarlingCitrusEngine;

	import flash.geom.Rectangle;
	import flash.system.Capabilities;

	[SWF(backgroundColor="#000000", frameRate="60")]
	
	/**
	 * @author Aymeric
	 */
	public class Main extends StarlingCitrusEngine {

		public var compileForMobile:Boolean;
		public var isIpad:Boolean = false;
		
		public function Main() {

			compileForMobile = isIOS() ? true : false;
			
			if (compileForMobile) {
				
				// detect if iPad
				isIpad = (stage.fullScreenWidth == 768 || stage.fullScreenWidth == 1536);
				
				if (isIpad)
					setUpStarling(true, 1, new Rectangle(32, 64, stage.fullScreenWidth, stage.fullScreenHeight));
				else
					setUpStarling(true, 1, new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight));
			} else 
				setUpStarling(true);
			
			state = new MobileNapeStarlingGameState();
		}
		
		override public function setUpStarling(debugMode:Boolean = false, antiAliasing:uint = 1, viewport:Rectangle = null):void {
			
			super.setUpStarling(debugMode, antiAliasing, viewport);
			
			if (compileForMobile) {
				// set iPhone & iPad size, used for Starling contentScaleFactor
				// landscape mode!
				_starling.stage.stageWidth = isIpad ? 512 : 480;
				_starling.stage.stageHeight = isIpad ? 384 : 320;
			}
		}
		
		public function isAndroid():Boolean {
    		return (Capabilities.version.substr(0,3) == "AND");
		}
		
		public function isIOS():Boolean {
	    	return (Capabilities.version.substr(0,3) == "IOS");
		}
	}
}
