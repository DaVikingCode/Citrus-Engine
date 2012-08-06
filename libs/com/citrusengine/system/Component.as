package com.citrusengine.system {

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;

	/**
	 * @author Aymeric
	 */
	public class Component extends CitrusObject {
		
		public var entity:Entity;
		
		protected var _ce:CitrusEngine;

		public function Component(name:String, params:Object = null) {
			
			super(name, params);
			
			_ce = CitrusEngine.getInstance();
		}
		
		public function initialize():void {
			
		}
			
		override public function destroy():void {
			
			super.destroy();
		}

		override public function update(timeDelta:Number):void {
		}

	}
}
