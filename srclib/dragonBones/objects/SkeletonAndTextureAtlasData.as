package dragonBones.objects
{
	import dragonBones.errors.UnknownDataError;
	import dragonBones.utils.ConstValues;
	
	import flash.utils.ByteArray;

	/** @private */
	public final class SkeletonAndTextureAtlasData
	{
		public var skeletonData:SkeletonData;
		public var textureAtlasData:TextureAtlasData;
		
		public var skeletonXML:XML;
		public var textureAtlasXML:XML;
		
		public function SkeletonAndTextureAtlasData(skeletonXML:XML, textureAtlasXML:XML, textureBytes:ByteArray)
		{
			this.skeletonXML = skeletonXML;
			this.textureAtlasXML = textureAtlasXML;
			skeletonData = XMLDataParser.parseSkeletonData(skeletonXML);
			textureAtlasData = XMLDataParser.parseTextureAtlasData(textureAtlasXML, textureBytes);
		}
		
		public function dispose():void{
			skeletonData = null;
			textureAtlasData = null;
		}
	}
}