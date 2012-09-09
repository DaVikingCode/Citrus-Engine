package starlingtiles {
	
	import com.citrusengine.utils.AGameData;
	
	/**
	 * @author Nick Pinkham
	 */
	public class MyGameData extends AGameData {
		
		public function MyGameData() {
			super();
			_levels = [ [Level1, "levels/starlingtiles_demo_level.swf"] ];
		}
		
		public function get levels():Array {
			return _levels;
		}
		
		override public function destroy():void {
			super.destroy();
		}
	}
	
}