package dragonBones.animation
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/
	
	/**
	 * The IAnimatable interface defines the methods used by all animatable instance type used by the DragonBones system.
	 * @see dragonBones.Armature
	 * @see dragonBones.animation.WorldClock
	 */
	public interface IAnimatable
	{
		/**
		 * Update the animation using this method typically in an ENTERFRAME Event or with a Timer.
		 * @param	The amount of second to move the playhead ahead.
		 */
		function advanceTime(passedTime:Number):void;
	}
}