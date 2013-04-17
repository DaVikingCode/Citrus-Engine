package dragonBones.textures
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.dragonBones_internal;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
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
		public function StarlingTextureAtlas(texture:Texture, textureAtlasXML:XML, isDifferentXML:Boolean = false)
		{
			if (texture)
			{
				_scale = texture.scale;
				_isDifferentXML = isDifferentXML;
			}			
			super(texture, textureAtlasXML);
			if (textureAtlasXML)
			{
				_name = textureAtlasXML.attribute(ConstValues.A_NAME);
			}
			_subTextureDic = {};
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
			_subTextureDic = {};
			
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
		 * @param	atlasXml
		 */
		override protected function parseAtlasXml(atlasXml:XML):void
		{
			var scale:Number = _isDifferentXML ? _scale : 1;
			
			for each (var subTexture:XML in atlasXml.SubTexture)
			{
				var name:String = subTexture.attribute("name");
				var x:Number = parseFloat(subTexture.attribute("x")) / scale;
				var y:Number = parseFloat(subTexture.attribute("y")) / scale;
				var width:Number = parseFloat(subTexture.attribute("width")) / scale;
				var height:Number = parseFloat(subTexture.attribute("height")) / scale;
				var frameX:Number = parseFloat(subTexture.attribute("frameX")) / scale;
				var frameY:Number = parseFloat(subTexture.attribute("frameY")) / scale;
				var frameWidth:Number = parseFloat(subTexture.attribute("frameWidth")) / scale;
				var frameHeight:Number = parseFloat(subTexture.attribute("frameHeight")) / scale;				
				//1.4
				var region:SubTextureData = new SubTextureData(x, y, width, height);
				region.pivotX = int(subTexture.attribute(ConstValues.A_PIVOT_X));
				region.pivotY = int(subTexture.attribute(ConstValues.A_PIVOT_Y));				
				var frame:Rectangle = frameWidth > 0 && frameHeight > 0 ? new Rectangle(frameX, frameY, frameWidth, frameHeight) : null;				
				addRegion(name, region, frame);
			}
		}
	}
}