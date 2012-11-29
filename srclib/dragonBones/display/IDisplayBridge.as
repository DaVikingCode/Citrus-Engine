package dragonBones.display
{
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
		 */
		function update(matrix:Matrix):void;
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