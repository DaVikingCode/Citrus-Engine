package games.live4sales.nape.weapons {

	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;

	import com.citrusengine.objects.platformer.nape.Missile;
	import com.citrusengine.physics.PhysicsCollisionCategories;

	/**
	 * @author Aymeric
	 */
	public class Bag extends Missile {

		public function Bag(name:String, params:Object = null) {
			super(name, params);
		}
		
		override public function update(timeDelta:Number):void {
			
			if (!_exploded)
				_body.velocity = _velocity;
			else
				_body.velocity = new Vec2();
			
			if (x > 480)
				kill = true;
		}
			
		override public function handleBeginContact(callback:InteractionCallback):void {
			explode();
		}
			
		override protected function createFilter():void {
			
			_body.setShapeFilters(new InteractionFilter(PhysicsCollisionCategories.Get("Level"), PhysicsCollisionCategories.GetAllExcept("Level")));
		}
	}
}
