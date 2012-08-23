package games.osmos {

	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;

	import com.citrusengine.objects.NapePhysicsObject;

	import flash.display.DisplayObject;

	/**
	 * @author Aymeric
	 */
	public class Atom extends NapePhysicsObject {
		
		public static const ATOM:CbType = new CbType();
		
		public var _size:String = "";
		
		private var _preListener:PreListener;

		private var _hand:PivotJoint;
		private var _mouseScope:DisplayObject;

		public function Atom(name:String, params:Object = null) {

			super(name, params);
			
			_preListener = new PreListener(InteractionType.ANY, ATOM, CbType.ANY_BODY, handlePreContact);
			_body.space.listeners.add(_preListener);
			_body.cbTypes.add(ATOM);
			
			_nape.space.listeners.add(new InteractionListener(CbEvent.ONGOING, InteractionType.ANY, ATOM, CbType.ANY_BODY, handleOnGoingContact));

			_hand = new PivotJoint(_nape.space.world, null, new Vec2(), new Vec2());
			_hand.active = false;
			_hand.stiff = false;
			_hand.space = _nape.space;
			_hand.maxForce = 3;
		}

		override public function destroy():void {
			
			_hand.space = null;
			
			_preListener.space = null;
			_preListener = null;

			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);
			
			if (_mouseScope)
				_hand.anchor1.setxy(_mouseScope.mouseX, _mouseScope.mouseY);
				
			if (_size == "bigger") {
				_body.scaleShapes(1.01, 1.01);
				(view as AtomArt).changeSize(_size);
				_size = "";
				
			} else if (_size == "smaller") {
				_body.scaleShapes(0.9, 0.9);
				(view as AtomArt).changeSize(_size);
				_size = "";
				if (_body.shapes.at(0).bounds.width < 1)
					this.kill = true;
			}
		}

		public function enableHolding(mouseScope:DisplayObject):void {
			
			_mouseScope = mouseScope;
			
			var mp:Vec2 = new Vec2(mouseScope.mouseX, mouseScope.mouseY);
            var bodies:BodyList = _nape.space.bodiesUnderPoint(mp);
            for(var i:int = 0; i < bodies.length; ++i) {
                var b:Body = bodies.at(i);
                if(!b.isDynamic()) continue;
                _hand.body2 = b;
                _hand.anchor2 = b.worldToLocal(mp);
                _hand.active = true;
                break;
            }
			
		}

		public function disableHolding():void {
			
			_hand.active = false;
			_mouseScope = null;
		}
			
		protected function handleOnGoingContact(callback:InteractionCallback):void {
			
			var atom1:Atom = callback.int1.userData.myData as Atom;
			var atom2:Atom = callback.int2.userData.myData as Atom;
			
			if (atom1.radius > atom2.radius) {
				 atom1._size = "bigger";
				 atom2._size = "smaller";
			} else {
				atom1._size = "smaller";
				atom2._size = "bigger";
			}
		}
			
		override public function handlePreContact(callback:PreCallback):PreFlag {
			
			return PreFlag.IGNORE;
		}

	}
}
