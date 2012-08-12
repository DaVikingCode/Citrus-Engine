package com.citrusengine.system {

	import com.citrusengine.core.CitrusObject;

	import flash.utils.Dictionary;

	/**
	 * A game entity is compound by components. The entity serves as a link to communicate between components.
	 * It extends the CitrusObject class to enjoy its params setter.
	 */
	public class Entity extends CitrusObject {

		public var components:Dictionary;

		public function Entity(name:String, params:Object = null) {
			
			if (params == null)
				params = {type:"entity"};
			else
				params["type"] = "entity";
			
			super(name, params);

			components = new Dictionary();
		}
		
		/**
		 * Add a component to the entity.
		 */
		public function add(component:Component):Entity {
			
			components[component.name] = component;

			return this;
		}
		
		/**
		 * Remove a component from the entity.
		 */
		public function remove(component:Component):void {
			
			if (components[component.name]) {
				component.destroy();
				delete components[component.name];
			}
		}
		
		/**
		 * After all the components have been added call this function to perform an init on them.
		 * Mostly used if you want to access to other components through the entity.
		 */
		override public function initialize():void {
			
			super.initialize();
			
			for each (var component:Component in components) {
				component.initialize();
			}
		}
		
		/**
		 * Destroy the entity and its components.
		 */
		override public function destroy():void {
			
			for each (var component:Component in components) {
				component.destroy();
			}
			
			components = null;
			
			super.destroy();
		}
		
		/**
		 * Perform an update on all entity's components.
		 */
		override public function update(timeDelta:Number):void {
			
			for each (var component:Component in components) {
				component.update(timeDelta);
			}
		}
	}
}
