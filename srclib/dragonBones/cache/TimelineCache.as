package dragonBones.cache
{
	import dragonBones.core.ICacheUser;

	public class TimelineCache
	{
		public var name:String;
		public var frameCacheList:Vector.<FrameCache> = new Vector.<FrameCache>();
		public var currentFrameCache:FrameCache;
		public function TimelineCache()
		{
		}
		
		public function addFrame():void
		{
		}
		public function update(frameIndex:int):void
		{
			currentFrameCache.copy(frameCacheList[frameIndex]);
		}
		
		public function bindCacheUser(cacheUser:ICacheUser):void
		{
			cacheUser.frameCache = currentFrameCache;
		}
	}
}