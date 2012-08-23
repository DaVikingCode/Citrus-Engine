package games.osmos {

	import nape.geom.Vec2;

	import com.citrusengine.core.State;
	import com.citrusengine.physics.Nape;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	/**
	 * @author Aymeric
	 */
	public class OsmosGameState extends State {
		
		private var _clickedAtom:Atom;

		public function OsmosGameState() {
			super();
		}

		override public function initialize():void {

			super.initialize();

			var nape:Nape = new Nape("nape", {gravity:new Vec2()});
			//nape.visible = true;
			add(nape);

			var atom:Atom, radius:Number;
			
			for (var i:uint = 0; i < 10; ++i) {

				for (var j:uint = 0; j < 10; ++j) {
					
					radius = Math.random() * 20;
					atom = new Atom("cell"+i+j, {x:i * 50, y:j * 50, radius:radius, view:new AtomArt(radius), registration:"topLeft"});
					add(atom);
					(view.getArt(atom) as DisplayObject).addEventListener(MouseEvent.MOUSE_DOWN, _handleGrab);
				}
			}
			
			stage.addEventListener(MouseEvent.MOUSE_UP, _handleRelease);
		}


		private function _handleGrab(mEvt:MouseEvent):void {

			_clickedAtom = view.getObjectFromArt(mEvt.currentTarget) as Atom;

			if (_clickedAtom)
				_clickedAtom.enableHolding(mEvt.currentTarget.parent);
		}

		private function _handleRelease(mEvt:MouseEvent):void {
			_clickedAtom.disableHolding();
		}
	}
}
