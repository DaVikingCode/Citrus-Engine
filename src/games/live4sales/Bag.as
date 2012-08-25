package games.live4sales {

	import com.citrusengine.objects.platformer.box2d.Missile;

	/**
	 * @author Aymeric
	 */
	public class Bag extends Missile {

		public function Bag(name:String, params:Object = null) {
			super(name, params);
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			if (x > 480)
				kill = true;
		}

	}
}
