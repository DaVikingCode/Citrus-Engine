package dragonBones.cache
{
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.ArmatureData;
	import dragonBones.objects.BoneData;
	import dragonBones.objects.SlotData;
	import dragonBones.objects.SlotTimeline;
	import dragonBones.objects.TransformTimeline;

	public class AnimationCache
	{
		public var name:String;
//		public var boneTimelineCacheList:Vector.<BoneTimelineCache> = new Vector.<BoneTimelineCache>();
		public var slotTimelineCacheList:Vector.<SlotTimelineCache> = new Vector.<SlotTimelineCache>();
//		public var boneTimelineCacheDic:Object = {};
		public var slotTimelineCacheDic:Object = {};
		public var frameNum:int = 0;
		public function AnimationCache()
		{
		}
		
		public static function initWithAnimationData(animationData:AnimationData,armatureData:ArmatureData):AnimationCache
		{
			var output:AnimationCache = new AnimationCache();
			output.name = animationData.name;
			
			var boneTimelineList:Vector.<TransformTimeline> = animationData.timelineList;
			var boneName:String;
			var boneData:BoneData;
			var slotData:SlotData;
			var slotTimelineCache:SlotTimelineCache;
			var slotName:String;
			
			for(var i:int = 0, length:int = boneTimelineList.length; i < length; i++)
			{
				boneName = boneTimelineList[i].name;
				for (var j:int = 0, jlen:int = armatureData.slotDataList.length; j < jlen; j++)
				{
					slotData = armatureData.slotDataList[j];
					slotName = slotData.name;
					if (slotData.parent == boneName)
					{
						if (output.slotTimelineCacheDic[slotName] == null)
						{
							slotTimelineCache = new SlotTimelineCache();
							slotTimelineCache.name = slotName;
							output.slotTimelineCacheList.push(slotTimelineCache);
							output.slotTimelineCacheDic[slotName] = slotTimelineCache;
						}
						
					}
				}
			}
			return output;
		}
		
//		public function initBoneTimelineCacheDic(boneCacheGeneratorDic:Object, boneFrameCacheDic:Object):void
//		{
//			var name:String;
//			for each(var boneTimelineCache:BoneTimelineCache in boneTimelineCacheDic)
//			{
//				name = boneTimelineCache.name;
//				boneTimelineCache.cacheGenerator = boneCacheGeneratorDic[name];
//				boneTimelineCache.currentFrameCache = boneFrameCacheDic[name];
//			}
//		}
		
		public function initSlotTimelineCacheDic(slotCacheGeneratorDic:Object, slotFrameCacheDic:Object):void
		{
			var name:String;
			for each(var slotTimelineCache:SlotTimelineCache in slotTimelineCacheDic)
			{
				name = slotTimelineCache.name;
				slotTimelineCache.cacheGenerator = slotCacheGeneratorDic[name];
				slotTimelineCache.currentFrameCache = slotFrameCacheDic[name];
			}
		}
		
//		public function bindCacheUserBoneDic(boneDic:Object):void
//		{
//			for(var name:String in boneDic)
//			{
//				(boneTimelineCacheDic[name] as BoneTimelineCache).bindCacheUser(boneDic[name]);
//			}
//		}
		
		public function bindCacheUserSlotDic(slotDic:Object):void
		{
			for(var name:String in slotDic)
			{
				(slotTimelineCacheDic[name] as SlotTimelineCache).bindCacheUser(slotDic[name]);
			}
		}
		
		public function addFrame():void
		{
			frameNum++;
//			var boneTimelineCache:BoneTimelineCache;
//			for(var i:int = 0, length:int = boneTimelineCacheList.length; i < length; i++)
//			{
//				boneTimelineCache = boneTimelineCacheList[i];
//				boneTimelineCache.addFrame();
//			}
			
			var slotTimelineCache:SlotTimelineCache;
			for(var i:int = 0, length:int = slotTimelineCacheList.length; i < length; i++)
			{
				slotTimelineCache = slotTimelineCacheList[i];
				slotTimelineCache.addFrame();
			}
		}
			
		
		public function update(progress:Number):void
		{
			var frameIndex:int = progress * (frameNum-1);
			
//			var boneTimelineCache:BoneTimelineCache;
//			for(var i:int = 0, length:int = boneTimelineCacheList.length; i < length; i++)
//			{
//				boneTimelineCache = boneTimelineCacheList[i];
//				boneTimelineCache.update(frameIndex);
//			}
			
			var slotTimelineCache:SlotTimelineCache;
			for(var i:int = 0, length:int = slotTimelineCacheList.length; i < length; i++)
			{
				slotTimelineCache = slotTimelineCacheList[i];
				slotTimelineCache.update(frameIndex);
			}
		}
	}
}