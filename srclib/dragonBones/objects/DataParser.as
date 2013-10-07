﻿package dragonBones.objects
{
	import dragonBones.objects.ObjectDataParser;
	import dragonBones.objects.SkeletonData;
	import dragonBones.objects.XMLDataParser;
	import dragonBones.utils.BytesType;
	import dragonBones.utils.checkBytesTailisXML;
	
	import flash.utils.ByteArray;
	
	public final class DataParser
	{
		/**
		 * Compress all data into a ByteArray for serialization.
		 * @param	The DragonBones data.
		 * @param	The TextureAtlas data.
		 * @param	The ByteArray representing the map.
		 * @return ByteArray. A DragonBones compatible ByteArray.
		 */
		public static function compressData(dragonBonesData:Object, textureAtlasData:Object, textureDataBytes:ByteArray):ByteArray
		{
			var retult:ByteArray = new ByteArray();
			retult.writeBytes(textureDataBytes);
			
			var dataBytes:ByteArray = new ByteArray();
			dataBytes.writeObject(textureAtlasData);
			dataBytes.compress();
			
			retult.position = retult.length;
			retult.writeBytes(dataBytes);
			retult.writeInt(dataBytes.length);
			
			dataBytes.length = 0;
			dataBytes.writeObject(dragonBonesData);
			dataBytes.compress();
			
			retult.position = retult.length;
			retult.writeBytes(dataBytes);
			retult.writeInt(dataBytes.length);
			
			return retult;
		}
		
		/**
		 * Decompress a compatible DragonBones data.
		 * @param	compressedByteArray The ByteArray to decompress.
		 * @return A DecompressedData instance.
		 */
		public static function decompressData(bytes:ByteArray):DecompressedData
		{
			var dataType:String = BytesType.getType(bytes);
			switch (dataType)
			{
				case BytesType.SWF: 
				case BytesType.PNG: 
				case BytesType.JPG: 
				case BytesType.ATF: 
					try
					{
						bytes.position = bytes.length - 4;
						var strSize:int = bytes.readInt();
						var position:uint = bytes.length - 4 - strSize;
						
						var dataBytes:ByteArray = new ByteArray();
						dataBytes.writeBytes(bytes, position, strSize);
						dataBytes.uncompress();
						bytes.length = position;
						
						var dragonBonesData:Object;
						if(checkBytesTailisXML(dataBytes))
						{
							dragonBonesData = XML(dataBytes.readUTFBytes(dataBytes.length));
						}
						else
						{
							dragonBonesData = dataBytes.readObject();
						}
						
						bytes.position = bytes.length - 4;
						strSize = bytes.readInt();
						position = bytes.length - 4 - strSize;
						
						dataBytes.length = 0;
						dataBytes.writeBytes(bytes, position, strSize);
						dataBytes.uncompress();
						bytes.length = position;
						
						var textureAtlasData:Object;
						if(checkBytesTailisXML(dataBytes))
						{
							textureAtlasData = XML(dataBytes.readUTFBytes(dataBytes.length));
						}
						else
						{
							textureAtlasData = dataBytes.readObject();
						}
					}
					catch (e:Error)
					{
						throw new Error("Data error!");
					}
					
					var decompressedData:DecompressedData = new DecompressedData(dragonBonesData, textureAtlasData, bytes);
					decompressedData.textureBytesDataType = dataType;
					return decompressedData;
				case BytesType.ZIP:
					throw new Error("Can not decompress zip!");
				default: 
					throw new Error("Nonsupport data!");
			}
			return null;
		}
		
		public static function parseTextureAtlas(rawData:Object, scale:Number = 1):Object
		{
			if(rawData is XML)
			{
				return XMLDataParser.parseTextureAtlasData(rawData as XML, scale);
			}
			else
			{
				return ObjectDataParser.parseTextureAtlasData(rawData, scale);
			}
			return null;
		}
		
		public static function parseData(rawData:Object):SkeletonData
		{
			if(rawData is XML)
			{
				return XMLDataParser.parseSkeletonData(rawData as XML);
			}
			else
			{
				return ObjectDataParser.parseSkeletonData(rawData);
			}
			return null;
		}
	}
}