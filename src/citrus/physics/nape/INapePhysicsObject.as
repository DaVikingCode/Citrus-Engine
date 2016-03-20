package citrus.physics.nape {

	import nape.callbacks.InteractionCallback;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.phys.Body;
	
	/**
	 * An interface used by each Nape object. It helps to enable interaction between entity/component object and "normal" object.
	 */
	public interface INapePhysicsObject {
		
		function handleBeginContact(callback:InteractionCallback):void;
		function handleEndContact(callback:InteractionCallback):void;
		function handlePreContact(callback:PreCallback):PreFlag;
		function fixedUpdate():void;
		function get x():Number;
		function set x(value:Number):void;
		function get y():Number;
		function set y(value:Number):void;
		function get z():Number;
		function get rotation():Number;
		function set rotation(value:Number):void;
		function get width():Number;
		function set width(value:Number):void;
		function get height():Number;
		function set height(value:Number):void;
		function get depth():Number;
		function get radius():Number;
		function set radius(value:Number):void;
		function get body():Body;
		function getBody():*;
		
		function get beginContactCallEnabled():Boolean;
		function set beginContactCallEnabled(value:Boolean):void;
		function get endContactCallEnabled():Boolean;
		function set endContactCallEnabled(value:Boolean):void;
	}
}
