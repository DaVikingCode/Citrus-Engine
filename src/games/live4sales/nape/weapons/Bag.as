package games.live4sales.nape.weapons {

	import nape.callbacks.InteractionCallback;
	import nape.geom.Vec2;

	import com.citrusengine.objects.platformer.nape.Missile;

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
			
		override protected function createConstraint():void {
			super.createConstraint();
			
			//_fixtureDef.filter.categoryBits = Box2DCollisionCategories.Get("Level");
			//_fixtureDef.filter.maskBits = Box2DCollisionCategories.GetAllExcept("Level");
		}
	}
}
