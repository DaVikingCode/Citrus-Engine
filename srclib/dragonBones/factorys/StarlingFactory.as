package dragonBones.factorys
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.display.StarlingDisplayBridge;
	import dragonBones.textures.ITextureAtlas;
	import dragonBones.textures.StarlingTextureAtlas;
	import dragonBones.textures.SubTextureData;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.dragonBones_internal;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	use namespace dragonBones_internal;
	
	/**
	 * A object managing the set of armature resources for Starling engine. It parses the raw data, stores the armature resources and creates armature instrances.
	 * @see dragonBones.Armature
	 */
	public class StarlingFactory extends BaseFactory
	{
		public var generateMipMaps:Boolean;
		public var optimizeForRenderToTexture:Boolean;
		public var scaleForTexture:Number;
		
		/**
		 * Creates a new <code>StarlingFactory</code>
		 */
		public function StarlingFactory()
		{
			super();
			generateMipMaps = true;
			optimizeForRenderToTexture = true;
			scaleForTexture = 1;
		}
		
		override protected function generateArmature():Armature
		{
			var armature:Armature = new Armature(new Sprite());
			return armature;
		}
		
		override protected function generateBone():Bone
		{
			var bone:Bone = new Bone(new StarlingDisplayBridge());
			return bone;
		}
		
		override protected function generateTextureDisplay(textureAtlas:Object, fullName:String, pivotX:int, pivotY:int):Object
		{
			var starlingTextureAtlas:StarlingTextureAtlas = textureAtlas as StarlingTextureAtlas;
			if(starlingTextureAtlas)
			{
				//1.4
				var subTextureData:SubTextureData = starlingTextureAtlas.getRegion(fullName) as SubTextureData;
				if(subTextureData)
				{
					pivotX = pivotX || subTextureData.pivotX;
					pivotY = pivotY || subTextureData.pivotY;
				}
			}
			
			var subTexture:SubTexture = (textureAtlas as TextureAtlas).getTexture(fullName) as SubTexture;
			if(subTexture)
			{
				var image:Image = new Image(subTexture);
				image.pivotX = pivotX;
				image.pivotY = pivotY;
				return image;
			}
			return null;
		}
		
		override protected function generateTextureAtlas(content:Object, textureAtlasXML:XML):Object
		{
			var texture:Texture;
			var bitmapData:BitmapData;
			if(content is BitmapData)
			{
				bitmapData = content as BitmapData;
				texture = Texture.fromBitmapData(bitmapData, generateMipMaps, optimizeForRenderToTexture, scaleForTexture);
			}
			else if(content is MovieClip)
			{
				var width:int = int(textureAtlasXML.attribute(ConstValues.A_WIDTH)) * scaleForTexture;
				var height:int = int(textureAtlasXML.attribute(ConstValues.A_HEIGHT)) * scaleForTexture;
				
				_helpMatirx.a = 1;
				_helpMatirx.b = 0;
				_helpMatirx.c = 0;
				_helpMatirx.d = 1;
				_helpMatirx.scale(scaleForTexture, scaleForTexture);
				_helpMatirx.tx = 0;
				_helpMatirx.ty = 0;
				
				var movieClip:MovieClip = content as MovieClip;
				movieClip.gotoAndStop(1);
				bitmapData= new BitmapData(width, height, true, 0xFF00FF);
				bitmapData.draw(movieClip, _helpMatirx);
				movieClip.gotoAndStop(movieClip.totalFrames);
				texture = Texture.fromBitmapData(bitmapData, generateMipMaps, optimizeForRenderToTexture, scaleForTexture);
			}
			else
			{
				//
			}
			
			var textureAtlas:StarlingTextureAtlas = new StarlingTextureAtlas(texture, textureAtlasXML);
			
			if(Starling.handleLostContext)
			{
				textureAtlas._bitmapData = bitmapData;
			}
			else
			{
				bitmapData.dispose();
			}
			return textureAtlas;
		}
	}
}