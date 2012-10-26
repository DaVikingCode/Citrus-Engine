package com.citrusengine.system {

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;

	/**
	 * A component is an object dedicate to a (single) task for an entity : physics, collision, inputs, view, movement... management.
	 * You will use an entity when your object become too much complex to manage into a single class.
	 * Preferably if you use a physics engine, create at first the entity's physics component.
	 * It extends the CitrusObject class to enjoy its params setter.
	 */
	public class Component extends CitrusObject {
		
		public var entity:Entity;
		
		protected var _ce:CitrusEngine;

		public function Component(name:String, params:Object = null) {
			
			_ce = CitrusEngine.getInstance();
			
			if (params == null)
				params = {type:"component"};
			else
				params["type"] = "component";
			
			super(name, params);
		}
		
		/**
		 * Register other components in your component class in this function.
		 * It should be call after all components have been added to an entity.
		 */
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize();
		}
		
		/**
		 * Destroy the component, most of the time called by its entity.
		 */
		override public function destroy():void {
			
			super.destroy();
		}
		
		/**
		 * Perform an update on the component, called by its entity.
		 */
		override public function update(timeDelta:Number):void {
		}

	}
}
