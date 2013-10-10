package dragonBones.textures
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/
	import flash.geom.Rectangle;
	/**
	 * The ITextureAtlas interface defines the methods used by all ITextureAtlas within the dragonBones system (flash or starling DisplayObject based).
	 * @see dragonBones.Armature
	 */
	public interface ITextureAtlas
	{
		/**
		 * The name of this ITextureAtlas.
		 */
		function get name():String;
		/**
		 * Clean up resources.
		 */
		function dispose():void;
		/**
		 * Get the specific region of the TextureAtlas occupied by assets defined by that name.
		 * @param	name The name of the assets represented by that name.
		 * @return Rectangle The rectangle area occupied by those assets.
		 */
		function getRegion(name:String):Rectangle
	}
}