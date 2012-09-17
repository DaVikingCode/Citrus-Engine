package tiledmap {

	import com.citrusengine.core.CitrusEngine;

	[SWF(frameRate="60")]

	/**
	* @author Aymeric
	*/
	public class Main extends CitrusEngine {
		
		[Embed(source="/../embed/tiledmap/map.tmx", mimeType="application/octet-stream")]
		private const _Map:Class;

		public function Main() {
			
            state = new TiledMapGameState(XML(new _Map()));
		}
	}
}