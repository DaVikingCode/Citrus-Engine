package games.live4sales.nape.characters {

	import games.live4sales.nape.objects.Block;
	import games.live4sales.nape.objects.Cash;
	import games.live4sales.nape.weapons.Bag;
	import games.live4sales.utils.Grid;

	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.Material;

	import com.citrusengine.objects.NapePhysicsObject;
	import com.citrusengine.physics.PhysicsCollisionCategories;

	import org.osflash.signals.Signal;

	/**
	 * @author Aymeric
	 */
	public class ShopsWoman extends NapePhysicsObject {
		
		public static const SHOPSWOMAN:CbType = new CbType();
		
		public var speed:Number = 21;
		public var life:uint = 4;
		public var fighting:Boolean = false;
		
		public var onTouchLeftSide:Signal;

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
			
			var velocity:Vec2 = _body.velocity;
			
			velocity.x = -speed;
			
			_body.velocity = velocity;
				
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
		
		override protected function createMaterial():void {
			
			_material = new Material(0, 0, 0, 1, 0);
		}
			
		override protected function createFilter():void {
			
			_body.setShapeFilters(new InteractionFilter(PhysicsCollisionCategories.Get("BadGuys"), PhysicsCollisionCategories.GetAllExcept("BadGuys")));
		}
		
		override protected function createConstraint():void {
			
			_body.space = _nape.space;			
			_body.cbTypes.add(SHOPSWOMAN);
		}
			
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			var self:ShopsWoman = callback.int1.userData.myData;
			var other:NapePhysicsObject = callback.int2.userData.myData;
			
			if (other is SalesWoman || other is Block || other is Cash)
				self.fighting = true;
				
			else if (other is Bag) {
				self.life--;
				//cEvt.contact.Disable();
			}
		}
			
		override public function handleEndContact(callback:InteractionCallback):void {
			
			var self:ShopsWoman = callback.int1.userData.myData;
			var other:NapePhysicsObject = callback.int2.userData.myData;
			
			if (other is SalesWoman || other is Block || other is Cash)
				self.fighting = false;
		}
		
		protected function updateAnimation():void {
			
			_animation = fighting ? "attack" : "walk";
		}

	}
}
