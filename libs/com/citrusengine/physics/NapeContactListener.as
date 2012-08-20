package com.citrusengine.physics {
	
	import com.citrusengine.objects.platformer.nape.Sensor;
	import com.citrusengine.objects.platformer.nape.Missile;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.space.Space;
	
	/**
	 * Used to determine the contact's interaction between object.
	 */
	public class NapeContactListener {
		
		private var _space:Space;
		
		public function NapeContactListener(space:Space) {
			
			_space = space;
			
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, Sensor.SENSOR, CbType.ANY_BODY, onInteractionBegin));
			_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.SENSOR, Sensor.SENSOR, CbType.ANY_BODY, onInteractionEnd));
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, Missile.MISSILE, CbType.ANY_BODY, onInteractionBegin));
		}
		
		public function destroy():void {
			
			_space.listeners.clear();
		}
		
		public function onInteractionBegin(interactionCallback:InteractionCallback):void {
			interactionCallback.int1.castBody.userData.myData.handleBeginContact(interactionCallback);
		}
		
		public function onInteractionEnd(interactionCallback:InteractionCallback):void {
			interactionCallback.int1.castBody.userData.myData.handleEndContact(interactionCallback);
		}
	}
}
