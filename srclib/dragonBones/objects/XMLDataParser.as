package dragonBones.objects
{
	/**
	 * Copyright 2012-2013. DragonBones. All Rights Reserved.
	 * @playerversion Flash 10.0, Flash 10
	 * @langversion 3.0
	 * @version 2.0
	 */
	
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import dragonBones.core.DragonBones;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.ArmatureData;
	import dragonBones.objects.BoneData;
	import dragonBones.objects.DBTransform;
	import dragonBones.objects.DisplayData;
	import dragonBones.objects.Frame;
	import dragonBones.objects.SkeletonData;
	import dragonBones.objects.SkinData;
	import dragonBones.objects.SlotData;
	import dragonBones.objects.Timeline;
	import dragonBones.objects.TransformFrame;
	import dragonBones.objects.TransformTimeline;
	import dragonBones.textures.TextureData;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.DBDataUtil;
	import dragonBones.utils.TransformUtil;
	
	use namespace dragonBones_internal;
	
	/**
	 * The XMLDataParser class parses xml data from dragonBones generated maps.
	 */
	final public class XMLDataParser
	{
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
				
				var frameWidth:Number = int(subTextureXML.subTextureXML.@[ConstValues.A_FRAME_WIDTH]) / scale;
				var frameHeight:Number = int(subTextureXML.subTextureXML.@[ConstValues.A_FRAME_HEIGHT]) / scale;
				
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
		public static function parseSkeletonData(rawData:XML):SkeletonData
		{
			if(!rawData)
			{
				throw new ArgumentError();
			}
			var version:String = rawData.@[ConstValues.A_VERSION];
			switch (version)
			{
				case "2.3":
					//Update2_3To3_0.format(rawData as XML);
					break;
				
				case DragonBones.DATA_VERSION:
					break;
				
				default:
					throw new Error("Nonsupport version!");
			}
			
			var frameRate:uint = int(rawData.@[ConstValues.A_FRAME_RATE]);
			
			var data:SkeletonData = new SkeletonData();
			data.name = rawData.@[ConstValues.A_NAME];
			for each(var armatureXML:XML in rawData[ConstValues.ARMATURE])
			{
				data.addArmatureData(parseArmatureData(armatureXML, data, frameRate));
			}
			
			return data;
		}
		
		private static function parseArmatureData(armatureXML:XML, data:SkeletonData, frameRate:uint):ArmatureData
		{
			var armatureData:ArmatureData = new ArmatureData();
			armatureData.name = armatureXML.@[ConstValues.A_NAME];
			
			for each(var boneXML:XML in armatureXML[ConstValues.BONE])
			{
				armatureData.addBoneData(parseBoneData(boneXML));
			}
			
			for each(var skinXML:XML in armatureXML[ConstValues.SKIN])
			{
				armatureData.addSkinData(parseSkinData(skinXML, data));
			}
			
			DBDataUtil.transformArmatureData(armatureData);
			armatureData.sortBoneDataList();
			
			for each(var animationXML:XML in armatureXML[ConstValues.ANIMATION])
			{
				armatureData.addAnimationData(parseAnimationData(animationXML, armatureData, frameRate));
			}
			
			return armatureData;
		}
		
		private static function parseBoneData(boneXML:XML):BoneData
		{
			var boneData:BoneData = new BoneData();
			boneData.name = boneXML.@[ConstValues.A_NAME];
			boneData.parent = boneXML.@[ConstValues.A_PARENT];
			boneData.length = Number(boneXML.@[ConstValues.A_LENGTH]);
			boneData.inheritRotation = getBoolean(boneXML, ConstValues.A_INHERIT_ROTATION, true);
			boneData.inheritScale = getBoolean(boneXML, ConstValues.A_SCALE_MODE, false);
			
			parseTransform(boneXML[ConstValues.TRANSFORM][0], boneData.global);
			boneData.transform.copy(boneData.global);
			
			return boneData;
		}
		
		private static function parseSkinData(skinXML:XML, data:SkeletonData):SkinData
		{
			var skinData:SkinData = new SkinData();
			skinData.name = skinXML.@[ConstValues.A_NAME];
			
			for each(var slotXML:XML in skinXML[ConstValues.SLOT])
			{
				skinData.addSlotData(parseSlotData(slotXML, data));
			}
			
			return skinData;
		}
		
		private static function parseSlotData(slotXML:XML, data:SkeletonData):SlotData
		{
			var slotData:SlotData = new SlotData();
			slotData.name = slotXML.@[ConstValues.A_NAME];
			slotData.parent = slotXML.@[ConstValues.A_PARENT];
			slotData.zOrder = Number(slotXML.@[ConstValues.A_Z_ORDER]);
			slotData.blendMode = slotXML.@[ConstValues.A_BLENDMODE];
			for each(var displayXML:XML in slotXML[ConstValues.DISPLAY])
			{
				slotData.addDisplayData(parseDisplayData(displayXML, data));
			}
			
			return slotData;
		}
		
		private static function parseDisplayData(displayXML:XML, data:SkeletonData):DisplayData
		{
			var displayData:DisplayData = new DisplayData();
			displayData.name = displayXML.@[ConstValues.A_NAME];
			displayData.type = displayXML.@[ConstValues.A_TYPE];
			
			displayData.pivot = data.addSubTexturePivot(
				0, 
				0, 
				displayData.name
			);
			
			parseTransform(displayXML[ConstValues.TRANSFORM][0], displayData.transform, displayData.pivot);
			
			return displayData;
		}
		
		/** @private */
		dragonBones_internal static function parseAnimationData(animationXML:XML, armatureData:ArmatureData, frameRate:uint):AnimationData
		{
			var animationData:AnimationData = new AnimationData();
			animationData.name = animationXML.@[ConstValues.A_NAME];
			animationData.frameRate = frameRate;
			animationData.playTimes = int(animationXML.@[ConstValues.A_LOOP]);
			animationData.fadeTime = Number(animationXML.@[ConstValues.A_FADE_IN_TIME]);
			animationData.duration = (Number(animationXML.@[ConstValues.A_DURATION]) || 1) / frameRate;
			animationData.scale = getNumber(animationXML, ConstValues.A_SCALE, 1) || 0;
			//use frame tweenEase, NaN
			//overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			animationData.tweenEasing = getNumber(animationXML, ConstValues.A_TWEEN_EASING, NaN);
			animationData.autoTween = getBoolean(animationXML, ConstValues.A_AUTO_TWEEN, true);
			
			parseTimeline(animationXML, animationData, parseMainFrame, frameRate);
			
			var lastFrameDuration:Number = animationData.duration;
			for each(var timelineXML:XML in animationXML[ConstValues.TIMELINE])
			{
				var timeline:TransformTimeline = parseTransformTimeline(timelineXML, animationData.duration, frameRate);
				lastFrameDuration = Math.min(lastFrameDuration, timeline.frameList[timeline.frameList.length - 1].duration);
				animationData.addTimeline(timeline);
			}
			
			if(animationData.frameList.length > 0)
			{
				lastFrameDuration = Math.min(lastFrameDuration, animationData.frameList[animationData.frameList.length - 1].duration);
			}
			animationData.lastFrameDuration = lastFrameDuration;
			
			DBDataUtil.addHideTimeline(animationData, armatureData);
			DBDataUtil.transformAnimationData(animationData, armatureData);
			
			return animationData;
		}
		
		private static function parseTimeline(timelineXML:XML, timeline:Timeline, frameParser:Function, frameRate:uint):void
		{
			var position:Number = 0;
			var frame:Frame;
			for each(var frameXML:XML in timelineXML[ConstValues.FRAME])
			{
				frame = frameParser(frameXML, frameRate);
				frame.position = position;
				timeline.addFrame(frame);
				position += frame.duration;
			}
			if(frame)
			{
				frame.duration = timeline.duration - frame.position;
			}
		}
		
		private static function parseTransformTimeline(timelineXML:XML, duration:Number, frameRate:uint):TransformTimeline
		{
			var timeline:TransformTimeline = new TransformTimeline();
			timeline.name = timelineXML.@[ConstValues.A_NAME];
			timeline.duration = duration;
			timeline.scale = getNumber(timelineXML, ConstValues.A_SCALE, 1) || 0;
			timeline.offset = getNumber(timelineXML, ConstValues.A_OFFSET, 0) || 0;
			
			parseTimeline(timelineXML, timeline, parseTransformFrame, frameRate);
			
			return timeline;
		}
		
		private static function parseFrame(frameXML:XML, frame:Frame, frameRate:uint):void
		{
			frame.duration = (Number(frameXML.@[ConstValues.A_DURATION]) || 1) / frameRate;
			frame.action = frameXML.@[ConstValues.A_ACTION];
			frame.event = frameXML.@[ConstValues.A_EVENT];
			frame.sound = frameXML.@[ConstValues.A_SOUND];
		}
		
		private static function parseMainFrame(frameXML:XML, frameRate:uint):Frame
		{
			var frame:Frame = new Frame();
			parseFrame(frameXML, frame, frameRate);
			return frame;
		}
		
		private static function parseTransformFrame(frameXML:XML, frameRate:uint):TransformFrame
		{
			var frame:TransformFrame = new TransformFrame();
			parseFrame(frameXML, frame, frameRate);
			
			frame.visible = !getBoolean(frameXML, ConstValues.A_HIDE, false);
			
			//NaN:no tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			frame.tweenEasing = getNumber(frameXML, ConstValues.A_TWEEN_EASING, 0);
			frame.tweenRotate = Number(frameXML.@[ConstValues.A_TWEEN_ROTATE]);
			frame.tweenScale = getBoolean(frameXML, ConstValues.A_TWEEN_SCALE, true);
			frame.displayIndex = Number(frameXML.@[ConstValues.A_DISPLAY_INDEX]);
			
			//如果为NaN，则说明没有改变过zOrder
			frame.zOrder = getNumber(frameXML, ConstValues.A_Z_ORDER, NaN);
			
			parseTransform(frameXML[ConstValues.TRANSFORM][0], frame.global, frame.pivot);
			frame.transform.copy(frame.global);
			
			var colorTransformXML:XML = frameXML[ConstValues.COLOR_TRANSFORM][0];
			if(colorTransformXML)
			{
				frame.color = new ColorTransform();
				frame.color.alphaOffset = Number(colorTransformXML.@[ConstValues.A_ALPHA_OFFSET]);
				frame.color.redOffset = Number(colorTransformXML.@[ConstValues.A_RED_OFFSET]);
				frame.color.greenOffset = Number(colorTransformXML.@[ConstValues.A_GREEN_OFFSET]);
				frame.color.blueOffset = Number(colorTransformXML.@[ConstValues.A_BLUE_OFFSET]);
				
				frame.color.alphaMultiplier = Number(colorTransformXML.@[ConstValues.A_ALPHA_MULTIPLIER]) * 0.01;
				frame.color.redMultiplier = Number(colorTransformXML.@[ConstValues.A_RED_MULTIPLIER]) * 0.01;
				frame.color.greenMultiplier = Number(colorTransformXML.@[ConstValues.A_GREEN_MULTIPLIER]) * 0.01;
				frame.color.blueMultiplier = Number(colorTransformXML.@[ConstValues.A_BLUE_MULTIPLIER]) * 0.01;
			}
			
			return frame;
		}
		
		private static function parseTransform(transformXML:XML, transform:DBTransform, pivot:Point = null):void
		{
			if(transformXML)
			{
				if(transform)
				{
					transform.x = Number(transformXML.@[ConstValues.A_X]) || 0;
					transform.y = Number(transformXML.@[ConstValues.A_Y]) || 0;
					transform.skewX = Number(transformXML.@[ConstValues.A_SKEW_X]) * ConstValues.ANGLE_TO_RADIAN || 0;
					transform.skewY = Number(transformXML.@[ConstValues.A_SKEW_Y]) * ConstValues.ANGLE_TO_RADIAN || 0;
					transform.scaleX = getNumber(transformXML, ConstValues.A_SCALE_X, 1) || 0;
					transform.scaleY = getNumber(transformXML, ConstValues.A_SCALE_Y, 1) || 0;
				}
				if(pivot)
				{
					pivot.x = Number(transformXML.@[ConstValues.A_PIVOT_X]) || 0;
					pivot.y = Number(transformXML.@[ConstValues.A_PIVOT_Y]) || 0;
				}
			}
		}
		
		private static function getBoolean(data:XML, key:String, defaultValue:Boolean):Boolean
		{
			if(data.@[key].length() > 0)
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
			if(data.@[key].length() > 0)
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

/*
import dragonBones.utils.ConstValues;

class Update2_3To3_0
{
	public static function format(skeleton:XML):void
	{
		//删除两个旧属性
		for each(var boneXML:XML in skeleton[ConstValues.ARMATURE][ConstValues.BONE])
		{
			if(String(boneXML.@[ConstValues.A_FIXED_ROTATION]) == "true")
			{
				boneXML.@[ConstValues.A_INHERIT_ROTATION] = 0;
			}
			delete boneXML.@[ConstValues.A_FIXED_ROTATION];
			
			if(String(boneXML.@[ConstValues.A_SCALE_MODE]) == "2")
			{
				boneXML.@[ConstValues.A_INHERIT_SCALE] = 1;
			}
			delete boneXML.@[ConstValues.A_SCALE_MODE];
		}
	}
}
*/