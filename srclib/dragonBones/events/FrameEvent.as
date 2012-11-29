package dragonBones.events
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.utils.dragonBones_internal;
	
	import flash.events.Event;
	
	use namespace dragonBones_internal;
	
	/**
	 * Dispatched when processing a frame.
	 */
	public class FrameEvent extends Event
	{
		/**
		 * Dispatched when the animation of the armatrue enter a frame.
		 */
		public static const MOVEMENT_FRAME_EVENT:String = "movementFrameEvent";
		/**
		 * Dispatched when a bone of the armatrue enter a frame.
		 */
		public static const BONE_FRAME_EVENT:String = "boneFrameEvent";
		
		public var movementID:String;
		
		public var frameLabel:String;
		
		/**
		 * The armature that is the subject of this event.
		 */
		public function get armature():Armature
		{
			return target as Armature;
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
		 * Creates a new <code>FrameEvent</code>
		 * @param	type
		 * @param	cancelable
		 */
		public function FrameEvent(type:String, cancelable:Boolean=false)
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
			var event:FrameEvent = new FrameEvent(type, cancelable);
			event.movementID = movementID;
			event.frameLabel = frameLabel;
			event._bone = _bone;
			return event;
		}
	}
}