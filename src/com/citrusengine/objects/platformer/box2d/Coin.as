package com.citrusengine.objects.platformer.box2d {

	import Box2D.Dynamics.Contacts.b2Contact;

	import com.citrusengine.physics.box2d.Box2DShapeMaker;
	import com.citrusengine.physics.box2d.Box2DUtils;
	import com.citrusengine.physics.box2d.IBox2DPhysicsObject;

	import flash.utils.getDefinitionByName;

	/**
	 * Coin is basically a sensor that destroys itself when a particular class type touches it (often a Hero). 
	 */
	public class Coin extends Sensor {

		protected var _collectorClass:Class = Hero;

		public function Coin(name:String, params:Object = null) {
			super(name, params);
		}

		/**
		 * The Coin uses the collectorClass parameter to know who can collect it.
		 * Use this setter to pass in which base class the collector should be, in String form
		 * or Object notation.
		 * For example, if you want to set the "Hero" class as your hero's enemy, pass
		 * "com.citrusengine.objects.platformer.box2d.Hero" or Hero directly (no quotes). Only String
		 * form will work when creating objects via a level editor.
		 */
		[Inspectable(defaultValue="com.citrusengine.objects.platformer.box2d.Hero")]
		public function set collectorClass(value:*):void {
			if (value is String)
				_collectorClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_collectorClass = value;
		}

		override protected function createShape():void {
			_shape = Box2DShapeMaker.Circle(_width, _height);
		}
		
		/**
		 * On contact, if the collider is the collector the coin is removed. The contact is also dispatched.
		 */
		override public function handleBeginContact(contact:b2Contact):void {

			super.handleBeginContact(contact);
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (_collectorClass && collider is _collectorClass)
				kill = true;
		}
	}
}