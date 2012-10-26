package games.live4sales {

	import com.citrusengine.core.StarlingCitrusEngine;
	import com.citrusengine.utils.Mobile;

	import flash.geom.Rectangle;

	[SWF(backgroundColor="#000000", frameRate="60")]
	
	/**
	 * @author Aymeric
	 */
	public class Main extends StarlingCitrusEngine {

		public var compileForMobile:Boolean;
		public var isIpad:Boolean = false;
		
		public function Main() {

			compileForMobile = Mobile.isIOS() ? true : Mobile.isAndroid() ? true : false;
			
			if (compileForMobile) {
				
				isIpad = Mobile.isIpad();
				
				if (isIpad)
					setUpStarling(true, 1, new Rectangle(64, 128, stage.fullScreenWidth, stage.fullScreenHeight));
				else
					setUpStarling(true, 1, new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight));
			} else 
				setUpStarling(true);
			
			// select Box2D or Nape demo
			state = new NapeLive4Sales();
			//state = new Box2DLive4Sales();
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
	}
}
