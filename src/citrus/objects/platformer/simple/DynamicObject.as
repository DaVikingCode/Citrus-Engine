package citrus.objects.platformer.simple {

	import citrus.objects.CitrusSprite;

	/**
	 * An object that will be moved away from overlapping during a collision (probably your hero or something else that moves).
	 */
	public class DynamicObject extends CitrusSprite {

		public function DynamicObject(name:String, params:Object = null) {
			
			super(name, params);
		}
	}
}
