package com.citrusengine.objects.platformer.nape {

	import com.citrusengine.objects.NapePhysicsObject;

	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.phys.BodyType;
	
	import org.osflash.signals.Signal;

	/**
	 * Sensors simply listen for when an object begins and ends contact with them. They disaptch a signal
	 * when contact is made or ended, and this signal can be used to perform custom game logic such as
	 * triggering a scripted event, ending a level, popping up a dialog box, and virtually anything else.
	 * 
	 * Remember that signals dispatch events when ANY Nape object collides with them, so you will want
	 * your collision handler to ignore collisions with objects that it is not interested in, or extend
	 * the sensor and use maskBits to ignore collisions altogether.  
	 * 
	 * Events
	 * onBeginContact - Dispatches on first contact with the sensor.
	 * onEndContact - Dispatches when the object leaves the sensor.
	 */
	public class Sensor extends NapePhysicsObject {

		public static const SENSOR:CbType = new CbType();
		
		/**
		 * Dispatches on first contact with the sensor.
		 */
		public var onBeginContact:Signal;
		/**
		 * Dispatches when the object leaves the sensor.
		 */
		public var onEndContact:Signal;

		public function Sensor(name:String, params:Object = null) {

			super(name, params);
			
			onBeginContact = new Signal(InteractionCallback);
			onEndContact = new Signal(InteractionCallback);
		}

		override public function destroy():void {
			
			onBeginContact.removeAll();
			onEndContact.removeAll();

			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);
		}

		override protected function defineBody():void {

			_bodyType = BodyType.STATIC;
		}

		override protected function createShape():void {

			super.createShape();
			
			_body.setShapeFilters(new InteractionFilter(0, 0, 1, 1, 0, 0));
		}
		
		override protected function createConstraint():void {
			
			_body.space = _nape.space;			
			_body.cbTypes.add(SENSOR);
		}
		
		override public function handleBeginContact(interactionCallback:InteractionCallback):void {
			onBeginContact.dispatch(interactionCallback);
		}
		
		override public function handleEndContact(interactionCallback:InteractionCallback):void {
			onEndContact.dispatch(interactionCallback);
		}
	}
}
