package dragonBones.events
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.utils.dragonBones_internal;
	
	import flash.events.Event;
	
	use namespace dragonBones_internal;
	
	public class SoundEvent extends Event
	{
		/**
		 * Dispatched when the animation of the animation enter a frame containing sound labels.
		 */
		public static const SOUND:String = "soundFrame";
		
		public var movementID:String;
		
		public var sound:String;
		public var soundEffect:String;
		
		/** @private */
		dragonBones_internal var _armature:Armature;
		
		/**
		 * The armature that is the subject of this event.
		 */
		public function get armature():Armature
		{
			return _armature;
		}
		
		/** @private */
		dragonBones_internal var _bone:Bone;
		
		/**
		 * The bone that is the subject of this event.
		 */
		public function get bone():Bone
		{
			return _bone;
		}
		
		/**
		 * Creates a new <code>SoundEvent</code>
		 * @param	type
		 * @param	cancelable
		 */
		public function SoundEvent(type:String, cancelable:Boolean=false)
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