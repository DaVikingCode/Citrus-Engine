package citrus.core {

	import citrus.view.ACitrusView;
	
	/**
	 * Take a look on the 2 respective scenes to have some information on the functions.
	 */
	public interface IScene {
		
		function destroy():void;
		
		function get view():ACitrusView;
		
		function preload():Boolean;
		
		function onPreloadComplete(event:*):void;
		
		function initialize():void;
		
		function get playing():Boolean;
		function set playing(value:Boolean):void;
		
		function update(timeDelta:Number):void;
		
		function add(object:CitrusObject):CitrusObject;
		
		function remove(object:CitrusObject):void;
		
		function removeImmediately(object:CitrusObject):void;
		
		function getObjectByName(name:String):CitrusObject;
		
		function getFirstObjectByType(type:Class):CitrusObject;
		
		function getObjectsByType(type:Class):Vector.<CitrusObject>;
	}
}
