package citrus.physics.nape {

	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.space.Space;
		
	/**
	 * Used to determine the contact's interaction between objects. It calls function in NapePhysicsObject.
	 */
	public class NapeContactListener {
		
		private var _space:Space;
		
		public function NapeContactListener(space:Space) {
			
			_space = space;
			
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onInteractionBegin));
			_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onInteractionEnd));
		}
		
		public function destroy():void {
			
			_space.listeners.clear();
		}
		
		public function onInteractionBegin(interactionCallback:InteractionCallback):void {
			interactionCallback.int1.userData.myData.handleBeginContact(interactionCallback);
			interactionCallback.int2.userData.myData.handleBeginContact(interactionCallback);
		}
		
		public function onInteractionEnd(interactionCallback:InteractionCallback):void {
			interactionCallback.int1.userData.myData.handleEndContact(interactionCallback);
			interactionCallback.int2.userData.myData.handleEndContact(interactionCallback);
		}
	}
}
