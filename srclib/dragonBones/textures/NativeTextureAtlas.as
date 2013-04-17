package dragonBones.textures
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	import dragonBones.textures.SubTextureData;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.dragonBones_internal;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	use namespace dragonBones_internal;
	
	/**
	 * The NativeTextureAtlas creates and manipulates TextureAtlas from traditional flash.display.DisplayObject.
	 */
	public class NativeTextureAtlas implements ITextureAtlas
	{
		/**
		 * @private
		 */
		protected var _width:int;
		/**
		 * @private
		 */
		protected var _height:int;
		/**
		 * @private
		 */
		protected var _subTextureDataDic:Object;
		/**
		 * @private
		 */
		protected var _isDifferentXML:Boolean;
		/**
		 * @private
		 */
		protected var _name:String;
		/**
		 * The name of this NativeTextureAtlas instance.
		 */
		public function get name():String
		{
			return _name;
		}
		
		protected var _movieClip:MovieClip;
		/**
		 * The MovieClip created by this NativeTextureAtlas instance.
		 */
		public function get movieClip():MovieClip
		{
			return _movieClip;
		}
		
		protected var _bitmapData:BitmapData;
		/**
		 * The BitmapData created by this NativeTextureAtlas instance.
		 */
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		protected var _scale:Number;
		/** 
		 * @private
		 */
		public function get scale():Number
		{
			return _scale;
		}
		/**
		 * Creates a new NativeTextureAtlas instance. 
		 * @param	texture A MovieClip or Bitmap.
		 * @param	textureAtlasXML The textureAtlas xml.
		 * @param	textureScale A scale value (x and y axis)
		 * @param	isDifferentXML 
		 */
		public function NativeTextureAtlas(texture:Object, textureAtlasXML:XML, textureScale:Number = 1, isDifferentXML:Boolean = false)
		{
			_scale = textureScale;
			_isDifferentXML = isDifferentXML;
			_subTextureDataDic = {};
			if (texture is BitmapData)
			{
				_bitmapData = texture as BitmapData;
			}
			else if (texture is MovieClip)
			{
				_movieClip = texture as MovieClip;
				_movieClip.stop();
			}
			parseData(textureAtlasXML);
		}
		/**
		 * Clean up all resources used by this NativeTextureAtlas instance.
		 */
		public function dispose():void
		{
			_movieClip = null;
			if (_bitmapData)
			{
				_bitmapData.dispose();
			}
			_bitmapData = null;
			_subTextureDataDic = {};
		}
		/**
		 * The area occupied by all assets related to that name.
		 * @param	name The name of these assets.
		 * @return Rectangle The area occupied by all assets related to that name.
		 */
		public function getRegion(name:String):Rectangle
		{
			return _subTextureDataDic[name];
		}
		
		protected function parseData(textureAtlasXML:XML):void
		{
			_name = textureAtlasXML.attribute(ConstValues.A_NAME);
			_width = int(textureAtlasXML.attribute(ConstValues.A_WIDTH));
			_height = int(textureAtlasXML.attribute(ConstValues.A_HEIGHT));
			var scale:Number = _isDifferentXML ? _scale : 1;
			for each (var subTextureXML:XML in textureAtlasXML.elements(ConstValues.SUB_TEXTURE))
			{
				var subTextureName:String = subTextureXML.attribute(ConstValues.A_NAME);
				var subTextureData:SubTextureData = new SubTextureData();
				subTextureData.x = int(subTextureXML.attribute(ConstValues.A_X)) / scale;
				subTextureData.y = int(subTextureXML.attribute(ConstValues.A_Y)) / scale;
				subTextureData.width = int(subTextureXML.attribute(ConstValues.A_WIDTH)) / scale;
				subTextureData.height = int(subTextureXML.attribute(ConstValues.A_HEIGHT)) / scale;
				//1.4
				subTextureData.pivotX = int(subTextureXML.attribute(ConstValues.A_PIVOT_X));
				subTextureData.pivotY = int(subTextureXML.attribute(ConstValues.A_PIVOT_Y));
				_subTextureDataDic[subTextureName] = subTextureData;
			}
		}
		
		dragonBones_internal function movieClipToBitmapData():void
		{
			if (!_bitmapData && _movieClip)
			{
				_movieClip.gotoAndStop(1);
				_bitmapData = new BitmapData(_width, _height, true, 0xFF00FF);
				_bitmapData.draw(_movieClip);
				_movieClip.gotoAndStop(_movieClip.totalFrames);
			}
		}
	}
}