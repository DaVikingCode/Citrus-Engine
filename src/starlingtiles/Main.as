package starlingtiles {

	import com.citrusengine.core.StarlingCitrusEngine;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	//[SWF(backgroundColor="#000000", frameRate="60", width="1280", height="720")]
	
	/**
	 * @author Nick Pinkham
	 */
	public class Main extends StarlingCitrusEngine {
		
		public function Main():void {
			
			setUpStarling(true);
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _levelLoaded);
			loader.load(new URLRequest("levels/starlingtiles_demo_level.swf"));
		}
		
		private function _levelLoaded(evt:Event):void {
			
			state = new StarlingTilesGameState(evt.target.loader.content);
			
			evt.target.removeEventListener(Event.COMPLETE, _levelLoaded);
			evt.target.loader.unloadAndStop();
		}
	}
	
}