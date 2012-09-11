package com.citrusengine.utils {

	import com.citrusengine.core.CitrusEngine;

	import flash.system.Capabilities;

	/**
	 * @author Aymeric
	 */
	public class Mobile {

		public function Mobile() {

		}

		static public function isIOS():Boolean {
			return (Capabilities.version.substr(0, 3) == "IOS");
		}

		static public function isAndroid():Boolean {
			return (Capabilities.version.substr(0, 3) == "AND");
		}

		static public function isLandscapeMode():Boolean {

			var ce:CitrusEngine = CitrusEngine.getInstance();

			return ce.stage.stageWidth > ce.stage.stageHeight ? true : false;
		}
		
		static public function isRetina():Boolean {
			
			if (Mobile.isIOS()) {
				
				var ce:CitrusEngine = CitrusEngine.getInstance();
				
				return (ce.stage.fullScreenWidth == 640 || ce.stage.fullScreenWidth == 1536 || ce.stage.fullScreenHeight == 640 || ce.stage.fullScreenHeight == 1536);
				
			} else 
				return false;
		}

		static public function isIpad():Boolean {

			if (Mobile.isIOS()) {

				var ce:CitrusEngine = CitrusEngine.getInstance();
				
				return (ce.stage.fullScreenWidth == 768 || ce.stage.fullScreenWidth == 1536 || ce.stage.fullScreenHeight == 768 || ce.stage.fullScreenHeight == 1536);

			} else
				return false;
		}
	}
}
