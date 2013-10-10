package dragonBones.events
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	import dragonBones.Armature;
	import dragonBones.animation.AnimationState;
	
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
		 * Dispatched when the playback of an animation fade in.
		 */
		public static function get MOVEMENT_CHANGE():String
		{
			return FADE_IN;
		}
		
		/**
		 * Dispatched when the playback of an animation fade in.
		 */
		public static const FADE_IN:String = "fadeIn";
		
		/**
		 * Dispatched when the playback of an animation fade out.
		 */
		public static const FADE_OUT:String = "fadeOut";
		
		/**
		 * Dispatched when the playback of an animation starts.
		 */
		public static const START:String = "start";
		
		/**
		 * Dispatched when the playback of a animation stops.
		 */
		public static const COMPLETE:String = "complete";
		
		/**
		 * Dispatched when the playback of a animation completes a loop.
		 */
		public static const LOOP_COMPLETE:String = "loopComplete";
		
		/**
		 * Dispatched when the playback of an animation fade in complete.
		 */
		public static const FADE_IN_COMPLETE:String = "fadeInComplete";
		
		/**
		 * Dispatched when the playback of an animation fade out complete.
		 */
		public static const FADE_OUT_COMPLETE:String = "fadeOutComplete";
		
		/**
		 * The animationState instance.
		 */
		public var animationState:AnimationState;
		
		/**
		 * The armature that is the taget of this event.
		 */
		public function get armature():Armature
		{
			return target as Armature;
		}
		
		public function get movementID():String
		{
			return animationState.name;
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
			event.animationState = animationState;
			return event;
		}
	}
}