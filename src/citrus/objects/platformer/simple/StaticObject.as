package citrus.objects.platformer.simple {

	import citrus.objects.CitrusSprite;

	/**
	 * An object that does not move (probably your platform or wall).
	 */
	public class StaticObject extends CitrusSprite {

		public function StaticObject(params:Object = null) {
			super(params);
		}
	}
}
