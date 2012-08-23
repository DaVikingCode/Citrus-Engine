package games.osmos {

	import flash.display.Sprite;

	/**
	 * @author Aymeric
	 */
	public class AtomArt extends Sprite {
		
		private var _color:uint;

		public function AtomArt(radius:Number) {
			
			_color = Math.random() * 0xFFFFFF;
			
			this.graphics.beginFill(_color);
			this.graphics.drawCircle(0, 0, radius);
			this.graphics.endFill();
		}
		
		public function changeSize(diameter:Number):void {
			
			this.graphics.clear();
			
			if (diameter > 0) {
				this.graphics.beginFill(_color);
				this.graphics.drawCircle(0, 0, diameter * 0.5);
				this.graphics.endFill();
			}
		} 
	}
}
