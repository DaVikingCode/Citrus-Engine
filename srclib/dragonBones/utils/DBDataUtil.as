package dragonBones.utils
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.ArmatureData;
	import dragonBones.objects.BoneData;
	import dragonBones.objects.DBTransform;
	import dragonBones.objects.Frame;
	import dragonBones.objects.SkinData;
	import dragonBones.objects.SlotData;
	import dragonBones.objects.SlotFrame;
	import dragonBones.objects.SlotTimeline;
	import dragonBones.objects.TransformFrame;
	import dragonBones.objects.TransformTimeline;
	
	/** @private */
	public final class DBDataUtil
	{
		public static function transformArmatureData(armatureData:ArmatureData):void
		{
			var boneDataList:Vector.<BoneData> = armatureData.boneDataList;
			var i:int = boneDataList.length;
			
			while(i --)
			{
				var boneData:BoneData = boneDataList[i];
				if(boneData.parent)
				{
					var parentBoneData:BoneData = armatureData.getBoneData(boneData.parent);
					if(parentBoneData)
					{
						boneData.transform.copy(boneData.global);
						boneData.transform.divParent(parentBoneData.global);
//						TransformUtil.globalToLocal(boneData.transform, parentBoneData.global);
					}
				}
			}
		}
		
		public static function transformArmatureDataAnimations(armatureData:ArmatureData):void
		{
			var animationDataList:Vector.<AnimationData> = armatureData.animationDataList;
			var i:int = animationDataList.length;
			while(i --)
			{
				transformAnimationData(animationDataList[i], armatureData, false);
			}
		}
		
		public static function transformRelativeAnimationData(animationData:AnimationData, armatureData:ArmatureData):void
		{
			
		}
		
		public static function transformAnimationData(animationData:AnimationData, armatureData:ArmatureData, isGlobalData:Boolean):void
		{
			if(!isGlobalData)
			{
				transformRelativeAnimationData(animationData, armatureData);
				return;
			}
			
			var skinData:SkinData = armatureData.getSkinData(null);
			var boneDataList:Vector.<BoneData> = armatureData.boneDataList;
			var slotDataList:Vector.<SlotData>;
			if(skinData)
			{
				slotDataList = armatureData.slotDataList;
			}
			
			for(var i:int = 0;i < boneDataList.length;i ++)
			{
				var boneData:BoneData = boneDataList[i];
				//绝对数据是不可能有slotTimeline的
				var timeline:TransformTimeline = animationData.getTimeline(boneData.name);
				var slotTimeline:SlotTimeline = animationData.getSlotTimeline(boneData.name);
				if(!timeline && !slotTimeline)
				{
					continue;
				}
				
				var slotData:SlotData = null;
				if(slotDataList)
				{
					for each(slotData in slotDataList)
					{
						//找到属于当前Bone的slot(FLash Pro制作的动画一个Bone只包含一个slot)
						if(slotData.parent == boneData.name)
						{
							break;
						}
					}
				}
				
				var frameList:Vector.<Frame> = timeline.frameList;
				if (slotTimeline)
				{
					var slotFrameList:Vector.<Frame> = slotTimeline.frameList;
				}
				
				var originTransform:DBTransform = null;
				var originPivot:Point = null;
				var prevFrame:TransformFrame = null;
				var frameListLength:uint = frameList.length;
				for(var j:int = 0;j < frameListLength;j ++)
				{
					var frame:TransformFrame = frameList[j] as TransformFrame;
					//计算frame的transform信息
					setFrameTransform(animationData, armatureData, boneData, frame);
					
					//转换成相对骨架的transform信息
					frame.transform.x -= boneData.transform.x;
					frame.transform.y -= boneData.transform.y;
					frame.transform.skewX -= boneData.transform.skewX;
					frame.transform.skewY -= boneData.transform.skewY;
					frame.transform.scaleX /= boneData.transform.scaleX;
					frame.transform.scaleY /= boneData.transform.scaleY;
					
					//if(!timeline.transformed)
					//{
						//if(slotData)
						//{
							////frame.zOrder -= slotData.zOrder;
						//}
					//}
					
					//如果originTransform不存在说明当前帧是第一帧，将当前帧的transform保存至timeline的originTransform
					//if(!originTransform)
					//{
						//originTransform = timeline.originTransform;
						//originTransform.copy(frame.transform);
						//originTransform.skewX = TransformUtil.formatRadian(originTransform.skewX);
						//originTransform.skewY = TransformUtil.formatRadian(originTransform.skewY);
						//originPivot = timeline.originPivot;
						//originPivot.x = frame.pivot.x;
						//originPivot.y = frame.pivot.y;
					//}
					//
					//frame.transform.x -= originTransform.x;
					//frame.transform.y -= originTransform.y;
					//frame.transform.skewX = TransformUtil.formatRadian(frame.transform.skewX - originTransform.skewX);
					//frame.transform.skewY = TransformUtil.formatRadian(frame.transform.skewY - originTransform.skewY);
					//frame.transform.scaleX /= originTransform.scaleX;
					//frame.transform.scaleY /= originTransform.scaleY;
					//
					//if(!timeline.transformed)
					//{
						//frame.pivot.x -= originPivot.x;
						//frame.pivot.y -= originPivot.y;
					//}
					
					if(prevFrame)
					{
						var dLX:Number = frame.transform.skewX - prevFrame.transform.skewX;
						
						if(prevFrame.tweenRotate)
						{
							
							if(prevFrame.tweenRotate > 0)
							{
								if(dLX < 0)
								{
									frame.transform.skewX += Math.PI * 2;
									frame.transform.skewY += Math.PI * 2;
								}
								
								if(prevFrame.tweenRotate > 1)
								{
									frame.transform.skewX += Math.PI * 2 * (prevFrame.tweenRotate - 1);
									frame.transform.skewY += Math.PI * 2 * (prevFrame.tweenRotate - 1);
								}
							}
							else
							{
								if(dLX > 0)
								{
									frame.transform.skewX -= Math.PI * 2;
									frame.transform.skewY -= Math.PI * 2;
								}
								
								if(prevFrame.tweenRotate < 1)
								{
									frame.transform.skewX += Math.PI * 2 * (prevFrame.tweenRotate + 1);
									frame.transform.skewY += Math.PI * 2 * (prevFrame.tweenRotate + 1);
								}
							}
						}
						else
						{
							frame.transform.skewX = prevFrame.transform.skewX + TransformUtil.formatRadian(frame.transform.skewX - prevFrame.transform.skewX);
							frame.transform.skewY = prevFrame.transform.skewY + TransformUtil.formatRadian(frame.transform.skewY - prevFrame.transform.skewY);
						}
					}
					prevFrame = frame;
				}
				
				if (slotTimeline && slotFrameList)
				{
					frameListLength = slotFrameList.length;
					for(j = 0;j < frameListLength;j ++)
					{
						var slotFrame:SlotFrame = slotFrameList[j] as SlotFrame;
						
						if(!slotTimeline.transformed)
						{
							if(slotData)
							{
								slotFrame.zOrder -= slotData.zOrder;
							}
						}
					}
					slotTimeline.transformed = true;
				}
				
				timeline.transformed = true;
				
			}
		}
		
		//计算frame的transoform信息
		private static function setFrameTransform(animationData:AnimationData, armatureData:ArmatureData, boneData:BoneData, frame:TransformFrame):void
		{
			frame.transform.copy(frame.global);
			//找到当前bone的父亲列表 并将timeline信息存入parentTimelineList 将boneData信息存入parentDataList
			var parentData:BoneData = armatureData.getBoneData(boneData.parent);
			if(parentData)
			{
				var parentTimeline:TransformTimeline = animationData.getTimeline(parentData.name);
				if(parentTimeline)
				{
					var parentTimelineList:Vector.<TransformTimeline> = new Vector.<TransformTimeline>;
					var parentDataList:Vector.<BoneData> = new Vector.<BoneData>;
					while(parentTimeline)
					{
						parentTimelineList.push(parentTimeline);
						parentDataList.push(parentData);
						parentData = armatureData.getBoneData(parentData.parent);
						if(parentData)
						{
							parentTimeline = animationData.getTimeline(parentData.name);
						}
						else
						{
							parentTimeline = null;
						}
					}
					
					var i:int = parentTimelineList.length;
					
					var globalTransform:DBTransform;
					var globalTransformMatrix:Matrix = new Matrix();
					
					var currentTransform:DBTransform = new DBTransform();
					var currentTransformMatrix:Matrix = new Matrix();
					//从根开始遍历
					while(i --)
					{
						parentTimeline = parentTimelineList[i];
						parentData = parentDataList[i];
						//一级一级找到当前帧对应的每个父节点的transform(相对transform) 保存到currentTransform，globalTransform保存根节点的transform
						getTimelineTransform(parentTimeline, frame.position, currentTransform, !globalTransform);
						
						if(!globalTransform)
						{
							globalTransform = new DBTransform();
							globalTransform.copy(currentTransform);	
						}
						else
						{
							currentTransform.x += parentTimeline.originTransform.x + parentData.transform.x;
							currentTransform.y += parentTimeline.originTransform.y + parentData.transform.y;
							
							currentTransform.skewX += parentTimeline.originTransform.skewX + parentData.transform.skewX;
							currentTransform.skewY += parentTimeline.originTransform.skewY + parentData.transform.skewY;
							
							currentTransform.scaleX *= parentTimeline.originTransform.scaleX * parentData.transform.scaleX;
							currentTransform.scaleY *= parentTimeline.originTransform.scaleY * parentData.transform.scaleY;
							
							TransformUtil.transformToMatrix(currentTransform, currentTransformMatrix);
							currentTransformMatrix.concat(globalTransformMatrix);
							TransformUtil.matrixToTransform(currentTransformMatrix, globalTransform, currentTransform.scaleX * globalTransform.scaleX >= 0, currentTransform.scaleY * globalTransform.scaleY >= 0);
							
						}
						
						TransformUtil.transformToMatrix(globalTransform, globalTransformMatrix);
					}
//					TransformUtil.globalToLocal(frame.transform, globalTransform);	
					frame.transform.divParent(globalTransform);
				}
			}
		}
		
		private static function getTimelineTransform(timeline:TransformTimeline, position:int, retult:DBTransform, isGlobal:Boolean):void
		{
			var frameList:Vector.<Frame> = timeline.frameList;
			var i:int = frameList.length;
			
			while(i --)
			{
				var currentFrame:TransformFrame = frameList[i] as TransformFrame;
				//找到穿越当前帧的关键帧
				if(currentFrame.position <= position && currentFrame.position + currentFrame.duration > position)
				{
					//是最后一帧或者就是当前帧
					if(i == frameList.length - 1 || position == currentFrame.position)
					{
						retult.copy(isGlobal?currentFrame.global:currentFrame.transform);
					}
					else
					{
						var tweenEasing:Number = currentFrame.tweenEasing;
						var progress:Number = (position - currentFrame.position) / currentFrame.duration;
						if(tweenEasing && tweenEasing != 10)
						{
							progress = MathUtil.getEaseValue(progress, tweenEasing);
						}
						var nextFrame:TransformFrame = frameList[i + 1] as TransformFrame;
						
						var currentTransform:DBTransform = isGlobal?currentFrame.global:currentFrame.transform;
						var nextTransform:DBTransform = isGlobal?nextFrame.global:nextFrame.transform;
						
						retult.x = currentTransform.x + (nextTransform.x - currentTransform.x) * progress;
						retult.y = currentTransform.y + (nextTransform.y - currentTransform.y) * progress;
						retult.skewX = TransformUtil.formatRadian(currentTransform.skewX + (nextTransform.skewX - currentTransform.skewX) * progress);
						retult.skewY = TransformUtil.formatRadian(currentTransform.skewY + (nextTransform.skewY - currentTransform.skewY) * progress);
						retult.scaleX = currentTransform.scaleX + (nextTransform.scaleX - currentTransform.scaleX) * progress;
						retult.scaleY = currentTransform.scaleY + (nextTransform.scaleY - currentTransform.scaleY) * progress;
					}
					break;
				}
			}
		}
		
		public static function addHideTimeline(animationData:AnimationData, armatureData:ArmatureData):void
		{
			var boneDataList:Vector.<BoneData> =armatureData.boneDataList;
			var i:int = boneDataList.length;
			
			while(i --)
			{
				var boneData:BoneData = boneDataList[i];
				var boneName:String = boneData.name;
				if(!animationData.getTimeline(boneName))
				{
					if(animationData.hideTimelineNameMap.indexOf(boneName) < 0)
					{
						animationData.hideTimelineNameMap.fixed = false;
						animationData.hideTimelineNameMap.push(boneName);
						animationData.hideTimelineNameMap.fixed = true;
					}
				}
			}
		}
	}
}