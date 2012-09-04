package games.live4sales.nape.characters {

	import games.live4sales.nape.weapons.Bag;
	import games.live4sales.utils.Grid;

	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;

	import com.citrusengine.objects.NapePhysicsObject;

	import org.osflash.signals.Signal;

	/**
	 * @author Aymeric
	 */
	public class ShopsWoman extends NapePhysicsObject {
		
		public static const SHOPSWOMAN:CbType = new CbType();
		
		public var speed:Number = 21;
		public var life:uint = 4;
		
		public var onTouchLeftSide:Signal;
		
		private var _fighting:Boolean = false;

		public function ShopsWoman(name:String, params:Object = null) {
			
			super(name, params);
			
			onTouchLeftSide = new Signal();
		}

		override public function destroy():void {
			
			onTouchLeftSide.removeAll();
			
			super.destroy();
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (!_fighting) {
			
				var velocity:Vec2 = _body.velocity;
				
				velocity.x = -speed;
				
				_body.velocity = velocity;
			}
				
			if (x < 0) {
				onTouchLeftSide.dispatch();
				kill = true;
			}
			
			if (life == 0) {
				kill = true;
				Grid.tabBaddies[group] = false;
			} else {
				Grid.tabBaddies[group] = true;
			}
			
			updateAnimation();
		}
		
		override protected function createBody():void {
			
			super.createBody();
			
			_body.allowRotation = false;
		}
		
		override protected function createConstraint():void {
			
			_body.space = _nape.space;			
			_body.cbTypes.add(SHOPSWOMAN);
		}
			
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			var other:NapePhysicsObject = callback.int2.userData.myData;
			
			if (other is SalesWoman)
				_fighting = true;
				
			else if (other is Bag) {
				life--;
				//cEvt.contact.Disable();
			}
		}
			
		override public function handleEndContact(callback:InteractionCallback):void {
			
			var other:NapePhysicsObject = callback.int2.castBody.userData.myData;
			
			if (other is SalesWoman)
				_fighting = false;
		}
		
		protected function updateAnimation():void {
			
			_animation = _fighting ? "attack" : "walk";
		}

	}
}
