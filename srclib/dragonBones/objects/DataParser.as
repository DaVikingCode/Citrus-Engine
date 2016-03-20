package dragonBones.objects
{
	public class DataParser
	{
		public function DataParser()
		{
		}
		
		public static function parseData(rawData:Object):DragonBonesData
		{
			if(rawData is XML)
			{
				return XMLDataParser.parseDragonBonesData(rawData as XML);
			}
			else
			{
				return ObjectDataParser.parseDragonBonesData(rawData);
			}
			return null;
		}
		
		public static function parseTextureAtlasData(textureAtlasData:Object, scale:Number = 1):Object
		{
			if(textureAtlasData is XML)
			{
				return XMLDataParser.parseTextureAtlasData(textureAtlasData as XML, scale);
			}
			else
			{
				return ObjectDataParser.parseTextureAtlasData(textureAtlasData, scale);
			}
			return null;
		}
	}
}