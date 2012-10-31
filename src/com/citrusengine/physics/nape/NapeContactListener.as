package com.citrusengine.physics.nape {

	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.space.Space;

	import com.citrusengine.objects.platformer.nape.Baddy;
	import com.citrusengine.objects.platformer.nape.Missile;
	import com.citrusengine.objects.platformer.nape.MissileWithExplosion;
	import com.citrusengine.objects.platformer.nape.Sensor;
		
	/**
	 * Used to determine the contact's interaction between objects. It calls function in NapePhysicsObject.
	 */
	public class NapeContactListener {
		
		private var _space:Space;
		
		public function NapeContactListener(space:Space) {
			
			_space = space;
			
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, Sensor.SENSOR, CbType.ANY_BODY, onInteractionBegin));
			_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.SENSOR, Sensor.SENSOR, CbType.ANY_BODY, onInteractionEnd));
			
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, Baddy.BADDY, CbType.ANY_BODY, onInteractionBegin));
			
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, Missile.MISSILE, CbType.ANY_BODY, onInteractionBegin));
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, MissileWithExplosion.MISSILE, CbType.ANY_BODY, onInteractionBegin));
		}
		
		public function destroy():void {
			
			_space.listeners.clear();
		}
		
		public function onInteractionBegin(interactionCallback:InteractionCallback):void {
			
			interactionCallback.int1.userData.myData.handleBeginContact(interactionCallback);
			
			if (interactionCallback.int1.cbTypes.at(1) != Missile.MISSILE)
				interactionCallback.int2.userData.myData.handleBeginContact(interactionCallback);
		}
		
		public function onInteractionEnd(interactionCallback:InteractionCallback):void {
			interactionCallback.int1.userData.myData.handleEndContact(interactionCallback);
			interactionCallback.int2.userData.myData.handleEndContact(interactionCallback);
		}
	}
}
