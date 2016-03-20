package dragonBones.objects {

	import dragonBones.core.DragonBones;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.textures.TextureData;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.DBDataUtil;

	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Copyright 2012-2013. DragonBones. All Rights Reserved.
	 * @playerversion Flash 10.0, Flash 10
	 * @langversion 3.0
	 * @version 2.0
	 */
	
	
	use namespace dragonBones_internal;
	
	/**
	 * The XMLDataParser class parses xml data from dragonBones generated maps.
	 */
	final public class XMLDataParser
	{
		private static var tempDragonBonesData:DragonBonesData;
		
		public static function parseTextureAtlasData(rawData:XML, scale:Number = 1):Object
		{
			var textureAtlasData:Object = {};
			textureAtlasData.__name = rawData.@[ConstValues.A_NAME];
			var subTextureFrame:Rectangle;
			for each (var subTextureXML:XML in rawData[ConstValues.SUB_TEXTURE])
			{
				var subTextureName:String = subTextureXML.@[ConstValues.A_NAME];
				
				var subTextureRegion:Rectangle = new Rectangle();
				subTextureRegion.x = int(subTextureXML.@[ConstValues.A_X]) / scale;
				subTextureRegion.y = int(subTextureXML.@[ConstValues.A_Y]) / scale;
				subTextureRegion.width = int(subTextureXML.@[ConstValues.A_WIDTH]) / scale;
				subTextureRegion.height = int(subTextureXML.@[ConstValues.A_HEIGHT]) / scale;
				var rotated:Boolean = subTextureXML.@[ConstValues.A_ROTATED] == "true";
				
				var frameWidth:Number = int(subTextureXML.@[ConstValues.A_FRAME_WIDTH]) / scale;
				var frameHeight:Number = int(subTextureXML.@[ConstValues.A_FRAME_HEIGHT]) / scale;
				
				if(frameWidth > 0 && frameHeight > 0)
				{
					subTextureFrame = new Rectangle();
					subTextureFrame.x = int(subTextureXML.@[ConstValues.A_FRAME_X]) / scale;
					subTextureFrame.y = int(subTextureXML.@[ConstValues.A_FRAME_Y]) / scale;
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
		
		/**
		 * Parse the SkeletonData.
		 * @param xml The SkeletonData xml to parse.
		 * @return A SkeletonData instance.
		 */
		public static function parseDragonBonesData(rawData:XML):DragonBonesData
		{
			if(!rawData)
			{
				throw new ArgumentError();
			}
			var version:String = rawData.@[ConstValues.A_VERSION];
			switch (version)
			{
				case "2.3":
				case "3.0":
					return XML3DataParser.parseSkeletonData(rawData);
					break;
				case DragonBones.DATA_VERSION:
					break;
				
				default:
					throw new Error("Nonsupport version!");
			}
			
			var frameRate:uint = int(rawData.@[ConstValues.A_FRAME_RATE]);
			
			var outputDragonBonesData:DragonBonesData = new DragonBonesData();
			outputDragonBonesData.name = rawData.@[ConstValues.A_NAME];
			outputDragonBonesData.isGlobalData = rawData.@[ConstValues.A_IS_GLOBAL] == "0" ? false : true;
			tempDragonBonesData = outputDragonBonesData;
			for each(var armatureXML:XML in rawData[ConstValues.ARMATURE])
			{
				outputDragonBonesData.addArmatureData(parseArmatureData(armatureXML, frameRate));
			}
			tempDragonBonesData = null;
			
			return outputDragonBonesData;
		}
		
		private static function parseArmatureData(armatureXML:XML, frameRate:uint):ArmatureData
		{
			var outputArmatureData:ArmatureData = new ArmatureData();
			outputArmatureData.name = armatureXML.@[ConstValues.A_NAME];
			
			for each(var boneXML:XML in armatureXML[ConstValues.BONE])
			{
				outputArmatureData.addBoneData(parseBoneData(boneXML));
			}
			for each(var slotXML:XML in armatureXML[ConstValues.SLOT])
			{
				outputArmatureData.addSlotData(parseSlotData(slotXML));
			}
			for each(var skinXML:XML in armatureXML[ConstValues.SKIN])
			{
				outputArmatureData.addSkinData(parseSkinData(skinXML));
			}
			
			if(tempDragonBonesData.isGlobalData)
			{
				DBDataUtil.transformArmatureData(outputArmatureData);
			}
			
			outputArmatureData.sortBoneDataList();
			
			var animationXML:XML;
			
			for each(animationXML in armatureXML[ConstValues.ANIMATION])
			{
				var animationData:AnimationData = parseAnimationData(animationXML, frameRate);
				DBDataUtil.addHideTimeline(animationData, outputArmatureData);
				DBDataUtil.transformAnimationData(animationData, outputArmatureData, tempDragonBonesData.isGlobalData);
				outputArmatureData.addAnimationData(animationData);
			}
			
			return outputArmatureData;
		}
		
		private static function parseBoneData(boneXML:XML):BoneData
		{
			var boneData:BoneData = new BoneData();
			boneData.name = boneXML.@[ConstValues.A_NAME];
			boneData.parent = boneXML.@[ConstValues.A_PARENT];
			boneData.length = Number(boneXML.@[ConstValues.A_LENGTH]);
			boneData.inheritRotation = getBoolean(boneXML, ConstValues.A_INHERIT_ROTATION, true);
			boneData.inheritScale = getBoolean(boneXML, ConstValues.A_INHERIT_SCALE, true);
			
			parseTransform(boneXML[ConstValues.TRANSFORM][0], boneData.transform);
			if(tempDragonBonesData.isGlobalData)//绝对数据
			{
				boneData.global.copy(boneData.transform);
			}
			
			return boneData;
		}
		
		
		private static function parseSkinData(skinXML:XML):SkinData
		{
			var skinData:SkinData = new SkinData();
			skinData.name = skinXML.@[ConstValues.A_NAME];
			
			for each(var slotXML:XML in skinXML[ConstValues.SLOT])
			{
				skinData.addSlotData(parseSlotDisplayData(slotXML));
			}
			
			return skinData;
		}
		
		private static function parseSlotDisplayData(slotXML:XML):SlotData
		{
			var slotData:SlotData = new SlotData();
			slotData.name = slotXML.@[ConstValues.A_NAME];
			for each(var displayXML:XML in slotXML[ConstValues.DISPLAY])
			{
				slotData.addDisplayData(parseDisplayData(displayXML));
			}
			
			return slotData;
		}
		
		private static function parseSlotData(slotXML:XML):SlotData
		{
			var slotData:SlotData = new SlotData();
			slotData.name = slotXML.@[ConstValues.A_NAME];
			slotData.parent = slotXML.@[ConstValues.A_PARENT];
			slotData.zOrder = getNumber(slotXML,ConstValues.A_Z_ORDER,0)||0;
			slotData.blendMode = slotXML.@[ConstValues.A_BLENDMODE];
			slotData.displayIndex = slotXML.@[ConstValues.A_DISPLAY_INDEX];
			return slotData;
		}
		
		private static function parseDisplayData(displayXML:XML):DisplayData
		{
			var displayData:DisplayData = new DisplayData();
			displayData.name = displayXML.@[ConstValues.A_NAME];
			displayData.type = displayXML.@[ConstValues.A_TYPE];
			
			parseTransform(displayXML[ConstValues.TRANSFORM][0], displayData.transform, displayData.pivot);
			
			displayData.pivot.x = NaN;
			displayData.pivot.y = NaN;
			
			if(tempDragonBonesData!=null)
			{
				tempDragonBonesData.addDisplayData(displayData);
			}
			
			return displayData;
		}
		
		/** @private */
		dragonBones_internal static function parseAnimationData(animationXML:XML, frameRate:uint):AnimationData
		{
			var animationData:AnimationData = new AnimationData();
			animationData.name = animationXML.@[ConstValues.A_NAME];
			animationData.frameRate = frameRate;
			animationData.duration = Math.round((int(animationXML.@[ConstValues.A_DURATION]) || 1) * 1000 / frameRate);
			animationData.playTimes = int(getNumber(animationXML,ConstValues.A_PLAY_TIMES,1));
			animationData.fadeTime = getNumber(animationXML,ConstValues.A_FADE_IN_TIME,0)||0;
			animationData.scale = getNumber(animationXML, ConstValues.A_SCALE, 1) || 0;
			//use frame tweenEase, NaN
			//overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			animationData.tweenEasing = getNumber(animationXML, ConstValues.A_TWEEN_EASING, NaN);
			animationData.autoTween = getBoolean(animationXML, ConstValues.A_AUTO_TWEEN, true);
			
			for each(var frameXML:XML in animationXML[ConstValues.FRAME])
			{
				var frame:Frame = parseTransformFrame(frameXML, frameRate);
				animationData.addFrame(frame);
			}
			
			parseTimeline(animationXML, animationData);
			
			var lastFrameDuration:int = animationData.duration;
			for each(var timelineXML:XML in animationXML[ConstValues.BONE])
			{
				var timeline:TransformTimeline = parseTransformTimeline(timelineXML, animationData.duration, frameRate);
				if (timeline.frameList.length > 0)
				{
					lastFrameDuration = Math.min(lastFrameDuration, timeline.frameList[timeline.frameList.length - 1].duration);
					animationData.addTimeline(timeline);
				}
				
			}
			
			for each(var slotTimelineXML:XML in animationXML[ConstValues.SLOT])
			{
				var slotTimeline:SlotTimeline = parseSlotTimeline(slotTimelineXML, animationData.duration, frameRate);
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
			animationData.lastFrameDuration = lastFrameDuration;
			
			return animationData;
		}
		
		private static function parseTransformTimeline(timelineXML:XML, duration:int, frameRate:uint):TransformTimeline
		{
			var timeline:TransformTimeline = new TransformTimeline();
			timeline.name = timelineXML.@[ConstValues.A_NAME];
			timeline.scale = getNumber(timelineXML, ConstValues.A_SCALE, 1) || 0;
			timeline.offset = getNumber(timelineXML, ConstValues.A_OFFSET, 0) || 0;
			timeline.originPivot.x = getNumber(timelineXML, ConstValues.A_PIVOT_X, 0) || 0;
			timeline.originPivot.y = getNumber(timelineXML, ConstValues.A_PIVOT_Y, 0) || 0;
			timeline.duration = duration;
			
			for each(var frameXML:XML in timelineXML[ConstValues.FRAME])
			{
				var frame:TransformFrame = parseTransformFrame(frameXML, frameRate);
				timeline.addFrame(frame);
			}
			
			parseTimeline(timelineXML, timeline);
			
			return timeline;
		}
		
		private static function parseSlotTimeline(timelineXML:XML, duration:int, frameRate:uint):SlotTimeline
		{
			var timeline:SlotTimeline = new SlotTimeline();
			timeline.name = timelineXML.@[ConstValues.A_NAME];
			timeline.scale = getNumber(timelineXML, ConstValues.A_SCALE, 1) || 0;
			timeline.offset = getNumber(timelineXML, ConstValues.A_OFFSET, 0) || 0;
			timeline.duration = duration;
			
			for each(var frameXML:XML in timelineXML[ConstValues.FRAME])
			{
				var frame:SlotFrame = parseSlotFrame(frameXML, frameRate);
				timeline.addFrame(frame);
			}
			
			parseTimeline(timelineXML, timeline);
			
			return timeline;
		}
		
		private static function parseMainFrame(frameXML:XML, frameRate:uint):Frame
		{
			var frame:Frame = new Frame();
			parseFrame(frameXML, frame, frameRate);
			return frame;
		}
		
		private static function parseSlotFrame(frameXML:XML, frameRate:uint):SlotFrame
		{
			var frame:SlotFrame = new SlotFrame();
			parseFrame(frameXML, frame, frameRate);
			
			frame.visible = !getBoolean(frameXML, ConstValues.A_HIDE, false);
			
			//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			frame.tweenEasing = getNumber(frameXML, ConstValues.A_TWEEN_EASING, 10);
			frame.displayIndex = int(getNumber(frameXML,ConstValues.A_DISPLAY_INDEX,0));
			
			//如果为NaN，则说明没有改变过zOrder
			frame.zOrder = getNumber(frameXML, ConstValues.A_Z_ORDER, tempDragonBonesData.isGlobalData ? NaN:0);
				
			var colorTransformXML:XML = frameXML[ConstValues.COLOR][0];
			if(colorTransformXML)
			{
				frame.color = new ColorTransform();
				parseColorTransform(colorTransformXML, frame.color);
			}
			
			return frame;
		}
		
		private static function parseTransformFrame(frameXML:XML, frameRate:uint):TransformFrame
		{
			var frame:TransformFrame = new TransformFrame();
			parseFrame(frameXML, frame, frameRate);
			
			frame.visible = !getBoolean(frameXML, ConstValues.A_HIDE, false);
			
			//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			frame.tweenEasing = getNumber(frameXML, ConstValues.A_TWEEN_EASING, 10);
			frame.tweenRotate = int(getNumber(frameXML,ConstValues.A_TWEEN_ROTATE,0));
			frame.tweenScale = getBoolean(frameXML, ConstValues.A_TWEEN_SCALE, true);
//			frame.displayIndex = int(getNumber(frameXML,ConstValues.A_DISPLAY_INDEX,0));
			
			
			parseTransform(frameXML[ConstValues.TRANSFORM][0], frame.transform, frame.pivot);
			if(tempDragonBonesData.isGlobalData)//绝对数据
			{
				frame.global.copy(frame.transform);
			}
			
			frame.scaleOffset.x = getNumber(frameXML, ConstValues.A_SCALE_X_OFFSET, 0) || 0;
			frame.scaleOffset.y = getNumber(frameXML, ConstValues.A_SCALE_Y_OFFSET, 0) || 0;
			
			return frame;
		}
		
		private static function parseTimeline(timelineXML:XML, timeline:Timeline):void
		{
			var position:int = 0;
			var frame:Frame;
			for each(frame in timeline.frameList)
			{
				frame.position = position;
				position += frame.duration;
			}
			if(frame)
			{
				frame.duration = timeline.duration - frame.position;
			}
		}
		
		private static function parseFrame(frameXML:XML, frame:Frame, frameRate:uint):void
		{
			frame.duration = Math.round((int(frameXML.@[ConstValues.A_DURATION])) * 1000 / frameRate);
			frame.action = frameXML.@[ConstValues.A_ACTION];
			frame.event = frameXML.@[ConstValues.A_EVENT];
			frame.sound = frameXML.@[ConstValues.A_SOUND];
		}
		
		private static function parseTransform(transformXML:XML, transform:DBTransform, pivot:Point = null):void
		{
			if(transformXML)
			{
				if(transform)
				{
					transform.x = getNumber(transformXML,ConstValues.A_X,0) || 0;
					transform.y = getNumber(transformXML,ConstValues.A_Y,0) || 0;
					transform.skewX = getNumber(transformXML,ConstValues.A_SKEW_X,0) * ConstValues.ANGLE_TO_RADIAN || 0;
					transform.skewY = getNumber(transformXML,ConstValues.A_SKEW_Y,0) * ConstValues.ANGLE_TO_RADIAN || 0;
					transform.scaleX = getNumber(transformXML, ConstValues.A_SCALE_X, 1) || 0;
					transform.scaleY = getNumber(transformXML, ConstValues.A_SCALE_Y, 1) || 0;
				}
				if(pivot)
				{
					pivot.x = getNumber(transformXML,ConstValues.A_PIVOT_X,0) || 0;
					pivot.y = getNumber(transformXML,ConstValues.A_PIVOT_Y,0) || 0;
				}
			}
		}
		
		private static function parseColorTransform(colorTransformXML:XML, colorTransform:ColorTransform):void
		{
			if(colorTransformXML)
			{
				if(colorTransform)
				{
					colorTransform.alphaOffset = int(colorTransformXML.@[ConstValues.A_ALPHA_OFFSET]);
					colorTransform.redOffset = int(colorTransformXML.@[ConstValues.A_RED_OFFSET]);
					colorTransform.greenOffset = int(colorTransformXML.@[ConstValues.A_GREEN_OFFSET]);
					colorTransform.blueOffset = int(colorTransformXML.@[ConstValues.A_BLUE_OFFSET]);
					
					colorTransform.alphaMultiplier = int(getNumber(colorTransformXML, ConstValues.A_ALPHA_MULTIPLIER, 100) || 0) * 0.01;
					colorTransform.redMultiplier = int(getNumber(colorTransformXML, ConstValues.A_RED_MULTIPLIER, 100) || 0) * 0.01;
					colorTransform.greenMultiplier = int(getNumber(colorTransformXML, ConstValues.A_GREEN_MULTIPLIER, 100) || 0) * 0.01;
					colorTransform.blueMultiplier = int(getNumber(colorTransformXML, ConstValues.A_BLUE_MULTIPLIER, 100) || 0) * 0.01;
				}
			}
		}
		
		private static function getBoolean(data:XML, key:String, defaultValue:Boolean):Boolean
		{
			if(data && data.@[key].length() > 0)
			{
				switch(String(data.@[key]))
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
		
		private static function getNumber(data:XML, key:String, defaultValue:Number):Number
		{
			if(data && data.@[key].length() > 0)
			{
				switch(String(data.@[key]))
				{
					case "NaN":
					case "":
					case "false":
					case "null":
					case "undefined":
						return NaN;
						
					default:
						return Number(data.@[key]);
				}
			}
			return defaultValue;
		}
	}
}