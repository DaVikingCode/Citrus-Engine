package dragonBones.factorys
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.display.StarlingDisplayBridge;
	import dragonBones.objects.Node;
	import dragonBones.objects.SubTextureData;
	import dragonBones.objects.TextureAtlasData;
	import dragonBones.utils.BytesType;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.dragonBones_internal;
	
	import starling.display.Sprite;
	import starling.display.Image;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	
	use namespace dragonBones_internal;
	
	/**
	 * A object managing the set of armature resources for Starling engine. It parses the raw data, stores the armature resources and creates armature instrances.
	 * @see dragonBones.Armature
	 */
	public class StarlingFactory extends BaseFactory
	{
		/** @private */
		public static function getTextureDisplay(textureAtlasData:TextureAtlasData, fullName:String):Image
		{
			var subTextureData:SubTextureData = textureAtlasData.getSubTextureData(fullName);
			if (subTextureData)
			{
				var subTexture:SubTexture = textureAtlasData.getStarlingSubTexture(fullName) as SubTexture;
				if(!subTexture)
				{
					subTexture = new SubTexture(textureAtlasData._starlingTexture as Texture, subTextureData);
					textureAtlasData.addStarlingSubTexture(fullName, subTexture);
				}
				
				var image:Image = new Image(subTexture);
				image.pivotX = subTextureData.pivotX;
				image.pivotY = subTextureData.pivotY;
				return image;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set textureAtlasData(value:TextureAtlasData):void
		{
			super.textureAtlasData = value;
			if(_textureAtlasData)
			{
				_textureAtlasData.bitmap;
			}
		}
		/**
		 * Specifies whether this object disposes bitmap data.
		 */
		public var autoDisposeBitmapData:Boolean = true;
		
		/**
		 * Creates a new <code>StarlingFactory</code>
		 */
		public function StarlingFactory()
		{
			super();
		}
		
		override protected function generateArmature():Armature
		{
			if (!textureAtlasData._starlingTexture)
			{
				if(textureAtlasData.dataType == BytesType.ATF)
				{
					textureAtlasData._starlingTexture = Texture.fromAtfData(textureAtlasData.rawData);
				}
				else
				{
					textureAtlasData._starlingTexture = Texture.fromBitmap(textureAtlasData.bitmap);
					//no need to keep the bitmapData
					if (autoDisposeBitmapData)
					{
						textureAtlasData.bitmap.bitmapData.dispose();
					}
				}
			}
			
			var armature:Armature = new Armature(new Sprite());
			return armature;
		}
		
		override protected function generateBone():Bone
		{
			var bone:Bone = new Bone(new StarlingDisplayBridge());
			return bone;
		}
		
		override protected function getBoneTextureDisplay(textureName:String):Object
		{
			return getTextureDisplay(_textureAtlasData, textureName);
		}
	}
}