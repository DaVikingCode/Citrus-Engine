package dragonBones.utils
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import dragonBones.animation.TimelineState;
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.ArmatureData;
	import dragonBones.objects.BoneData;
	import dragonBones.objects.DBTransform;
	import dragonBones.objects.Frame;
	import dragonBones.objects.SkinData;
	import dragonBones.objects.SlotData;
	import dragonBones.objects.TransformFrame;
	import dragonBones.objects.TransformTimeline;
	import dragonBones.utils.TransformUtil;
	
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
						TransformUtil.transformPointWithParent(boneData.transform, parentBoneData.global);
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
				transformAnimationData(animationDataList[i], armatureData);
			}
		}
		
		public static function transformAnimationData(animationData:AnimationData, armatureData:ArmatureData):void
		{
			var skinData:SkinData = armatureData.getSkinData(null);
			var boneDataList:Vector.<BoneData> = armatureData.boneDataList;
			var slotDataList:Vector.<SlotData>;
			if(skinData)
			{
				slotDataList = skinData.slotDataList;
			}
			
			for(var i:int = 0;i < boneDataList.length;i ++)
			{
				var boneData:BoneData = boneDataList[i];
				var timeline:TransformTimeline = animationData.getTimeline(boneData.name);
				if(!timeline)
				{
					continue;
				}
				
				var slotData:SlotData = null;
				if(slotDataList)
				{
					for each(slotData in slotDataList)
					{
						if(slotData.parent == boneData.name)
						{
							break;
						}
					}
				}
				
				var frameList:Vector.<Frame> = timeline.frameList;
				
				var originTransform:DBTransform = null;
				var originPivot:Point = null;
				var prevFrame:TransformFrame = null;
				var frameListLength:uint = frameList.length;
				for(var j:int = 0;j < frameListLength;j ++)
				{
					var frame:TransformFrame = frameList[j] as TransformFrame;
					setFrameTransform(animationData, armatureData, boneData, frame);
					
					frame.transform.x -= boneData.transform.x;
					frame.transform.y -= boneData.transform.y;
					frame.transform.skewX -= boneData.transform.skewX;
					frame.transform.skewY -= boneData.transform.skewY;
					frame.transform.scaleX -= boneData.transform.scaleX;
					frame.transform.scaleY -= boneData.transform.scaleY;
					
					if(!timeline.transformed)
					{
						if(slotData)
						{
							frame.zOrder -= slotData.zOrder;
						}
					}
					
					if(!originTransform)
					{
						originTransform = timeline.originTransform;
						originTransform.copy(frame.transform);
						originTransform.skewX = TransformUtil.formatRadian(originTransform.skewX);
						originTransform.skewY = TransformUtil.formatRadian(originTransform.skewY);
						originPivot = timeline.originPivot;
						originPivot.x = frame.pivot.x;
						originPivot.y = frame.pivot.y;
					}
					
					frame.transform.x -= originTransform.x;
					frame.transform.y -= originTransform.y;
					frame.transform.skewX = TransformUtil.formatRadian(frame.transform.skewX - originTransform.skewX);
					frame.transform.skewY = TransformUtil.formatRadian(frame.transform.skewY - originTransform.skewY);
					frame.transform.scaleX -= originTransform.scaleX;
					frame.transform.scaleY -= originTransform.scaleY;
					
					if(!timeline.transformed)
					{
						frame.pivot.x -= originPivot.x;
						frame.pivot.y -= originPivot.y;
					}
					
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
				timeline.transformed = true;
			}
		}
		
		private static function setFrameTransform(animationData:AnimationData, armatureData:ArmatureData, boneData:BoneData, frame:TransformFrame):void
		{
			frame.transform.copy(frame.global);
			var parentData:BoneData = armatureData.getBoneData(boneData.parent);
			if(parentData)
			{
				var parentTimeline:TransformTimeline = animationData.getTimeline(parentData.name);
				if(parentTimeline)
				{
					/*
					var currentTransform:DBTransform = new DBTransform();
					getTimelineTransform(parentTimeline, frame.position, currentTransform, true);
					TransformUtil.transformPointWithParent(frame.transform, currentTransform);
					*/
					
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
					
					var helpMatrix:Matrix = new Matrix();
					var globalTransform:DBTransform;
					var currentTransform:DBTransform = new DBTransform();
					while(i --)
					{
						parentTimeline = parentTimelineList[i];
						parentData = parentDataList[i];
						getTimelineTransform(parentTimeline, frame.position, currentTransform, !globalTransform);
						
						if(globalTransform)
						{
							//if(inheritRotation)
							//{
								globalTransform.skewX += currentTransform.skewX + parentTimeline.originTransform.skewX + parentData.transform.skewX;
								globalTransform.skewY += currentTransform.skewY + parentTimeline.originTransform.skewY + parentData.transform.skewY;
							//}
							
							//if(inheritScale)
							//{
							//	globalTransform.scaleX *= currentTransform.scaleX + parentTimeline.originTransform.scaleX;
							//	globalTransform.scaleY *= currentTransform.scaleY + parentTimeline.originTransform.scaleY;
							//}
							//else
							//{
								globalTransform.scaleX = currentTransform.scaleX + parentTimeline.originTransform.scaleX + parentData.transform.scaleX;
								globalTransform.scaleY = currentTransform.scaleY + parentTimeline.originTransform.scaleY + parentData.transform.scaleY;
							//}
								
							var x:Number = currentTransform.x + parentTimeline.originTransform.x + parentData.transform.x;
							var y:Number = currentTransform.y + parentTimeline.originTransform.y + parentData.transform.y;
							
							globalTransform.x = helpMatrix.a * x + helpMatrix.c * y + helpMatrix.tx;
							globalTransform.y = helpMatrix.d * y + helpMatrix.b * x + helpMatrix.ty;
						}
						else
						{
							globalTransform = new DBTransform();
							globalTransform.copy(currentTransform);
						}
						
						TransformUtil.transformToMatrix(globalTransform, helpMatrix);
					}
					TransformUtil.transformPointWithParent(frame.transform, globalTransform);
					
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
				if(currentFrame.position <= position && currentFrame.position + currentFrame.duration > position)
				{
					var tweenEasing:Number = currentFrame.tweenEasing;
					if(i == frameList.length - 1 || position == currentFrame.position)
					{
						retult.copy(isGlobal?currentFrame.global:currentFrame.transform);
					}
					else
					{
						var progress:Number = (position - currentFrame.position) / currentFrame.duration;
						if(tweenEasing && tweenEasing != 10)
						{
							progress = TimelineState.getEaseValue(progress, tweenEasing);
						}
						var nextFrame:TransformFrame = frameList[i + 1] as TransformFrame;
						
						var currentTransform:DBTransform = isGlobal?currentFrame.global:currentFrame.transform;
						var nextTransform:DBTransform = isGlobal?nextFrame.global:nextFrame.transform;
						
						retult.x = currentTransform.x +  (nextTransform.x - currentTransform.x) * progress;
						retult.y = currentTransform.y +  (nextTransform.y - currentTransform.y) * progress;
						retult.skewX = TransformUtil.formatRadian(currentTransform.skewX +  (nextTransform.skewX - currentTransform.skewX) * progress);
						retult.skewY = TransformUtil.formatRadian(currentTransform.skewY +  (nextTransform.skewY - currentTransform.skewY) * progress);
						retult.scaleX = currentTransform.scaleX +  (nextTransform.scaleX - currentTransform.scaleX) * progress;
						retult.scaleY = currentTransform.scaleY +  (nextTransform.scaleY - currentTransform.scaleY) * progress;
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