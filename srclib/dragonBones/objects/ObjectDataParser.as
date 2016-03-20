package dragonBones.objects {

	import dragonBones.core.DragonBones;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.textures.TextureData;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.DBDataUtil;

	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	use namespace dragonBones_internal;
	
	public final class ObjectDataParser
	{
		private static var tempDragonBonesData:DragonBonesData;
		
		public static function parseTextureAtlasData(rawData:Object, scale:Number = 1):Object
		{
			var textureAtlasData:Object = {};
			textureAtlasData.__name = rawData[ConstValues.A_NAME];
			var subTextureFrame:Rectangle;
			for each (var subTextureObject:Object in rawData[ConstValues.SUB_TEXTURE])
			{
				var subTextureName:String = subTextureObject[ConstValues.A_NAME];
				var subTextureRegion:Rectangle = new Rectangle();
				subTextureRegion.x = int(subTextureObject[ConstValues.A_X]) / scale;
				subTextureRegion.y = int(subTextureObject[ConstValues.A_Y]) / scale;
				subTextureRegion.width = int(subTextureObject[ConstValues.A_WIDTH]) / scale;
				subTextureRegion.height = int(subTextureObject[ConstValues.A_HEIGHT]) / scale;
				
				var rotated:Boolean = subTextureObject[ConstValues.A_ROTATED] == "true";
				
				var frameWidth:Number = int(subTextureObject[ConstValues.A_FRAME_WIDTH]) / scale;
				var frameHeight:Number = int(subTextureObject[ConstValues.A_FRAME_HEIGHT]) / scale;
				
				if(frameWidth > 0 && frameHeight > 0)
				{
					subTextureFrame = new Rectangle();
					subTextureFrame.x = int(subTextureObject[ConstValues.A_FRAME_X]) / scale;
					subTextureFrame.y = int(subTextureObject[ConstValues.A_FRAME_Y]) / scale;
					subTextureFrame.width = frameWidth;
					subTextureFrame.height = frameHeight;
				}
				else
				{
					subTextureFrame = null;
				}
				
				textureAtlasData[subTextureName] = new TextureData(subTextureRegion, subTextureFrame, rotated);
			}
			
			return textureAtlasData;
		}
		
		public static function parseDragonBonesData(rawDataToParse:Object):DragonBonesData
		{
			if(!rawDataToParse)
			{
				throw new ArgumentError();
			}
			
			var version:String = rawDataToParse[ConstValues.A_VERSION];
			switch (version)
			{
				case "2.3":
				case "3.0":
					return Object3DataParser.parseSkeletonData(rawDataToParse);
					break;
				case DragonBones.DATA_VERSION:
					break;
				
				default:
					throw new Error("Nonsupport version!");
			}
			
			var frameRate:uint = int(rawDataToParse[ConstValues.A_FRAME_RATE]);
			
			var outputDragonBonesData:DragonBonesData =  new DragonBonesData();
			outputDragonBonesData.name = rawDataToParse[ConstValues.A_NAME];
			outputDragonBonesData.isGlobalData = rawDataToParse[ConstValues.A_IS_GLOBAL] == "0" ? false : true;
			tempDragonBonesData = outputDragonBonesData;
			
			for each(var armatureObject:Object in rawDataToParse[ConstValues.ARMATURE])
			{
				outputDragonBonesData.addArmatureData(parseArmatureData(armatureObject, frameRate));
			}
			
			tempDragonBonesData = null;
			
			return outputDragonBonesData;
		}
		
		private static function parseArmatureData(armatureDataToParse:Object, frameRate:uint):ArmatureData
		{
			var outputArmatureData:ArmatureData = new ArmatureData();
			outputArmatureData.name = armatureDataToParse[ConstValues.A_NAME];
			
			for each(var boneObject:Object in armatureDataToParse[ConstValues.BONE])
			{
				outputArmatureData.addBoneData(parseBoneData(boneObject));
			}
			
			for each(var slotObject:Object in armatureDataToParse[ConstValues.SLOT])
			{
				outputArmatureData.addSlotData(parseSlotData(slotObject));
			}
			
			for each(var skinObject:Object in armatureDataToParse[ConstValues.SKIN])
			{
				outputArmatureData.addSkinData(parseSkinData(skinObject));
			}
			
			if(tempDragonBonesData.isGlobalData)
			{
				DBDataUtil.transformArmatureData(outputArmatureData);
			}
			
			outputArmatureData.sortBoneDataList();
		
			for each(var animationObject:Object in armatureDataToParse[ConstValues.ANIMATION])
			{
				var animationData:AnimationData = parseAnimationData(animationObject, frameRate);
				DBDataUtil.addHideTimeline(animationData, outputArmatureData);
				DBDataUtil.transformAnimationData(animationData, outputArmatureData, tempDragonBonesData.isGlobalData);
				outputArmatureData.addAnimationData(animationData);
			}
			
			return outputArmatureData;
		}
		
		//把bone的初始transform解析并返回
		private static function parseBoneData(boneObject:Object):BoneData
		{
			var boneData:BoneData = new BoneData();
			boneData.name = boneObject[ConstValues.A_NAME];
			boneData.parent = boneObject[ConstValues.A_PARENT];
			boneData.length = Number(boneObject[ConstValues.A_LENGTH]);
			boneData.inheritRotation = getBoolean(boneObject, ConstValues.A_INHERIT_ROTATION, true);
			boneData.inheritScale = getBoolean(boneObject, ConstValues.A_INHERIT_SCALE, true);
			
			parseTransform(boneObject[ConstValues.TRANSFORM], boneData.transform);
			if(tempDragonBonesData.isGlobalData)//绝对数据
			{
				boneData.global.copy(boneData.transform);
			}
			return boneData;
		}
		
		private static function parseSkinData(skinObject:Object):SkinData
		{
			var skinData:SkinData = new SkinData();
			skinData.name = skinObject[ConstValues.A_NAME];
			
			for each(var slotObject:Object in skinObject[ConstValues.SLOT])
			{
				skinData.addSlotData(parseSlotDisplayData(slotObject));
			}
			
			return skinData;
		}
		
		private static function parseSlotDisplayData(slotObject:Object):SlotData
		{
			var slotData:SlotData = new SlotData();
			slotData.name = slotObject[ConstValues.A_NAME];
			for each(var displayObject:Object in slotObject[ConstValues.DISPLAY])
			{
				slotData.addDisplayData(parseDisplayData(displayObject));
			}
			
			return slotData;
		}
		
		private static function parseSlotData(slotObject:Object):SlotData
		{
			var slotData:SlotData = new SlotData();
			slotData.name = slotObject[ConstValues.A_NAME];
			slotData.parent = slotObject[ConstValues.A_PARENT];
			slotData.zOrder = getNumber(slotObject, ConstValues.A_Z_ORDER, 0) || 0;
			slotData.blendMode = slotObject[ConstValues.A_BLENDMODE];
			slotData.displayIndex = slotObject[ConstValues.A_DISPLAY_INDEX];
			//for each(var displayObject:Object in slotObject[ConstValues.DISPLAY])
			//{
				//slotData.addDisplayData(parseDisplayData(displayObject));
			//}
			
			return slotData;
		}
		
		private static function parseDisplayData(displayObject:Object):DisplayData
		{
			var displayData:DisplayData = new DisplayData();
			displayData.name = displayObject[ConstValues.A_NAME];
			displayData.type = displayObject[ConstValues.A_TYPE];
			parseTransform(displayObject[ConstValues.TRANSFORM], displayData.transform, displayData.pivot);
			displayData.pivot.x = NaN;
			displayData.pivot.y = NaN;
			if(tempDragonBonesData!=null)
			{
				tempDragonBonesData.addDisplayData(displayData);
			}
			
			return displayData;
		}
		
		/** @private */
		dragonBones_internal static function parseAnimationData(animationObject:Object, frameRate:uint):AnimationData
		{
			var animationData:AnimationData = new AnimationData();
			animationData.name = animationObject[ConstValues.A_NAME];
			animationData.frameRate = frameRate;
			animationData.duration = Math.round((Number(animationObject[ConstValues.A_DURATION]) || 1) * 1000 / frameRate);
			animationData.playTimes = int(getNumber(animationObject, ConstValues.A_PLAY_TIMES, 1));
			animationData.fadeTime = getNumber(animationObject, ConstValues.A_FADE_IN_TIME, 0) || 0;
			animationData.scale = getNumber(animationObject, ConstValues.A_SCALE, 1) || 0;
			//use frame tweenEase, NaN
			//overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			animationData.tweenEasing = getNumber(animationObject, ConstValues.A_TWEEN_EASING, NaN);
			animationData.autoTween = getBoolean(animationObject, ConstValues.A_AUTO_TWEEN, true);
			
			for each(var frameObject:Object in animationObject[ConstValues.FRAME])
			{
				var frame:Frame = parseTransformFrame(frameObject, frameRate);
				animationData.addFrame(frame);
			}
			
			parseTimeline(animationObject, animationData);
			
			var lastFrameDuration:int = animationData.duration;
			for each(var timelineObject:Object in animationObject[ConstValues.BONE])
			{
				var timeline:TransformTimeline = parseTransformTimeline(timelineObject, animationData.duration, frameRate);
				if (timeline.frameList.length > 0)
				{
					lastFrameDuration = Math.min(lastFrameDuration, timeline.frameList[timeline.frameList.length - 1].duration);
					animationData.addTimeline(timeline);
				}
				
			}
			
			for each(var slotTimelineObject:Object in animationObject[ConstValues.SLOT])
			{
				var slotTimeline:SlotTimeline = parseSlotTimeline(slotTimelineObject, animationData.duration, frameRate);
				if (slotTimeline.frameList.length > 0)
				{
					lastFrameDuration = Math.min(lastFrameDuration, slotTimeline.frameList[slotTimeline.frameList.length - 1].duration);
					animationData.addSlotTimeline(slotTimeline);
				}
				
			}
			
			if(animationData.frameList.length > 0)
			{
				lastFrameDuration = Math.min(lastFrameDuration, animationData.frameList[animationData.frameList.length - 1].duration);
			}
			//取得timeline中最小的lastFrameDuration并保存
			animationData.lastFrameDuration = lastFrameDuration;
			
			return animationData;
		}
		
		private static function parseTransformTimeline(timelineObject:Object, duration:int, frameRate:uint):TransformTimeline
		{
			var outputTimeline:TransformTimeline = new TransformTimeline();
			outputTimeline.name = timelineObject[ConstValues.A_NAME];
			outputTimeline.scale = getNumber(timelineObject, ConstValues.A_SCALE, 1) || 0;
			outputTimeline.offset = getNumber(timelineObject, ConstValues.A_OFFSET, 0) || 0;
			outputTimeline.originPivot.x = getNumber(timelineObject, ConstValues.A_PIVOT_X, 0) || 0;
			outputTimeline.originPivot.y = getNumber(timelineObject, ConstValues.A_PIVOT_Y, 0) || 0;
			outputTimeline.duration = duration;
			
			for each(var frameObject:Object in timelineObject[ConstValues.FRAME])
			{
				var frame:TransformFrame = parseTransformFrame(frameObject, frameRate);
				outputTimeline.addFrame(frame);
			}
			
			parseTimeline(timelineObject, outputTimeline);
			
			return outputTimeline;
		}
		
		private static function parseSlotTimeline(timelineObject:Object, duration:int, frameRate:uint):SlotTimeline
		{
			var timeline:SlotTimeline = new SlotTimeline();
			timeline.name = timelineObject[ConstValues.A_NAME];
			timeline.scale = getNumber(timelineObject, ConstValues.A_SCALE, 1) || 0;
			timeline.offset = getNumber(timelineObject, ConstValues.A_OFFSET, 0) || 0;
			//timeline.originPivot.x = getNumber(timelineXML, ConstValues.A_PIVOT_X, 0) || 0;
			//timeline.originPivot.y = getNumber(timelineXML, ConstValues.A_PIVOT_Y, 0) || 0;
			timeline.duration = duration;
			
			for each(var frameObject:Object in timelineObject[ConstValues.FRAME])
			{
				var frame:SlotFrame = parseSlotFrame(frameObject, frameRate);
				timeline.addFrame(frame);
			}
			
			parseTimeline(timelineObject, timeline);
			
			return timeline;
		}
		
		private static function parseMainFrame(frameObject:Object, frameRate:uint):Frame
		{
			var frame:Frame = new Frame();
			parseFrame(frameObject, frame, frameRate);
			return frame;
		}
		
		private static function parseTransformFrame(frameObject:Object, frameRate:uint):TransformFrame
		{
			var outputFrame:TransformFrame = new TransformFrame();
			parseFrame(frameObject, outputFrame, frameRate);
			
			outputFrame.visible = !getBoolean(frameObject, ConstValues.A_HIDE, false);
			
			//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			outputFrame.tweenEasing = getNumber(frameObject, ConstValues.A_TWEEN_EASING, 10);
			outputFrame.tweenRotate = int(getNumber(frameObject, ConstValues.A_TWEEN_ROTATE, 0));
			outputFrame.tweenScale = getBoolean(frameObject, ConstValues.A_TWEEN_SCALE, true);
//			outputFrame.displayIndex = int(getNumber(frameObject, ConstValues.A_DISPLAY_INDEX, 0));
			
			parseTransform(frameObject[ConstValues.TRANSFORM], outputFrame.transform, outputFrame.pivot);
			if(tempDragonBonesData.isGlobalData)//绝对数据
			{
				outputFrame.global.copy(outputFrame.transform);
			}
			
			outputFrame.scaleOffset.x = getNumber(frameObject, ConstValues.A_SCALE_X_OFFSET, 0) || 0;
			outputFrame.scaleOffset.y = getNumber(frameObject, ConstValues.A_SCALE_Y_OFFSET, 0) || 0;
			return outputFrame;
		}
		
		private static function parseSlotFrame(frameObject:Object, frameRate:uint):SlotFrame
		{
			var frame:SlotFrame = new SlotFrame();
			parseFrame(frameObject, frame, frameRate);
			
			frame.visible = !getBoolean(frameObject, ConstValues.A_HIDE, false);
			
			//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			frame.tweenEasing = getNumber(frameObject, ConstValues.A_TWEEN_EASING, 10);
			frame.displayIndex = int(getNumber(frameObject,ConstValues.A_DISPLAY_INDEX,0));
			
			//如果为NaN，则说明没有改变过zOrder
			frame.zOrder = getNumber(frameObject, ConstValues.A_Z_ORDER, tempDragonBonesData.isGlobalData ? NaN:0);
			
			var colorTransformObject:Object = frameObject[ConstValues.COLOR];
			if(colorTransformObject)
			{
				frame.color = new ColorTransform();
				parseColorTransform(colorTransformObject, frame.color);
			}
			
			return frame;
		}
		
		private static function parseTimeline(timelineObject:Object, outputTimeline:Timeline):void
		{
			var position:int = 0;
			var frame:Frame;
			for each(frame in outputTimeline.frameList)
			{
				frame.position = position;
				position += frame.duration;
			}
			//防止duration计算有误差
			if(frame)
			{
				frame.duration = outputTimeline.duration - frame.position;
			}
		}
		
		private static function parseFrame(frameObject:Object, outputFrame:Frame, frameRate:uint):void
		{
			outputFrame.duration = Math.round((Number(frameObject[ConstValues.A_DURATION])) * 1000 / frameRate);
			outputFrame.action = frameObject[ConstValues.A_ACTION];
			outputFrame.event = frameObject[ConstValues.A_EVENT];
			outputFrame.sound = frameObject[ConstValues.A_SOUND];
			if (frameObject[ConstValues.A_CURVE] != null && frameObject[ConstValues.A_CURVE].length == 4)
			{
				outputFrame.curve = new CurveData();
				outputFrame.curve.pointList = [new Point(frameObject[ConstValues.A_CURVE][0],
														 frameObject[ConstValues.A_CURVE][1]),
											   new Point(frameObject[ConstValues.A_CURVE][2],
														 frameObject[ConstValues.A_CURVE][3])];
			}
		}
		
		private static function parseTransform(transformObject:Object, transform:DBTransform, pivot:Point = null):void
		{
			if(transformObject)
			{
				if(transform)
				{
					transform.x = getNumber(transformObject,ConstValues.A_X,0) || 0;
					transform.y = getNumber(transformObject,ConstValues.A_Y,0) || 0;
					transform.skewX = getNumber(transformObject,ConstValues.A_SKEW_X,0) * ConstValues.ANGLE_TO_RADIAN || 0;
					transform.skewY = getNumber(transformObject,ConstValues.A_SKEW_Y,0) * ConstValues.ANGLE_TO_RADIAN || 0;
					transform.scaleX = getNumber(transformObject, ConstValues.A_SCALE_X, 1) || 0;
					transform.scaleY = getNumber(transformObject, ConstValues.A_SCALE_Y, 1) || 0;
				}
				if(pivot)
				{
					pivot.x = getNumber(transformObject,ConstValues.A_PIVOT_X,0) || 0;
					pivot.y = getNumber(transformObject,ConstValues.A_PIVOT_Y,0) || 0;
				}
			}
		}
		
		private static function parseColorTransform(colorTransformObject:Object, colorTransform:ColorTransform):void
		{
			if(colorTransformObject)
			{
				if(colorTransform)
				{
					colorTransform.alphaOffset = int(colorTransformObject[ConstValues.A_ALPHA_OFFSET]);
					colorTransform.redOffset = int(colorTransformObject[ConstValues.A_RED_OFFSET]);
					colorTransform.greenOffset = int(colorTransformObject[ConstValues.A_GREEN_OFFSET]);
					colorTransform.blueOffset = int(colorTransformObject[ConstValues.A_BLUE_OFFSET]);
					
					colorTransform.alphaMultiplier = int(getNumber(colorTransformObject, ConstValues.A_ALPHA_MULTIPLIER,100)) * 0.01;
					colorTransform.redMultiplier = int(getNumber(colorTransformObject,ConstValues.A_RED_MULTIPLIER,100)) * 0.01;
					colorTransform.greenMultiplier = int(getNumber(colorTransformObject,ConstValues.A_GREEN_MULTIPLIER,100)) * 0.01;
					colorTransform.blueMultiplier = int(getNumber(colorTransformObject,ConstValues.A_BLUE_MULTIPLIER,100)) * 0.01;
				}
			}
		}
		
		private static function getBoolean(data:Object, key:String, defaultValue:Boolean):Boolean
		{
			if(data && key in data)
			{
				switch(String(data[key]))
				{
					case "0":
					case "NaN":
					case "":
					case "false":
					case "null":
					case "undefined":
						return false;
						
					case "1":
					case "true":
					default:
						return true;
				}
			}
			return defaultValue;
		}
		
		private static function getNumber(data:Object, key:String, defaultValue:Number):Number
		{
			if(data && key in data)
			{
				switch(String(data[key]))
				{
					case "NaN":
					case "":
					case "false":
					case "null":
					case "undefined":
						return NaN;
						
					default:
						return Number(data[key]);
				}
			}
			return defaultValue;
		}
	}
}