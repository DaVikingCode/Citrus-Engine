package dragonBones.objects
{
	import flash.utils.ByteArray;
	
	public final class DecompressedData
	{
		public var skeletonXML:XML;
		public var textureAtlasXML:XML;
		public var textureBytes:ByteArray;
		public function DecompressedData(skeletonXML:XML, textureAtlasXML:XML, textureBytes:ByteArray)
		{
			this.skeletonXML = skeletonXML;
			this.textureAtlasXML = textureAtlasXML;
			this.textureBytes = textureBytes;
		}
		
		public function dispose():void
		{
			skeletonXML = null;
			textureAtlasXML = null;
			textureBytes = null;
		}
	}
}