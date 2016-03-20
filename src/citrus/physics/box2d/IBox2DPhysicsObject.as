package citrus.physics.box2d {

	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;
	
	/**
	 * An interface used by each Box2D object. It helps to enable interaction between entity/component object and "normal" object.
	 */
	public interface IBox2DPhysicsObject
	{
		function handleBeginContact(contact:b2Contact):void;
		function handleEndContact(contact:b2Contact):void;
		function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void;
		function handlePostSolve(contact:b2Contact, impulse:b2ContactImpulse):void;
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
		function get body():b2Body;
		function getBody():*;
		
		function get beginContactCallEnabled():Boolean;
		function set beginContactCallEnabled(value:Boolean):void;
		function get endContactCallEnabled():Boolean;
		function set endContactCallEnabled(value:Boolean):void;
		function get preContactCallEnabled():Boolean;
		function set preContactCallEnabled(value:Boolean):void;
		function get postContactCallEnabled():Boolean;
		function set postContactCallEnabled(value:Boolean):void;
	}
}