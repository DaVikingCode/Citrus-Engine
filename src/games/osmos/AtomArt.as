package games.osmos {

	import flash.display.Sprite;

	/**
	 * @author Aymeric
	 */
	public class AtomArt extends Sprite {
		
		private var _radius:Number;
		private var _color:uint;

		public function AtomArt(radius:Number) {
			
			_radius = radius;
			_color = Math.random() * 0xFFFFFF;
			
			this.graphics.beginFill(_color);
			this.graphics.drawCircle(0, 0, _radius);
			this.graphics.endFill();
		}
		
		public function changeSize(size:String):void {
			
			_radius = size == "bigger" ? _radius + 0.3 : _radius - 1;
			
			this.graphics.clear();
			
			if (_radius > 0) {
				this.graphics.beginFill(_color);
				this.graphics.drawCircle(0, 0, _radius);
				this.graphics.endFill();
			}
		} 
	}
}
