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
		
		public var size:String = "";
		
		private var _preListener:PreListener;
		private var _onGoingInteraction:InteractionListener;

		private var _hand:PivotJoint;
		private var _mouseScope:DisplayObject;

		public function Atom(name:String, params:Object = null) {

			super(name, params);
		}
			
		override protected function createConstraint():void {
			
			super.createConstraint();
			
			// we need to ignore physics collision
			_preListener = new PreListener(InteractionType.ANY, ATOM, ATOM, handlePreContact);
			_nape.space.listeners.add(_preListener);
			_body.cbTypes.add(ATOM);
			
			_onGoingInteraction = new InteractionListener(CbEvent.ONGOING, InteractionType.ANY, ATOM, ATOM, handleOnGoingContact);
			
			_nape.space.listeners.add(_onGoingInteraction);

			_hand = new PivotJoint(_nape.space.world, null, new Vec2(), new Vec2());
			_hand.active = false;
			_hand.stiff = false;
			_hand.space = _nape.space;
			_hand.maxForce = 5;
		}

		override public function destroy():void {
			
			_nape.space.listeners.remove(_preListener);
			_nape.space.listeners.remove(_onGoingInteraction);
			
			_hand.space = null;

			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);
			
			if (_mouseScope)
				_hand.anchor1.setxy(_mouseScope.mouseX, _mouseScope.mouseY);
				
			var bodyDiameter:Number;
				
			if (size == "bigger") {
				bodyDiameter = _body.shapes.at(0).bounds.width;
				bodyDiameter > 100 ? _body.scaleShapes(1.003, 1.003) : _body.scaleShapes(1.01, 1.01); 
				bodyDiameter = _body.shapes.at(0).bounds.width;
				(view as AtomArt).changeSize(bodyDiameter);
				
			} else if (size == "smaller") {
				_body.scaleShapes(0.9, 0.9);
				bodyDiameter = _body.shapes.at(0).bounds.width;
				(view as AtomArt).changeSize(bodyDiameter);
				
				if (_body.shapes.at(0).bounds.width < 1)
					this.kill = true;
			}
			
			size = "";
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
			
			if (atom1.body.shapes.at(0).bounds.width > atom2.body.shapes.at(0).bounds.width) {
				 atom1.size = "bigger";
				 atom2.size = "smaller";
			} else {
				atom1.size = "smaller";
				atom2.size = "bigger";
			}
		}
			
		override public function handlePreContact(callback:PreCallback):PreFlag {
			
			return PreFlag.IGNORE;
		}

	}
}
