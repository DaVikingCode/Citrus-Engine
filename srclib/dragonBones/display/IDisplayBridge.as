package dragonBones.display
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/
	
	import dragonBones.objects.BoneTransform;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	/**
	 * Provides an interface for display classes that can be used in this skeleton animation system.
	 *
	 */
	public interface IDisplayBridge
	{
		/**
		 * Indicates the original display object relative to specific display engine.
		 */
		function get display():Object;
		function set display(value:Object):void;
		/**
		 * Updates the transform of the display object
		 * @param	matrix
		 * @param	node
		 * @param	colorTransform
		 * @param	visible
		 */
		function update(matrix:Matrix, node:BoneTransform, colorTransform:ColorTransform, visible:Boolean):void;
		/**
		 * Adds the original display object to another display object.
		 * @param	container
		 * @param	index
		 */
		function addDisplay(container:Object, index:int = -1):void;
		/**
		 * remove the original display object from its parent.
		 */
		function removeDisplay():void;
	}
}