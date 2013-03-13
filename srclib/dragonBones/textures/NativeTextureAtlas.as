package dragonBones.textures
{
	import dragonBones.textures.SubTextureData;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.dragonBones_internal;
	
	
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	use namespace dragonBones_internal;
	
	/**
	 * A set of texture data
	 */
	public class NativeTextureAtlas implements ITextureAtlas
	{
		protected var _width:int;
		protected var _height:int;
		protected var _subTextureDataDic:Object;
		
		
		protected var _isDifferentXML:Boolean;
		
		protected var _name:String;
		public function get name():String
		{
			return _name;
		}
		
		protected var _movieClip:MovieClip;
		public function get movieClip():MovieClip
		{
			return _movieClip;
		}
		
		protected var _bitmapData:BitmapData;
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		protected var _scale:Number;
		public function get scale():Number
		{
			return _scale;
		}
		
		public function NativeTextureAtlas(texture:Object, textureAtlasXML:XML, textureScale:Number = 1, isDifferentXML:Boolean = false)
		{
			_scale = textureScale;
			_isDifferentXML = isDifferentXML;
			
			_subTextureDataDic = {};
			
			if(texture is BitmapData)
			{
				_bitmapData = texture as BitmapData;
			}
			else if(texture is MovieClip)
			{
				_movieClip = texture as MovieClip;
				_movieClip.stop();
			}
			
			parseData(textureAtlasXML);
		}
		
		public function dispose():void
		{
			_movieClip = null;
			
			if(_bitmapData)
			{
				_bitmapData.dispose();
			}
			_bitmapData = null;
			
			_subTextureDataDic = {};
		}
		
		public function getRegion(name:String):Rectangle
		{
			return _subTextureDataDic[name];
		}
		
		protected function parseData(textureAtlasXML:XML):void
		{
			_name = textureAtlasXML.attribute(ConstValues.A_NAME);
			_width = int(textureAtlasXML.attribute(ConstValues.A_WIDTH));
			_height = int(textureAtlasXML.attribute(ConstValues.A_HEIGHT));
			
			var scale:Number = _isDifferentXML?_scale:1;
			
			for each(var subTextureXML:XML in textureAtlasXML.elements(ConstValues.SUB_TEXTURE))
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