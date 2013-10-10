package dragonBones.display
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/
	
	import dragonBones.objects.DBTransform;
	
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	/**
	 * Provides an interface for display classes that can be used in this DragonBones animation system.
	 *
	 */
	public interface IDisplayBridge
	{
		function get visible():Boolean;
		function set visible(value:Boolean):void;
		
		/**
		 * Indicates the original display object relative to specific display engine.
		 */
		function get display():Object;
		function set display(value:Object):void;
		
		/**
		 * Cleans up resources used by this IDisplayBridge instance.
		 */
		function dispose():void;
		
		/**
		 * Updates the transform of the display object
		 * @param	matrix
		 * @param	transform
		 */
		function updateTransform(matrix:Matrix, transform:DBTransform):void;
		
		/**
		 * Updates the color of the display object
		 * @param	a
		 * @param	r
		 * @param	g
		 * @param	b
		 * @param	aM
		 * @param	rM
		 * @param	gM
		 * @param	bM
		 */
		function updateColor(
			aOffset:Number, 
			rOffset:Number, 
			gOffset:Number, 
			bOffset:Number, 
			aMultiplier:Number, 
			rMultiplier:Number, 
			gMultiplier:Number, 
			bMultiplier:Number
		):void;
        
        /**
         * Update the blend mode of the display object
         * @param blendMode The blend mode to use. 
         */
        function updateBlendMode(blendMode:String):void;
		
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