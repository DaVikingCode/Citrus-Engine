package dragonBones.textures
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.DataParser;
	
	import flash.display.BitmapData;
	
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	use namespace dragonBones_internal;
	
	/**
	 * The StarlingTextureAtlas creates and manipulates TextureAtlas from starling.display.DisplayObject.
	 */
	public class StarlingTextureAtlas extends TextureAtlas implements ITextureAtlas
	{
		dragonBones_internal var _bitmapData:BitmapData;
		/**
		 * @private
		 */
		protected var _subTextureDic:Object;
		/**
		 * @private
		 */
		protected var _isDifferentXML:Boolean;	
		/**
		 * @private
		 */
		protected var _scale:Number;
		/**
		 * @private
		 */
		protected var _name:String;
		/**
		 * The name of this StarlingTextureAtlas instance.
		 */
		public function get name():String
		{
			return _name;
		}
		/**
		 * Creates a new StarlingTextureAtlas instance.
		 * @param	texture A texture instance.
		 * @param	textureAtlasXML A textureAtlas xml
		 * @param	isDifferentXML
		 */
		public function StarlingTextureAtlas(texture:Texture, textureAtlasRawData:Object, isDifferentXML:Boolean = false)
		{
			super(texture, null);
			if (texture)
			{
				_scale = texture.scale;
				_isDifferentXML = isDifferentXML;
			}
			_subTextureDic = {};
			parseData(textureAtlasRawData);
		}
		/**
		 * Clean up all resources used by this StarlingTextureAtlas instance.
		 */
		override public function dispose():void
		{
			super.dispose();			
			for each (var subTexture:SubTexture in _subTextureDic)
			{
				subTexture.dispose();
			}			
			_subTextureDic = null;
			
			if (_bitmapData)
			{
				_bitmapData.dispose();
			}
			_bitmapData = null;
		}
		/**
		 * Get the Texture with that name.
		 * @param	name The name ofthe Texture instance.
		 * @return The Texture instance.
		 */
		override public function getTexture(name:String):Texture
		{
			var texture:Texture = _subTextureDic[name];
			if (!texture)
			{
				texture = super.getTexture(name);
				if (texture)
				{
					_subTextureDic[name] = texture;
				}
			}
			return texture;
		}
		/**
		 * @private
		 */
		protected function parseData(textureAtlasRawData:Object):void
		{
			var textureAtlasData:Object = DataParser.parseTextureAtlas(textureAtlasRawData, _isDifferentXML ? _scale : 1);
			_name = textureAtlasData.__name;
			delete textureAtlasData.__name;
			for(var subTextureName:String in textureAtlasData)
			{
				this.addRegion(subTextureName, textureAtlasData[subTextureName], null);
			}
		}
	}
}