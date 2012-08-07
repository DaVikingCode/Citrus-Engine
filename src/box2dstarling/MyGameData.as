package box2dstarling {

	import com.citrusengine.utils.AGameData;

	/**
	 * @author Aymeric
	 */
	public class MyGameData extends AGameData {

		public function MyGameData() {
			
			super();
			
			_levels = [[Level1, "levels/A1/LevelA1.swf"], [Level2, "levels/A2/LevelA2.swf"]];
		}
		
		public function get levels():Array {
			return _levels;
		}

		override public function destroy():void {
			
			super.destroy();
		}

	}
}
