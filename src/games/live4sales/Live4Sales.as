package games.live4sales {
	
	import Box2DAS.Common.V2;

	import com.citrusengine.core.StarlingState;
	import com.citrusengine.physics.Box2D;

	/**
	 * @author Aymeric
	 */
	public class Live4Sales extends StarlingState {
		
		public function Live4Sales() {
			super();
		}

		override public function initialize() : void {
			
			super.initialize();
			
			var box2D:Box2D = new Box2D("box2D", {gravity:new V2()});
			box2D.visible = true;
			add(box2D);
		}

	}
}
