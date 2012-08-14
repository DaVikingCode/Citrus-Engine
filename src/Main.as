package {

	import objectpooling.ObjectPoolingGameState;

	import com.citrusengine.core.CitrusEngine;

	[SWF(frameRate="60")]
	
	/**
	 * @author Aymeric
	 */
	public class Main extends CitrusEngine {
		
		public function Main() {

			// copy & paste here the Main of the differents src project,
			// be careful with the package & import!
			// import libraries from the libs folder, select just one Nape swc.
			
			//setUpStarling(true);
			
			state = new ObjectPoolingGameState();
		}
	}
}
