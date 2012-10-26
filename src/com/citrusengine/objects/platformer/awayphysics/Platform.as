package com.citrusengine.objects.platformer.awayphysics {
	
	import com.citrusengine.objects.AwayPhysicsObject;

	/**
	 * @author Aymeric
	 */
	public class Platform extends AwayPhysicsObject {
		
		private var _oneWay:Boolean = false;

		public function Platform(name:String, params:Object = null) {
			
			super(name, params);
		}
		
		override protected function defineBody():void {
			
			_mass = 0;
			
			super.defineBody();
		}
	}
}
