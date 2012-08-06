package com.citrusengine.objects.platformer.simple {

	import com.citrusengine.objects.CitrusSprite;

	/**
	 * An object that will be moved away from overlapping during a collision (probably your hero or something else that moves).
	 */
	public class DynamicObject extends CitrusSprite {

		public function DynamicObject(name:String, params:Object = null) {
			
			super(name, params);
		}
	}
}
