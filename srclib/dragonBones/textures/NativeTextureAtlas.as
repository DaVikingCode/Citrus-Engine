package dragonBones.textures
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.DataParser;
	
	use namespace dragonBones_internal;
	
	/**
	 * The NativeTextureAtlas creates and manipulates TextureAtlas from traditional flash.display.DisplayObject.
	 */
	public class NativeTextureAtlas implements ITextureAtlas
	{
		/**
		 * @private
		 */
		protected var _subTextureDataDic:Object;
		/**
		 * @private
		 */
		protected var _isDifferentConfig:Boolean;
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
		 * @param texture A MovieClip or Bitmap.
		 * @param textureAtlasRawData The textureAtlas config data.
		 * @param textureScale A scale value (x and y axis)
		 * @param isDifferentConfig 
		 */
		public function NativeTextureAtlas(texture:Object, textureAtlasRawData:Object, textureScale:Number = 1, isDifferentConfig:Boolean = false)
		{
			_scale = textureScale;
			_isDifferentConfig = isDifferentConfig;
			if (texture is BitmapData)
			{
				_bitmapData = texture as BitmapData;
			}
			else if (texture is MovieClip)
			{
				_movieClip = texture as MovieClip;
				_movieClip.stop();
			}
			parseData(textureAtlasRawData);
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
		}
		/**
		 * The area occupied by all assets related to that name.
		 * @param name The name of these assets.
		 * @return Rectangle The area occupied by all assets related to that name.
		 */
		public function getRegion(name:String):Rectangle
		{
			var textureData:TextureData = _subTextureDataDic[name] as TextureData;
			if(textureData)
			{
				return textureData.region;
			}
			
			return null;
		}
		
		public function getFrame(name:String):Rectangle
		{
			var textureData:TextureData = _subTextureDataDic[name] as TextureData;
			if(textureData)
			{
				return textureData.frame;
			}
			
			return null;
		}
		
		protected function parseData(textureAtlasRawData:Object):void
		{
			_subTextureDataDic = DataParser.parseTextureAtlasData(textureAtlasRawData, _isDifferentConfig ? _scale : 1);
			_name = _subTextureDataDic.__name;
			
			delete _subTextureDataDic.__name;
		}
		
		dragonBones_internal function movieClipToBitmapData():void
		{
			if (!_bitmapData && _movieClip)
			{
				_movieClip.gotoAndStop(1);
				_bitmapData = new BitmapData(getNearest2N(_movieClip.width), getNearest2N(_movieClip.height), true, 0xFF00FF);
				_bitmapData.draw(_movieClip);
				_movieClip.gotoAndStop(_movieClip.totalFrames);
			}
		}
		
		private function getNearest2N(_n:uint):uint
		{
			return _n & _n - 1?1 << _n.toString(2).length:_n;
		}
	}
}