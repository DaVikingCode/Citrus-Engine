package dragonBones.objects
{
	import dragonBones.core.dragonBones_internal;
	import dragonBones.utils.BytesType;
	import dragonBones.utils.ConstValues;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	use namespace dragonBones_internal;
	
	public final class DataParser
	{
		/**
		 * Compress all data into a ByteArray for serialization.
		 * @param The DragonBones data.
		 * @param The TextureAtlas data.
		 * @param The ByteArray representing the map.
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
		 * @param compressedByteArray The ByteArray to decompress.
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
					var dragonBonesData:Object;
					var textureAtlasData:Object;
					try
					{
						var bytesCopy:ByteArray = new ByteArray();
						bytesCopy.writeBytes(bytes);
						bytes = bytesCopy;
						
						bytes.position = bytes.length - 4;
						var strSize:int = bytes.readInt();
						var position:uint = bytes.length - 4 - strSize;
						
						var dataBytes:ByteArray = new ByteArray();
						dataBytes.writeBytes(bytes, position, strSize);
						dataBytes.uncompress();
						bytes.length = position;
						
						dragonBonesData = dataBytes.readObject();
						
						bytes.position = bytes.length - 4;
						strSize = bytes.readInt();
						position = bytes.length - 4 - strSize;
						
						dataBytes.length = 0;
						dataBytes.writeBytes(bytes, position, strSize);
						dataBytes.uncompress();
						bytes.length = position;
						
						textureAtlasData = dataBytes.readObject();
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
		
		public static function parseData(rawData:Object, ifSkipAnimationData:Boolean = false, outputAnimationDictionary:Dictionary = null):SkeletonData
		{
			if(rawData is XML)
			{
				return XMLDataParser.parseSkeletonData(rawData as XML, ifSkipAnimationData, outputAnimationDictionary);
			}
			else
			{
				return ObjectDataParser.parseSkeletonData(rawData, ifSkipAnimationData, outputAnimationDictionary);
			}
			return null;
		}
		
		public static function parseAnimationDataByAnimationRawData(animationRawData:Object, armatureData:ArmatureData):AnimationData
		{
			var animationData:AnimationData = armatureData.animationDataList[0];
			
			
			if(animationRawData is XML)
			{
				return XMLDataParser.parseAnimationData((animationRawData as XML), armatureData, animationData.frameRate);
			}
			else
			{
				return ObjectDataParser.parseAnimationData(animationRawData, armatureData, animationData.frameRate);
			}
		}
		
		public static function parseFrameRate(rawData:Object):uint
		{
			if(rawData is XML)
			{
				return uint(rawData.@[ConstValues.A_FRAME_RATE]);
			}
			else
			{
				return uint(rawData[ConstValues.A_FRAME_RATE]);
			}
		}
	}
}