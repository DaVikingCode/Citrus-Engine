package mobilenapestarling {

	import com.citrusengine.objects.platformer.nape.Sensor;

	/**
	 * @author Aymeric
	 */
	public class Particle extends Sensor {
		
		private var _hero:MobileHero;

		public function Particle(name:String, params:Object = null) {
			
			super(name, params);
			
			_hero = _ce.state.getFirstObjectByType(MobileHero) as MobileHero;
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (this.x < _hero.x - 100)
				this.kill = true;
		}

	}
}
