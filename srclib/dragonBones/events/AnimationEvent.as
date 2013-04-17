package dragonBones.events
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	import dragonBones.Armature;
	
	import flash.events.Event;
	
	/**
	 * The AnimationEvent provides and defines all events dispatched during an animation.
	 *
	 * @see dragonBones.Armature
	 * @see dragonBones.animation.Animation
	 */
	public class AnimationEvent extends Event
	{
		/**
		 * Dispatched when the movement of animation is changed.
		 */
		public static const MOVEMENT_CHANGE:String = "movementChange";
		
		/**
		 * Dispatched when the playback of an animation starts.
		 */
		public static const START:String = "start";
		
		/**
		 * Dispatched when the playback of a movement stops.
		 */
		public static const COMPLETE:String = "complete";
		
		/**
		 * Dispatched when the playback of a movement completes a loop.
		 */
		public static const LOOP_COMPLETE:String = "loopComplete";
		/**
		 * The preceding MovementData id.
		 */
		public var exMovementID:String;
		/**
		 * The current MovementData id.
		 */
		public var movementID:String;
		
		/**
		 * The armature that is the taget of this event.
		 */
		public function get armature():Armature
		{
			return target as Armature;
		}
		
		/**
		 * Creates a new AnimationEvent instance.
		 * @param	type
		 * @param	cancelable
		 */
		public function AnimationEvent(type:String, cancelable:Boolean = false)
		{
			super(type, false, cancelable);
		}
		
		/**
		 * @private
		 * @return
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