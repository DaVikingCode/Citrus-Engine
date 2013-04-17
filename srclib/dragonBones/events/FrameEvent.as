package dragonBones.events
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	import dragonBones.Armature;
	import dragonBones.Bone;
	
	import flash.events.Event;
	
	/**
	 * The FrameEvent class provides and defines all events dispatched by an Animation or Bone instance entering a new frame.
	 *
	 * 
	 * @see dragonBones.animation.Animation
	 */
	public class FrameEvent extends Event
	{
		/**
		 * Dispatched when the animation of the armatrue enter a frame.
		 */
		public static const MOVEMENT_FRAME_EVENT:String = "movementFrameEvent";
		/**
		 * Dispatched when a bone of the armature enter a frame.
		 */
		public static const BONE_FRAME_EVENT:String = "boneFrameEvent";
		/**
		 * The id of the MovementData instance.
		 */
		public var movementID:String;
		/**
		 * The entered frame label.
		 */
		public var frameLabel:String;
		
		/**
		 * The armature that is the target of this event.
		 */
		public function get armature():Armature
		{
			return target as Armature;
		}
		
		/** @private */
		private var _bone:Bone;
		
		/**
		 * The bone that is the target of this event.
		 */
		public function get bone():Bone
		{
			return _bone;
		}
		
		/**
		 * Creates a new FrameEvent instance.
		 * @param	type
		 * @param	cancelable
		 */
		public function FrameEvent(type:String, cancelable:Boolean = false, bone:Bone = null)
		{
			super(type, false, cancelable);
			_bone = bone;
		}
		
		/**
		 * @private
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