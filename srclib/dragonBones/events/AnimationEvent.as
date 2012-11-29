package dragonBones.events
{
	import dragonBones.Armature;
	
	import flash.events.Event;
	
	/**
	 * Dispatched to notify state changes in an animation.
	 *
	 * @see dragonBones.Armature
	 */
	public class AnimationEvent extends flash.events.Event
	{
		/**
		 * Dispatched when the movement of animation is changed.
		 */
		public static const MOVEMENT_CHANGE:String = "movementChange";
		
		/**
		 * Dispatched when the playback of a animation starts.
		 */
		public static const START:String = "animationStart";
		
		/**
		 * Dispatched when the playback of a movement stops.
		 */
		public static const COMPLETE:String = "movementComplete";
		
		/**
		 * Dispatched when the playback of a movement completes a loop.
		 */
		public static const LOOP_COMPLETE:String = "movementLoopComplete";
		
		public var exMovementID:String;
		public var movementID:String;
		
		/**
		 * The armature that is the subject of this event.
		 */
		public function get armature():Armature
		{
			return target as Armature;
		}
		
		/**
		 * Creates a new <code>AnimationEvent</code>
		 * @param	type
		 * @param	cancelable
		 */
		public function AnimationEvent(type:String, cancelable:Boolean = false)
		{
			super(type, false, cancelable);
		}
		
		/**
		 * Clones the event.
		 *
		 * @return An exact duplicate of the current object.
		 */
		override public function clone():Event
		{
			var event:AnimationEvent = new AnimationEvent(type, cancelable);
			event.exMovementID = exMovementID;
			event.movementID = movementID;
			return event;
		}
	}
}