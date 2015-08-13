package dragonBones.objects
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	/** Dispatched after a sucessful call to parseTextureAtlasBytes(). */
	[Event(name="complete", type="flash.events.Event")]
	public class DecompressedData extends EventDispatcher
	{
		/**
		 * data name.
		 */
		public var name:String;
		
		public var textureBytesDataType:String;
		/**
		 * The xml or JSON for DragonBones data.
		 */
		public var dragonBonesData:Object;
		
		/**
		 * The xml or JSON for atlas data.
		 */
		public var textureAtlasData:Object;
		
		/**
		 * The non parsed textureAtlas bytes.
		 */
		public var textureAtlasBytes:ByteArray;
		
		/**
		 * TextureAtlas can be bitmap, movieclip, ATF etc.
		 */
		public var textureAtlas:Object;
		
		public function DecompressedData()
		{
		}
		
		public function dispose():void
		{
			dragonBonesData = null;
			textureAtlasData = null;
			textureAtlas = null;
			textureAtlasBytes = null;
		}
		
		public function parseTextureAtlasBytes():void
		{
			var loader:TextureAtlasByteArrayLoader = new TextureAtlasByteArrayLoader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.loadBytes(textureAtlasBytes);
		}
		
		private function loaderCompleteHandler(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
			var loader:Loader = e.target.loader;
			var content:Object = e.target.content;
			loader.unloadAndStop();
			
			if (content is Bitmap)
			{
				textureAtlas =  (content as Bitmap).bitmapData;
			}
			else if (content is Sprite)
			{
				textureAtlas = (content as Sprite).getChildAt(0) as MovieClip;
			}
			else
			{
				//ATF
				textureAtlas = content;
			}
			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}