package dragonBones.objects
{
	import dragonBones.utils.dragonBones_internal;
	import flash.events.EventDispatcher;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	use namespace dragonBones_internal;
	
	/** Dispatched when the textureData init completed. */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * A set of texture datas
	 */
	public class TextureAtlasData extends EventDispatcher
	{
		dragonBones_internal var _starlingTexture:Object;
		
		private var _starlingSubTextures:Object;
		private var _subTextureDatas:Object;
		
		internal var _name:String;
		public function get name():String
		{
			return _name;
		}
		
		internal var _width:int;
		public function get width():int
		{
			return _width;
		}
		
		internal var _height:uint;
		public function get height():int
		{
			return _height;
		}
		
		internal var _dataType:String;
		public function get dataType():String
		{
			return _dataType;
		}
		
		internal var _rawData:ByteArray;
		public function get rawData():ByteArray
		{
			return _rawData;
		}
		
		private var _clip:MovieClip;
		public function get clip():MovieClip
		{
			return _clip;
		}
		
		private var _bitmap:Bitmap;
		public function get bitmap():Bitmap
		{
			if (!_bitmap && clip)
			{
				clip.gotoAndStop(1);
				_bitmap = new Bitmap();
				_bitmap.bitmapData = new BitmapData(width, height, true, 0xFF00FF);
				_bitmap.bitmapData.draw(clip);
				clip.gotoAndStop(clip.totalFrames);
			}
			return _bitmap;
		}
		
		public function TextureAtlasData()
		{
			_subTextureDatas = {};
		}
		
		public function dispose():void
		{
			_clip = null;
			
			if(_bitmap && _bitmap.bitmapData)
			{
				_bitmap.bitmapData.dispose();
			}
			_bitmap = null;
			
			if(_starlingTexture && ("dispose" in _starlingTexture))
			{
				_starlingTexture.dispose();
			}
			_starlingTexture = null;
			
			for each(var starlingSubTexture:Object in _starlingSubTextures)
			{
				if("dispose" in starlingSubTexture)
				{
					starlingSubTexture.dispose();
				}
			}
			_starlingSubTextures = null;
			
			_subTextureDatas = null;
		}
		
		public function getSubTextureData(name:String):SubTextureData
		{
			return _subTextureDatas[name];
		}
		
		internal function addSubTextureData(data:SubTextureData):void
		{
			var name:String = data.name;
			_subTextureDatas[name] = data;
		}
		
		dragonBones_internal function addStarlingSubTexture(name:String, data:Object):void
		{
			if(!_starlingSubTextures)
			{
				_starlingSubTextures = { };
			}
			_starlingSubTextures[name] = data;
		}
		
		dragonBones_internal function getStarlingSubTexture(name:String):Object
		{
			return _starlingSubTextures?_starlingSubTextures[name]:null;
		}
		
		internal function loaderCompleteHandler(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
			var loader:Loader = e.target.loader;
			var content:Object = e.target.content;
			loader.unloadAndStop();
			
			if (content is Bitmap)
			{
				_bitmap = content as Bitmap;
			}
			else
			{
				_clip = content.getChildAt(0) as MovieClip;
			}
			completeHandler();
		}
		
		internal function completeHandler():void
		{
			if(hasEventListener(Event.COMPLETE))
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
	}
}