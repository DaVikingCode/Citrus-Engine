package dragonBones.objects
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	import flash.utils.ByteArray;
	/**
	 * The DecompressedData is a convenient class for storing animation related data (data, atlas, object).
	 *
	 * @see dragonBones.Armature
	 */
	public final class DecompressedData
	{
		public var textureBytesDataType:String;
		/**
		 * A xml for DragonBones data.
		 */
		public var dragonBonesData:Object;
		/**
		 * A xml for atlas data.
		 */
		public var textureAtlasData:Object;
		/**
		 * The non parsed data map.
		 */
		public var textureBytes:ByteArray;
		
		/**
		 * Creates a new DecompressedData instance.
		 * @param xml A xml for DragonBones data.
		 * @param textureAtlasXML A xml for atlas data.
		 * @param textureBytes The non parsed data map.
		 */
		public function DecompressedData(dragonBonesData:Object, textureAtlasData:Object, textureBytes:ByteArray)
		{
			this.dragonBonesData = dragonBonesData;
			this.textureAtlasData = textureAtlasData;
			this.textureBytes = textureBytes;
		}
		
		public function dispose():void
		{
			dragonBonesData = null;
			textureAtlasData = null;
			textureBytes = null;
		}
	}
}