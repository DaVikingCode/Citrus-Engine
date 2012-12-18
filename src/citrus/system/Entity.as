package citrus.system {

	import citrus.core.CitrusObject;

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
			
			doAddComponent(component, component.name);
			
			return this;
		}
		
		protected function doAddComponent(component:Component, componentName:String):Boolean
		{
			if(componentName == "")
			{
				trace("A component name was not specified. This might cause problems later.");
			}
			
			if(components[componentName])
				throw Error("A component with name '" + componentName + "' already exists on this entity.");
			
			if(component.entity)
			{
				if(component.entity == this)
				{
					trace("Component with name '" + componentName + "' already has entity ('" + this.name + "') defined. Manually defining components is no longer needed");
					components[componentName] = component;
					return true;
				}
				
				throw Error("The component '" + componentName + "' already has an owner. ('" + component.entity.name + "')");
			}
			
			
			
			component.entity = this;
			components[componentName] = component;
			return true;
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
		
		public function lookupComponentByType(componentType:Class):Component
		{
			var component:Component;
			for each(component in components)
			{
				if(component is componentType)
					return component;
			}
			
			return null;
		}
		
		public function lookupComponentsByType(componentType:Class):Array
		{
			var list:Array = [];
			var component:Component;
			for each(component in components)
			{
				if(component is componentType)
					list.push(component);
			}
			
			return list;
		}
		
		/**
		 * After all the components have been added call this function to perform an init on them.
		 * Mostly used if you want to access to other components through the entity.
		 */
		override public function initialize(poolObjectParams:Object = null):void {
			
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
