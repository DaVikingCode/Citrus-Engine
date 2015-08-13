package dragonBones.cache
{
	import dragonBones.core.IAnimationState;
	import dragonBones.core.ICacheUser;
	import dragonBones.core.ICacheableArmature;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.ArmatureData;

	use namespace dragonBones_internal;
	
	public class AnimationCacheManager
	{
		public var cacheGeneratorArmature:ICacheableArmature
		public var armatureData:ArmatureData;
		public var frameRate:Number;
		public var animationCacheDic:Object = {};
//		public var boneFrameCacheDic:Object = {};
		public var slotFrameCacheDic:Object = {};
		public function AnimationCacheManager()
		{
		}
		
		public static function initWithArmatureData(armatureData:ArmatureData, frameRate:Number = 0):AnimationCacheManager
		{
			var output:AnimationCacheManager = new AnimationCacheManager();
			output.armatureData = armatureData;
			if(frameRate<=0)
			{
				var animationData:AnimationData = armatureData.animationDataList[0];
				if(animationData)
				{
					output.frameRate = animationData.frameRate;
				}
			}
			else
			{
				output.frameRate = frameRate;
			}
			
			return output;
		}
		
		public function initAllAnimationCache():void
		{
			for each(var animationData:AnimationData in armatureData.animationDataList)
			{
				animationCacheDic[animationData.name] = AnimationCache.initWithAnimationData(animationData,armatureData);
			}
		}
		
		public function initAnimationCache(animationName:String):void
		{
			animationCacheDic[animationName] = AnimationCache.initWithAnimationData(armatureData.getAnimationData(animationName),armatureData);
		}
		
		public function bindCacheUserArmatures(armatures:Array):void
		{
			for each(var armature:ICacheableArmature in armatures)
			{
				bindCacheUserArmature(armature);
			}
			
		}
		
		public function bindCacheUserArmature(armature:ICacheableArmature):void
		{
			armature.getAnimation().animationCacheManager = this;
			
			var slotDic:Object = armature.getSlotDic();
			var cacheUser:ICacheUser;
//			for each(cacheUser in armature._boneDic)
//			{
//				cacheUser.frameCache = boneFrameCacheDic[cacheUser.name];
//			}
			for each(cacheUser in slotDic)
			{
				cacheUser.frameCache = slotFrameCacheDic[cacheUser.name];
			}
		}
		
		public function setCacheGeneratorArmature(armature:ICacheableArmature):void
		{
			cacheGeneratorArmature = armature;
			
			var slotDic:Object = armature.getSlotDic();
			var cacheUser:ICacheUser;
//			for each(cacheUser in armature._boneDic)
//			{
//				boneFrameCacheDic[cacheUser.name] = new FrameCache();
//			}
			for each(cacheUser in armature.getSlotDic())
			{
				slotFrameCacheDic[cacheUser.name] = new SlotFrameCache();
			}
			
			for each(var animationCache:AnimationCache in animationCacheDic)
			{
//				animationCache.initBoneTimelineCacheDic(armature._boneDic, boneFrameCacheDic);
				animationCache.initSlotTimelineCacheDic(slotDic, slotFrameCacheDic);
			}
		}
		
		public function generateAllAnimationCache(loop:Boolean):void
		{
			for each(var animationCache:AnimationCache in animationCacheDic)
			{
				generateAnimationCache(animationCache.name, loop);
			}
		}
		
		public function generateAnimationCache(animationName:String, loop:Boolean):void
		{
			var temp:Boolean = cacheGeneratorArmature.enableCache;
			cacheGeneratorArmature.enableCache = false;
			var animationCache:AnimationCache = animationCacheDic[animationName];
			if(!animationCache)
			{
				return;
			}
			
			var animationState:IAnimationState = cacheGeneratorArmature.getAnimation().animationState;
			var passTime:Number = 1 / frameRate;
				
			if (loop)
			{
				cacheGeneratorArmature.getAnimation().gotoAndPlay(animationName,0,-1,0);
			}
			else
			{
				cacheGeneratorArmature.getAnimation().gotoAndPlay(animationName,0,-1,1);
			}
			
			var tempEnableEventDispatch:Boolean = cacheGeneratorArmature.enableEventDispatch;
			cacheGeneratorArmature.enableEventDispatch = false;
			var lastProgress:Number;
			do
			{
				lastProgress = animationState.progress;
				cacheGeneratorArmature.advanceTime(passTime);
				animationCache.addFrame();
			}
			while (animationState.progress >= lastProgress && animationState.progress < 1);
			
			cacheGeneratorArmature.enableEventDispatch = tempEnableEventDispatch;
			resetCacheGeneratorArmature();
			cacheGeneratorArmature.enableCache = temp;
		}
		
		/**
		 * 将缓存生成器骨架重置，生成动画缓存后调用。
		 */
		public function resetCacheGeneratorArmature():void
		{
			cacheGeneratorArmature.resetAnimation();
		}
		
		public function getAnimationCache(animationName:String):AnimationCache
		{
			return animationCacheDic[animationName];
		} 
	}
}