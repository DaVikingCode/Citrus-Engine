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
		
		public function changeSize(radius:Number):void {
			
			radius *= 0.5; // = radius /2
			
			this.graphics.clear();
			
			if (radius > 0) {
				this.graphics.beginFill(_color);
				this.graphics.drawCircle(0, 0, radius);
				this.graphics.endFill();
			}
		} 
	}
}
