package awayphysics.cadet3d {

	import away3d.debug.AwayStats;

	import com.citrusengine.core.State;
	import com.citrusengine.physics.AwayPhysics;
	import com.citrusengine.utils.ObjectMaker;
	import com.citrusengine.view.CitrusView;
	import com.citrusengine.view.away3dview.Away3DView;

	/**
	 * @author Aymeric
	 */
	public class Cadet3DGameState extends State {
		
		[Embed(source="/../embed/3D/simpletest.away3d4", mimeType="application/octet-stream")]
		private const _CADET_LEVEL:Class;

		public function Cadet3DGameState() {
			
			super();
		}

		override public function initialize():void {
			
			super.initialize();
			
			addChild(new AwayStats((view as Away3DView).viewRoot));
			
			var awayPhysics:AwayPhysics = new AwayPhysics("awayPhysics");
			awayPhysics.visible = true;
			add(awayPhysics);
			
			ObjectMaker.FromCadet3DEditor(XML(new _CADET_LEVEL()));
		}
		
		// Make sure and call this override to specify Away3D view.
		override protected function createView():CitrusView {

			return new Away3DView(this);
		}

	}
}
