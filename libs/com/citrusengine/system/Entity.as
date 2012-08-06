package com.citrusengine.system {

	import com.citrusengine.core.CitrusObject;

	import flash.utils.Dictionary;

	/**
	 * @author Aymeric
	 */
	public class Entity extends CitrusObject {

		public var components:Dictionary;

		public function Entity(name:String, params:Object = null) {
			
			super(name, params);

			components = new Dictionary();
		}

		public function add(component:Component):Entity {
			
			components[component.name] = component;

			return this;
		}
		
		public function remove(component:Component):void {
			
			if (components[component.name]) {
				component.destroy();
				delete components[component.name];
			}
		}
		
		public function initialize():void {
			
			for each (var component:Component in components) {
				component.initialize();
			}
		}	
		
		override public function destroy():void {
			
			for each (var component:Component in components) {
				component.destroy();
			}
			
			components = null;
			
			super.destroy();
		}

		override public function update(timeDelta:Number):void {
			
			for each (var component:Component in components) {
				component.update(timeDelta);
			}
		}
	}
}
