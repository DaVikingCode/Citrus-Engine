package com.citrusengine.objects.platformer.nape {
	
	import flash.utils.getDefinitionByName;
	
	import nape.callbacks.InteractionCallback;

	/**
	 * Coin is basically a sensor that destroys itself when a particular class type touches it. 
	 */
	public class Coin extends Sensor {

		private var _collectorClass:Class = Hero;

		public function Coin(name:String, params:Object = null) {

			super(name, params);
		}

		/**
		 * The Coin uses the collectorClass parameter to know who can collect it.
		 * Use this setter to to pass in which base class the collector should be, in String form
		 * or Object notation.
		 * For example, if you want to set the "Hero" class as your hero's enemy, pass
		 * "com.citrusengine.objects.platformer.nape.Hero" or Hero directly (no quotes). Only String
		 * form will work when creating objects via a level editor.
		 */
		[Property(value="com.citrusengine.objects.platformer.nape.Hero")]
		public function set collectorClass(value:*):void {
			
			if (value is String)
				_collectorClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_collectorClass = value;
		}
		
		override public function handleBeginContact(interactionCallback:InteractionCallback):void {
			
			super.handleBeginContact(interactionCallback);
			
			if (_collectorClass && interactionCallback.int2.castBody.userData is _collectorClass) {
				kill = true;
			}
		}
	}
}
