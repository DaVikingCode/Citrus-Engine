package dragonBones.events
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.utils.dragonBones_internal;
	
	import flash.events.Event;
	
	use namespace dragonBones_internal;
	/**
	 * The SoundEvent provides and defines all sound related events dispatched during an animation.
	 *
	 * @see dragonBones.Armature
	 * @see dragonBones.animation.Animation
	 */
	public class SoundEvent extends Event
	{
		/**
		 * Dispatched when the animation of the animation enter a frame containing sound labels.
		 */
		public static const SOUND:String = "sound";
		
		public var movementID:String;
		
		public var sound:String;
		public var soundEffect:String;
		
		/** @private */
		dragonBones_internal var _armature:Armature;
		
		/**
		 * The armature that is the target of this event.
		 */
		public function get armature():Armature
		{
			return _armature;
		}
		
		/** @private */
		dragonBones_internal var _bone:Bone;
		
		/**
		 * The bone that is the target of this event.
		 */
		public function get bone():Bone
		{
			return _bone;
		}
		
		/**
		 * Creates a new SoundEvent instance.
		 * @param	type
		 * @param	cancelable
		 */
		public function SoundEvent(type:String, cancelable:Boolean = false)
		{
			super(type, false, cancelable);
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			var event:SoundEvent = new SoundEvent(type, cancelable);
			event.movementID = movementID;
			event.sound = sound;
			event.soundEffect = soundEffect;
			event._armature = _armature;
			event._bone = _bone;
			return event;
		}
	}
}