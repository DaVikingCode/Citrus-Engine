package games.osmos {

	import com.citrusengine.core.State;
	import com.citrusengine.objects.platformer.nape.Platform;
	import com.citrusengine.physics.nape.Nape;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import nape.geom.Vec2;



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
			
			add(new Platform("platformTop", {x:stage.stageWidth / 2, y:0, width:stage.stageWidth, height:10}));
			add(new Platform("platformRight", {x:stage.stageWidth, y:stage.stageHeight / 2, width:10, height:stage.stageHeight}));
			add(new Platform("platformBot", {x:stage.stageWidth / 2, y:stage.stageHeight, width:stage.stageWidth, height:10}));
			add(new Platform("platformLeft", {x:0, y:stage.stageHeight / 2, width:10, height:stage.stageHeight}));

			var atom:Atom, radius:Number;
			
			for (var i:uint = 0; i < 10; ++i) {

				for (var j:uint = 0; j < 10; ++j) {
					
					radius = 3 + Math.random() * 30;
					atom = new Atom("atom"+i+j, {x:i * 50 + 40, y:j * 50 - 15, radius:radius, view:new AtomArt(radius), registration:"topLeft"});
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
