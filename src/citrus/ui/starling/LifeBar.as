package citrus.ui.starling {

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	import flash.geom.Point;
	
	/**
	 * A simple way to display a life bar. It removes life from right to left using its <code>ratio</code> variable between 0 and 1.
	 */
	public class LifeBar extends Sprite {

		private var mImage:Image;
		private var mRatio:Number;

		public function LifeBar(texture:Texture) {
			
			mRatio = 1.0;
			mImage = new Image(texture);
			addChild(mImage);
		}

		private function update():void {
			
			mImage.scaleX = mRatio;
			mImage.setTexCoords(1, new Point(mRatio, 0.0));
			mImage.setTexCoords(3, new Point(mRatio, 1.0));
		}

		public function get ratio():Number {
			return mRatio;
		}

		public function set ratio(value:Number):void {
			mRatio = Math.max(0.0, Math.min(1.0, value));
			update();
		}
	}
}