package citrus.core {

	import citrus.system.Entity;
	import citrus.system.components.ViewComponent;
	import citrus.view.ACitrusView;
	
	/**
	 * Take a look on the 2 respective states to have some information on the functions.
	 */
	public interface IState {
		
		function destroy():void;
		
		function get view():ACitrusView;
		
		function initialize():void;
		
		function update(timeDelta:Number):void;
		
		function add(object:CitrusObject):CitrusObject;
		
		function addEntity(entity:Entity, view:ViewComponent = null):Entity;
		
		function remove(object:CitrusObject):void;
		
		function getObjectByName(name:String):CitrusObject;
		
		function getFirstObjectByType(type:Class):CitrusObject;
		
		function getObjectsByType(type:Class):Vector.<CitrusObject>;
	}
}
